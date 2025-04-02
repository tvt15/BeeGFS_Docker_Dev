#!/bin/bash

# BeeGFS Performance Test Script

# Function to display usage information
function display_usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -c, --create      Create test files on BeeGFS mount"
  echo "  -i, --io          Run I/O performance tests"
  echo "  -s, --stats       Collect system statistics"
  echo "  -t, --targets     Check storage targets"
  echo "  -a, --all         Run all tests"
  echo "  -h, --help        Display this help message"
  echo ""
  echo "Example: $0 --all"
  echo "         $0 --create --io"
}

# Function to check if the BeeGFS client container is running
function check_client() {
  if ! sudo docker ps | grep -q beegfs-client; then
    echo "Error: beegfs-client container is not running!"
    echo "Start it with: sudo ./start-client.sh"
    exit 1
  fi
}

# Function to create test files
function create_test_files() {
  echo "=== Creating test files on BeeGFS mount ==="
  sudo docker exec beegfs-client bash -c 'if ! command -v create_test_files &> /dev/null; then echo "Error: create_test_files function not found!"; exit 1; fi; create_test_files /mnt/beegfs'
  echo "=== Test file creation complete ==="
  echo ""
}

# Function to run I/O tests
function run_io_tests() {
  echo "=== Running I/O performance tests ==="
  sudo docker exec beegfs-client bash -c 'if ! command -v run_io_tests &> /dev/null; then echo "Error: run_io_tests function not found!"; exit 1; fi; run_io_tests /mnt/beegfs 512M "BeeGFS Performance Test"'
  echo "=== I/O performance tests complete ==="
  echo ""
}

# Function to collect system statistics
function collect_stats() {
  echo "=== Collecting system statistics ==="
  sudo docker exec beegfs-client bash -c 'if ! command -v collect_stats &> /dev/null; then echo "Error: collect_stats function not found!"; exit 1; fi; collect_stats'
  echo "=== System statistics collection complete ==="
  echo ""
}

# Function to check BeeGFS targets
function check_targets() {
  echo "=== Checking BeeGFS targets ==="
  sudo docker exec beegfs-client bash -c 'if ! command -v check_all_targets &> /dev/null; then echo "Error: check_all_targets function not found!"; exit 1; fi; check_all_targets'
  echo "=== BeeGFS target check complete ==="
  echo ""
}

# Function to check chunks info for created files
function check_file_chunks() {
  local FILE_PATH=$1
  if [[ -z $FILE_PATH ]]; then
    FILE_PATH="/mnt/beegfs/medium.dat"
  fi
  
  echo "=== Checking chunks for $FILE_PATH ==="
  sudo docker exec beegfs-client bash -c "if ! command -v check_chunks &> /dev/null; then echo \"Error: check_chunks function not found!\"; exit 1; fi; check_chunks $FILE_PATH"
  echo "=== Chunk check complete ==="
  echo ""
}

# Function to run all tests
function run_all_tests() {
  create_test_files
  check_file_chunks "/mnt/beegfs/medium.dat"
  run_io_tests
  collect_stats
  check_targets
}

# Parse command line arguments
if [[ $# -eq 0 ]]; then
  display_usage
  exit 0
fi

# Check if client container is running
check_client

# Process options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--create)
      CREATE=true
      shift
      ;;
    -i|--io)
      IO=true
      shift
      ;;
    -s|--stats)
      STATS=true
      shift
      ;;
    -t|--targets)
      TARGETS=true
      shift
      ;;
    -a|--all)
      ALL=true
      shift
      ;;
    -h|--help)
      display_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      display_usage
      exit 1
      ;;
  esac
done

# Execute selected tests
if [[ $ALL == true ]]; then
  run_all_tests
else
  [[ $CREATE == true ]] && create_test_files
  [[ $CREATE == true ]] && check_file_chunks "/mnt/beegfs/medium.dat"
  [[ $IO == true ]] && run_io_tests
  [[ $STATS == true ]] && collect_stats
  [[ $TARGETS == true ]] && check_targets
fi

# Display mount information
echo "=== BeeGFS Mount Information ==="
sudo docker exec beegfs-client df -h /mnt/beegfs
echo ""

exit 0 