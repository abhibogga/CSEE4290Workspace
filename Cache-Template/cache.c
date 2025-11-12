#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <netinet/in.h>
#include <math.h>

int associativity = 1;    // Associativity of cache  1 for now bc direct map
int blocksize_bytes = 4;   //make it a word for simple example    // Cache Block size in bytes
int cachesize_kb = 4;     //around 1000 words     // Cache size in KB
int miss_penalty = 30; //can be same for now

void
print_usage () //I have a feeling this isn't being used rn
{
  printf ("Usage: gunzip2 -c <tracefile> | ./cache -a <assoc> -l <blksz> -s <size> -mp <mispen>\n");
  printf ("  <tracefile>: The memory trace file\n");
  printf ("  -a <assoc>: The associativity of the cache\n");
  printf ("  -l <blksz>: The blocksize (in bytes) of the cache\n");
  printf ("  -s <size>: The size (in KB) of the cache\n");
  printf ("  -mp <mispen>: The miss penalty (in cycles) of a miss\n");
  exit (0);
}

int main(int argc, char * argv []) {

//argc = argument count. If default, argc = 1 because only program object cache.out is sent through to program
//argv = argument value. If default, argc[0] = cache.out, this is the only argument
//one can pass other arguments like custom cache size, miss penalty, association, etc

  long address;
  int loadstore, icount;
  char marker;

  long i = 0;
  int j = 1;
  long total_inst = 0;
  // Process the command line arguments
  while (j < argc) { //if j<argc that means 1<argc that means this while loop
//doesn't occur in the default case, where argc = 1
    if (strcmp ("-a", argv [j]) == 0) {
      j++;
      if (j >= argc)
        print_usage ();
      associativity = atoi (argv [j]);
      j++;
    } else if (strcmp ("-l", argv [j]) == 0) {
      j++;
      if (j >= argc)
        print_usage ();
      blocksize_bytes = atoi (argv [j]);
      j++;
    } else if (strcmp ("-s", argv [j]) == 0) {
      j++;
      if (j >= argc)
        print_usage ();
      cachesize_kb = atoi (argv [j]);
      j++;
    } else if (strcmp ("-mp", argv [j]) == 0) {
      j++;
      if (j >= argc)
        print_usage ();
      miss_penalty = atoi (argv [j]);
      j++;
    } else {
      print_usage ();
    }
  }

  // print out cache configuration
  printf("Cache parameters:\n"); //these values below were hard coded in the code in the beginning
  printf ("Cache Size (KB)\t\t\t%d\n", cachesize_kb);
  printf ("Cache Associativity\t\t%d\n", associativity);
  printf ("Cache Block Size (bytes)\t%d\n", blocksize_bytes);
  printf ("Miss penalty (cyc)\t\t%d\n",miss_penalty);
  printf ("\n");

  while (scanf("%c %d %lx %d\n",&marker,&loadstore,&address,&icount) != EOF) {
    // Code to print out just the first 10 addresses.  You'll want to delete
    // this part once you get things going.
    if(i<10){//there should be less than 6 million instructions right?
//	printf("\t%c %d %lx %d\n",marker, loadstore, address, icount);
//don't print every instruction lmao
	i++;
	total_inst = total_inst + icount;
    }
    else{
	printf("all done\n");
	printf("total instructions: %ld", total_inst);
	return 0;
   }

    //here is where you will want to process your memory accesses

  }
  // Here is where you want to print out stats
  printf("Lines found = %ld \n",i);
  printf("Simulation results:\n");
  //  Use your simulator to output the following statistics.  The 
  //  print statements are provided, just replace the question marks with
  //  your calcuations.
  
  /*
  printf("\texecution time %ld cycles\n", ?);
  printf("\tinstructions %ld\n", ?);
  printf("\tmemory accesses %ld\n", ?);
  printf("\toverall miss rate %.2f\n", ? );
  printf("\tread miss rate %.2f\n", ? );
  printf("\tmemory CPI %.2f\n", ?);
  printf("\ttotal CPI %.2f\n", ?);
  printf("\taverage memory access time %.2f cycles\n",  ?);
  printf("dirty evictions %d\n", ?);
  printf("load_misses %d\n", ?);
  printf("store_misses %d\n", ?);
  printf("load_hits %d\n", ?);
  printf("store_hits %d\n", ?);
  */

}
