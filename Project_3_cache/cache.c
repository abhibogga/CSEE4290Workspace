#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <winsock2.h> //For windows compilation
#include <ws2tcpip.h> //For windows compilation
#include <math.h>

int associativity = 1;    // Associativity of cache
int blocksize_bytes = 16; // Cache Block size in bytes
int cachesize_kb = 16;    // Cache size in KB
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

  struct cacheLine
  {
    int dirty;
    int tag;
    int valid;
  };

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

  // Cache simulation loop
  while (scanf(" %c %d %lx %d", &marker, &loadstore, &address, &icount) != EOF)
  {
    int index = (int)((address >> offsetBits) & ((1UL << indexBits) - 1));
    int checkedTag = (int)(address >> (indexBits + offsetBits));

    memAccess++;
    totalCycles += icount;
    instructionsParsed += icount;

    if (loadstore == 0)
    { // LOAD
      for (int search = 0; search < associativity; search++)
      {
        if (cache[index][search]->tag == checkedTag && cache[index][search]->valid == 1)
        {
          hitCount_load++;
          break;
        }
        else
        {
          if (cache[index][search]->valid && cache[index][search]->dirty)
            totalCycles += miss_penalty + 2;
          else
            totalCycles += miss_penalty;

          cache[index][search]->tag = checkedTag;
          cache[index][search]->valid = 1;
          cache[index][search]->dirty = 0;
          missCount_load++;
          break;
        }
      }
    }
    else
    { // STORE
      for (int search = 0; search < associativity; search++)
      {
        if (cache[index][search]->tag == checkedTag && cache[index][search]->valid == 1)
        {
          hitCount_store++;
          cache[index][search]->dirty = 1;
          break;
        }
        else
        {
          if (cache[index][search]->valid && cache[index][search]->dirty)
            totalCycles += miss_penalty + 2;
          else
            totalCycles += miss_penalty;

          cache[index][search]->tag = checkedTag;
          cache[index][search]->valid = 1;
          cache[index][search]->dirty = 1;
          missCount_store++;
          break;
        }
      }
    }
  }

  printf("Lines found = %i \n", i);
  printf("Simulation results:\n");

  printf("execution time %ld cycles\n", totalCycles);
  printf("instructions %d\n", instructionsParsed);
  printf("memory accesses %d\n", memAccess);
  printf("overall miss rate %.2f\n", ((double)(missCount_load + missCount_store) / (double)memAccess));
  printf("read miss rate %.2f\n", ((double)(missCount_load) / (double)(missCount_load + hitCount_load)));
  printf("memory cpi %.2f\n", ((double)totalCycles / (double)instructionsParsed) - 1);  //Assume ideal cache hit = 1 cycle
  printf("total cpi %.2f\n", (double)totalCycles / (double)instructionsParsed); //TOTAL CPI
  printf("avg memory access time %.2f\n", 1.0 + (((double)(missCount_load + missCount_store) / memAccess) * miss_penalty));
  printf("load_misses %d\n", missCount_load);
  printf("store_misses %d\n", missCount_store);
  printf("load_hits %d\n", hitCount_load);
  printf("store_hits %d\n", hitCount_store);

  

  return 0;
}
