#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <netinet/in.h>
#include <math.h>

int associativity = 1;    // Associativity of cache  1 for now bc direct map
int blocksize_bytes = 16;   //4 words for a block    // Cache Block size in bytes
int cachesize_kb = 16;     //around 1000 words     // Cache size in KB
int miss_penalty = 30; //can be same for now
//hardcoded for now....


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


  bool cache [2^10][61] = {0}; //2^10 rows, 61 columns
//might need another bit for the dirty bit
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
	i++;
	total_inst = total_inst + icount;

	if (loadstore = 0){ //this is a load
	    //locate the appropriate cache block
	   //determine if tag matches tag in address AND valid bit is on
	   //pull data if correct, else, go to memory and wait
	}
	else if (loadstore = 1) //this is a store

    }

  printf("all done\n");
  printf("total instructions: %ld \n", total_inst);
  printf("memory access: %ld \n", i); //count the lines
  return 0;

  printf("Lines found = %ld \n",i);
  printf("Simulation results:\n");

}
