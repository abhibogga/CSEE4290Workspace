//include stuff
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

//set 4 main params
int associativity = 1;
int blocksize_bytes = 16;
int cachesize_kb = 16;
int miss_penalty = 30;

//print usage block for input params
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

//main function
int main(int argc, char *argv[])
{
  //defining parts of each line of the trace
  long address;
  int loadstore, icount;
  char marker;

  //initializing incrementers
  int i = 0;
  int j = 1;

  //replace the 4 params if they were set by user
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

  // print out 4 main cache params
  printf("Cache parameters:\n");
  printf("Cache Size (KB)\t\t\t%d\n", cachesize_kb);
  printf("Cache Associativity\t\t%d\n", associativity);
  printf("Cache Block Size (bytes)\t%d\n", blocksize_bytes);
  printf("Miss penalty (cyc)\t\t%d\n", miss_penalty);
  printf("\n");

  //calculate number of blocks, aka number of lines in the cache
  //each line in cache holds 1 block
  int total_lines = (cachesize_kb * 1024);

  //make one cache line
  struct cache_line {
     int dirty_bit;
     int valid_bit;
     int tag;
     /*we don't need to put data because we don't care about that. only addresses
     we don't need to put index because index simply acts as a pointer.
     Index is not stored in the cache */
  };

  //make cache array
  struct cache_line *cache;
  cache = malloc(total_lines * sizeof(struct cache_line);
//cache = total number of rows x total number of columns

  for (int k = 0; k < total_lines; k++) { //go through each line in trace
     //initialize cache params
     cache[k].dirty_bit = 0;
     cache[k].valid_bit = 0;
     cache[k].tag = -1;
     //come back to put in error print statement if needed

     //set index, offset, tag size
     int index_size = log2(total_lines);
     int offset_size = log2(blocksize_bytes);
     int tag_size = 32 - (index_size + offset_size);

     //set desired statistics
     int ld_hit = 0;
     int ld_miss = 0;
     int st_hit = 0;
     int st_miss = 0;
     long instructionsParsed = 0;
     long memAccess = 0;
     long totalCycle = 0; //COME BACK TO FINISH THIS
			  //CAN'T WE PUT THIS STUFF BEFORE THE FOR LOOP??

     while (scanf("%c %d %lx %d\n", &marker, &loadstore, &address, &icount) != EOF){
	int index = (address >> offset_size) & ((1U << index_size) - 1);
	int checkedTag = address & (~0U << (32 - tagBits));
	memAccess++;
	instructionsParsed += icount;
	if (loadstore == 0){
	   //load functionality here
	   if (cache[index].tag == checkedTag) {
		if (cache[index].dirty_bit == 0 && cache[index].valid_bit == 1){
		    ld_hit++;
		}
		else{
		    ld_miss++;
		}
	   }
	   else{
		ld_miss++;
	   }
	}else {
	   //store functionality here
	    if (cache[index].tag == checkedTag) {
		if (cache[index].dirty_bit == 0 && cache[index].valid_bit == 1){
		    st_hit++;
		}
		else{
		    st_miss++;
		}
	   }
	   else{
		st_miss++;
	   }

	}
     }

    printf("load_misses %d\n", ld_miss);
    printf("store_misses %d\n", st_miss);
    printf("load_hits %d\n", ld_hit);
    printf("store_hits %d\n", st_hit);

    return 0;
  }

