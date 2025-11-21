#!/bin/bash

# -------------------------------
# CONFIGURATION
# -------------------------------
TRACE="swim"   # default trace unless argument is given

if [ $# -ge 1 ]; then
    TRACE="$1"
fi

BLOCK_SIZES=(16 32 64 128)
CACHE_SIZES=(16 32 64 128)

RESULTS_DIR="results"
mkdir -p $RESULTS_DIR

# -------------------------------
# COMPILE
# -------------------------------
echo " Building cache simulator..."
make build

# -------------------------------
# RUN FOR ALL COMBINATIONS
# -------------------------------
echo " Running all configurations for trace: $TRACE"
echo

for BS in "${BLOCK_SIZES[@]}"; do
    for CS in "${CACHE_SIZES[@]}"; do
        
        echo "===================================================="
        echo " Running: BlockSize = $BS bytes | CacheSize = $CS KB "
        echo "===================================================="

        OUTPUT_FILE="$RESULTS_DIR/output_bs${BS}_cs${CS}.txt"

        # Call your Makefile's run target
        gunzip -c traces/$TRACE.trace.gz \
            | ./cache.out -a 8 -l $BS -s $CS -mp 30 \
            | tee "$OUTPUT_FILE"

        echo
    done
done

echo " All simulations complete!"
echo " Results saved in: $RESULTS_DIR/"
