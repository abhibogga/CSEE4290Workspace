#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <winsock2.h> //For windows compilation
#include <ws2tcpip.h> //For windows compilation
#include <math.h>

int associativity = 2;    // Associativity of cache
int blocksize_bytes = 32; // Cache Block size in bytes
int cachesize_kb = 30;    // Cache size in KB
int miss_penalty = 30;

void print_usage(void)
{
  printf("Usage: gunzip2 -c <tracefile> | ./cache -a <assoc> -l <blksz> -s <size> -mp <mispen>\n");
  printf("  <tracefile>: The memory trace file\n");
  printf("  -a <assoc>: The associativity of the cache\n");
  printf("  -l <blksz>: The blocksize (in bytes) of the cache\n");
  printf("  -s <size>: The size (in KB) of the cache\n");
  printf("  -mp <mispen>: The miss penalty (in cycles) of a miss\n");
  exit(0);
}

struct cacheLine
{
  int dirty;
  int tag;
  int valid;
  int uses;
};

int isFull(int indexOfSet, struct cacheLine **cacheLinePointer)
{

  for (int i = 0; i < associativity; i++)
  {

    if ((cacheLinePointer[i])->valid == 0)
    {
      return 0; // return false
    }
  }

  return 1; // return true
}

int findVictim(int indexOfSet, struct cacheLine **cacheLinePointer)
{
  int victim = 0;

  for (int i = 0; i < associativity; i++)
  {

    if ((cacheLinePointer[i])->uses < (cacheLinePointer[victim])->uses)
    {
      victim = i;
    }
  }

  return victim; // return the pointer difference to where our victim is to evict location
}

