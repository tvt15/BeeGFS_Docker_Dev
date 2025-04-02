#!/bin/bash

# Quick BeeGFS Benchmark Script

echo "=== BeeGFS Quick Performance Benchmark ==="
echo "Starting benchmark at $(date)"
echo

# Check if client container is running
if ! sudo docker ps | grep -q beegfs-client; then
  echo "Error: BeeGFS client container is not running."
  echo "Please start the client container first."
  exit 1
fi

# Make sure the mount point exists
sudo docker exec beegfs-client bash -c 'if [ ! -d /mnt/beegfs ]; then echo "Error: BeeGFS not mounted"; exit 1; fi'
if [ $? -ne 0 ]; then
  echo "Error: BeeGFS not properly mounted in the client container."
  exit 1
fi

echo "=== Running write/read throughput test ==="
sudo docker exec -it beegfs-client bash -c '
mkdir -p /mnt/beegfs/benchmark
cd /mnt/beegfs/benchmark

# Create a 1GB test file
echo "Creating 1GB test file..."
dd if=/dev/zero of=testfile bs=1M count=1024 conv=fdatasync status=progress 2>&1
sync

# Read the test file
echo -e "\nReading 1GB test file..."
dd if=testfile of=/dev/null bs=1M status=progress 2>&1
'

echo -e "\n=== Running metadata performance test ==="
sudo docker exec -it beegfs-client bash -c '
cd /mnt/beegfs/benchmark

# Create 1000 small files
echo "Creating 1000 small files..."
time for i in $(seq 1 1000); do touch smallfile_$i; done

# List files
echo -e "\nListing 1000 files..."
time ls -la smallfile_* > /dev/null

# Remove files
echo -e "\nRemoving 1000 files..."
time rm smallfile_*
'

echo -e "\n=== Test Complete ==="
echo "Benchmark finished at $(date)"
echo "See beegfs-performance-report.txt for full performance analysis"
