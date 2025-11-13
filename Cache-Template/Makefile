# Compiler/Debugger options
CC=gcc
DEBUGGER=gdb
CFLAGS=-Wall
# Add the math library here
LIBS=-lm 

# Source and executable names
FILE=cache
EXE=$(FILE).out

# If the first argument is "run"...
ifeq (run,$(firstword $(MAKECMDGOALS)))
  # use the first as argument for gunzip, making sure to set a default of 'art'
  ifeq (,$(word 2, $(MAKECMDGOALS)))
      TRACE := art
  else
    TRACE := $(word 2, $(MAKECMDGOALS))
  endif
  # use the rest as arguments for cachesim
  CACHE_ARGS := $(wordlist 3,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif

build:
    # Added $(LIBS) to the end of this line
	$(CC) $(CFLAGS) $(FILE).c -o $(EXE) $(LIBS)

run: build
	gunzip -c traces/$(TRACE).trace.gz | ./$(EXE) $(CACHE_ARGS)

debug: build
	$(DEBUGGER) $(EXE)

clean:
	rm -rf $(EXE)