int main(int argc, char *argv[])
{


  unsigned long address = 0; // use unsigned long for shifts and bit masking
  int loadstore = 0, icount = 0;
  char marker = 0;

  int i = 0;
  int j = 1;

  // Process the command line arguments
  while (j < argc)
  {
    if (strcmp("-a", argv[j]) == 0)
    {
      j++;
      if (j >= argc)
        print_usage();
      associativity = atoi(argv[j]);
      j++;
    }
    else if (strcmp("-l", argv[j]) == 0)
    {
      j++;
      if (j >= argc)
        print_usage();
      blocksize_bytes = atoi(argv[j]);
      j++;
    }
    else if (strcmp("-s", argv[j]) == 0)
    {
      j++;
      if (j >= argc)
        print_usage();
      cachesize_kb = atoi(argv[j]);
      j++;
    }
    else if (strcmp("-mp", argv[j]) == 0)
    {
      j++;
      if (j >= argc)
        print_usage();
      miss_penalty = atoi(argv[j]);
      j++;
    }
    else
    {
      print_usage();
    }
  }

  // print out cache configuration
  printf("Cache parameters:\n");
  printf("Cache Size (KB)\t\t\t%d\n", cachesize_kb);
  printf("Cache Associativity\t\t%d\n", associativity);
  printf("Cache Block Size (bytes)\t%d\n", blocksize_bytes);
  printf("Miss penalty (cyc)\t\t%d\n", miss_penalty);
  printf("\n");

  int cacheLines = (cachesize_kb * 1024) / blocksize_bytes; // total cache lines
  int sets = cacheLines / associativity;

  struct cacheLine *cache[sets][associativity];

  // Allocate cache lines
  for (int k = 0; k < sets; k++)
  {
    for (int l = 0; l < associativity; l++)
    {
      cache[k][l] = (struct cacheLine *)malloc(sizeof(struct cacheLine));
      if (cache[k][l] == NULL)
      {
        fprintf(stderr, "malloc failed at set %d, way %d\n", k, l);
        exit(1);
      }
      cache[k][l]->valid = 0;
      cache[k][l]->dirty = 0;
      cache[k][l]->tag = -1;
      cache[k][l]->uses = 0;
    }
  }

  int indexBits = (int)log2((double)sets);
  int offsetBits = (int)log2((double)blocksize_bytes);
  int tagBits = 32 - (indexBits + offsetBits);

  printf("indexBits: %d  || offsetBits: %d || tagBits: %d\n", indexBits, offsetBits, tagBits);

  // Stat Vars
  int hitCount_load = 0;
  int missCount_load = 0;
  int hitCount_store = 0;
  int missCount_store = 0;
  int instructionsParsed = 0;
  int memAccess = 0;
  long totalCycles = 0;
  int dirtyEvictions = 0;

  long global_counter = 0; // COunt whenever a line is accessed in a set

  // Change miss penalty based on block size
  if (blocksize_bytes == 32) {
    miss_penalty += 2; 
  } else if (blocksize_bytes == 64) {
    miss_penalty += 6;
  } else if (blocksize_bytes == 128) {
    miss_penalty += 12;
  }

    // Cache simulation loop
    while (scanf(" %c %d %lx %d", &marker, &loadstore, &address, &icount) != EOF)
    {
      int index = (int)((address >> offsetBits) & ((1UL << indexBits) - 1));
      int checkedTag = (int)(address >> (indexBits + offsetBits));

      memAccess++;
      totalCycles += icount;
      instructionsParsed += icount;
      global_counter++; // Line is accessed in every set

      if (loadstore == 0)
      { // LOAD

        int hit = 0;
        int hitWay = -1;

        // First pass: check ALL ways for a hit
        for (int w = 0; w < associativity; w++)
        {

          if (cache[index][w]->valid == 1 &&
              cache[index][w]->tag == checkedTag)
          {

            // HIT
            hit = 1;
            hitWay = w;
            break;
          }
        }

        if (hit)
        {
          // Handle LOAD hit
          hitCount_load++;
          cache[index][hitWay]->uses = global_counter; // Line accessed is now filled with most recently used!
        }
        else
        {
          // MISS
          missCount_load++;

          // Check for empty slot
          int emptyWay = -1;
          for (int w = 0; w < associativity; w++)
          {
            if (cache[index][w]->valid == 0)
            {
              emptyWay = w;
              break;
            }
          }

          int targetWay;

          if (emptyWay != -1)
          {
            // There is space; no eviction
            targetWay = emptyWay;
          }
          else
          {
            // No space → eviction
            targetWay = findVictim(index, cache[index]);

            if (cache[index][targetWay]->dirty == 1)
            {

              // Dirty eviction: write-back cost
              dirtyEvictions++;
              totalCycles += 2;
            }
          }

          // Install new line
          cache[index][targetWay]->tag = checkedTag;
          cache[index][targetWay]->valid = 1;
          cache[index][targetWay]->dirty = 0;
          cache[index][targetWay]->uses = global_counter; // New line is now filled with most recently used!

          // Miss penalty timing
          totalCycles += miss_penalty;
        }
      }
      else
      { // STORE

        int hit = 0;
        int hitWay = -1;

        // First pass: check ALL ways for a hit
        for (int w = 0; w < associativity; w++)
        {

          if (cache[index][w]->valid == 1 && cache[index][w]->tag == checkedTag)
          {

            // HIT
            hit = 1;
            hitWay = w;
            break;
          }
        }

        if (hit)
        {
          // STORE hit
          hitCount_store++;
          cache[index][hitWay]->dirty = 1;             // stores make line dirty
          cache[index][hitWay]->uses = global_counter; // Line used here is now most recently used
        }
        else
        {
          // STORE miss
          missCount_store++;

          // Check for empty slot
          int emptyWay = -1;
          for (int w = 0; w < associativity; w++)
          {
            if (cache[index][w]->valid == 0)
            {
              emptyWay = w;
              break;
            }
          }

          int targetWay;

          if (emptyWay != -1)
          {
            // Use empty slot
            targetWay = emptyWay;
          }
          else
          {
            // Need eviction

            targetWay = findVictim(index, cache[index]);

            if (cache[index][targetWay]->dirty == 1)
            {

              // Dirty eviction: write-back cost
              dirtyEvictions++;
              totalCycles += 2;
            }
          }

          // Install new line
          cache[index][targetWay]->tag = checkedTag;
          cache[index][targetWay]->valid = 1;
          cache[index][targetWay]->dirty = 1;             // stores make new line dirty
          cache[index][targetWay]->uses = global_counter; // New line is now filled with most recently used!

          // Miss penalty timing
          totalCycles += miss_penalty;
        }
      }
    }

  //printf("Lines found = %i \n", i);
  //printf("Simulation results:\n");

  printf("execution time %ld cycles\n", totalCycles);
  //printf("instructions %d\n", instructionsParsed);
  //printf("memory accesses %d\n", memAccess);
  printf("total cpi %.2f\n", (double)totalCycles / (double)instructionsParsed);
  printf("overall miss rate %.2f\n", ((double)(missCount_load + missCount_store) / (double)memAccess));
  /*printf("read miss rate %.2f\n", ((double)(missCount_load) / (double)(missCount_load + hitCount_load)));
  printf("memory cpi %.2f\n", ((double)totalCycles / (double)instructionsParsed) - 1);                                                      // Assume ideal cache hit = 1 cycle
                                                               // TOTAL CPI
  printf("dirty evitions %d\n", dirtyEvictions);
  printf("load_misses %d\n", missCount_load);
  printf("store_misses %d\n", missCount_store);
  printf("load_hits %d\n", hitCount_load);
  printf("store_hits %d\n", hitCount_store);*/

  return 0;
}