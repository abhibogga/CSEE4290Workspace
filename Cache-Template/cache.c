#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include <winsock2.h> //For windows compilation
//#include <ws2tcpip.h> //For windows compilation
#include <math.h>

int associativity = 1;    // Associativity of cache
int blocksize_bytes = 16; // Cache Block size in bytes
int cachesize_kb = 16;    // Cache size in KB
int miss_penalty = 30;

void print_usage()
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

  long address;
  int loadstore, icount;
  char marker;

  int i = 0;
  int j = 1;
  // Process the command line arguments
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

  // First we need to make our data structure for our cache simulator

  // This will work as a 2D array - Blocks exist within WAYS and WAYS exist within sets

  int cacheLines = (cachesize_kb * 1024) / blocksize_bytes; // This gives us the amount of cache lines needed for each way
//                 amount of bytes       / blocksize_bytes = #blocks in cache


  int sets = cacheLines / associativity;
  // should only be 1 right now
  struct cacheLine
  {
    int dirty;
    int tag;

    int valid;
  };

  struct cacheLine *cache[sets][associativity];

  // Lets allocate space in memory for this cache:
  for (int k = 0; k < sets; k++)
  {
    for (int l = 0; l < associativity; l++)
    {

      // Allocate space for one integer (or a block)
      cache[k][l] = malloc(sizeof(struct cacheLine));
      cache[k][l]->valid = 0;
      cache[k][l]->dirty = 0;
      cache[k][l]->tag = -1;

      // Check allocation
      if (cache[k][l] == NULL)
      {
        fprintf(stderr, "malloc failed at set %d, way %d\n", k, l);
        exit(1);
      }
    }
  }

  // Now we to work on calculating the index and the tag, we don't really need the offset but we'll calc that as well
  int indexBits = log2(sets);
  int offsetBits = log2(blocksize_bytes);

  int tagBits = 32 - (indexBits + offsetBits);

  printf("indexBits: %d  || offsetBits: %d || tagBits: %d\n", indexBits, offsetBits, tagBits);

  // Stat Vars
  int hitCount_load = 0;
  int missCount_load = 0;
  int hitCount_store = 0;
  int missCount_store = 0;
  long instructionsParsed = 0;
  long memAccess = 0;
 // int executionTime = 0; // this isn't used rn
  long totalCycles = 0;
 // int executionTime = 0;
					  

  // Now lets build our simple LRU eviction data structure
  
  

  while (scanf("%c %d %lx %d\n", &marker, &loadstore, &address, &icount) != EOF)
  {

    /////////////////////////////////////////////////////////////////////////////////////
    // So now we know that our marker, loadstore, address, and instruction count are updated here:

    // In terms of logic distribution, for loads are reads - load from memory and stores will be writes - store into memory
    // When reading all we need to do is read the cache, if it is either a hit or miss, all we do is update the stats

    int index = (address >> offsetBits) & ((1U << indexBits) - 1);

    // With our checked tag, we need to bit mask the top x bits
    int checkedTag = address & (~0U << (32 - tagBits));

    memAccess++;
//	totalCycles+=icount;	abhhi's attempt at total cycles rn			
    instructionsParsed += icount;
					   
    if (loadstore == 0) { //this means we are reading
      // This means all we have to do is look into memory and see if its a hit
      //printf("%d\n", index);

      //First we need to loop through the right set to make sure the tag exists:
      for(int search = 0; search < associativity; search++) {
									
	
      // First we need to loop through the right set to make sure the tag exists:
      for (int search = 0; search < associativity; search++)
      {
        //totalCycles += miss_penalty;
        // Now we look for the tags and make sure they good
        if (cache[index][search]->tag == checkedTag && cache[index][search]->valid == 1)
        {
          hitCount_load++;
          //totalCycles++;
        }
        else
        {

          if (cache[index][search]->valid && cache[index][search]->dirty)
            totalCycles += miss_penalty + 2; // dirty eviction
          else
            totalCycles += miss_penalty; // clean eviction

          cache[index][search]->tag = checkedTag;
          cache[index][search]->valid = 1;
          missCount_load++;
          
        }
      }
    }
    }else { //code for store or write commands
      for (int search = 0; search < associativity; search++)
      {

        // Now we look for the tags and make sure they good
        if (cache[index][search]->tag == checkedTag && cache[index][search]->valid == 1)
        {
		  //totalCycles++;				  
          hitCount_store++;
          cache[index][search]->dirty = 1; 
        }
        else
        {

	   if (cache[index][search]->valid && cache[index][search]->dirty)
            totalCycles += miss_penalty+2; // dirty eviction
        else
            totalCycles += miss_penalty; // clean eviction

          cache[index][search]->tag = checkedTag;
          cache[index][search]->valid = 1; 
          missCount_store++;
        }
      }
    }

    /////////////////////////////////////////////////////////////////////////////////////
  }
  // Here is where you want to print out stats
  printf("Lines found = %i \n", i);
  printf("Simulation results:\n");
  //  Use your simulator to output the following statistics.  The
  //  print statements are provided, just replace the question marks with
  //  your calcuations.

  // printf("\texecution time %ld cycles\n", ?);
  printf("execution time %ld cycles\n", totalCycles);
  printf("instructions %ld\n", instructionsParsed);
  printf("tmemory accesses %ld\n", memAccess);
  printf("overall miss rate %.2f\n", ((double)(missCount_load + missCount_store) / memAccess));
  printf("read miss rate %.2f\n", ((double)(missCount_load) / (missCount_load + hitCount_load)));
  //printf("memory CPI %.2f\n", ?);
  // printf("\ttotal CPI %.2f\n", ?);
  // printf("\taverage memory access time %.2f cycles\n",  ?);
  // printf("dirty evictions %d\n", ?);
  printf("load_misses %d\n", missCount_load);
  printf("store_misses %d\n", missCount_store);
  printf("load_hits %d\n", hitCount_load);
  printf("store_hits %d\n", hitCount_store);

  return 0;
}
