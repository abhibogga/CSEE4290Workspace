#!/bin/bash
# build_run.sh — cleans, builds, and runs your project quickly

# Exit immediately if a command fails
set -e

# Step 1: Clean previous builds
clear
echo "Cleaning previous build..."
make clean

# Step 2: Build the project
echo "Building project..."
make build

# Step 3: Run the compiled program (adjust name if needed)
echo "Running program..."
make run

# (Optional) echo success message
echo "Done!"
