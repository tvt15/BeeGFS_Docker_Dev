# BeeGFS Testing Environment Scripts

This document provides detailed information about the scripts available in this repository for working with the BeeGFS Docker development and testing environment.

## Main Scripts

### 1. `beegfs-dev.sh`

This script manages the BeeGFS development container and its services.

#### Usage

```bash
./beegfs-dev.sh [command] [options]
```

#### Commands

| Command | Description |
|---------|-------------|
| `start` | Start the development environment containers |
| `stop` | Stop the development environment containers |
| `build` | Build all BeeGFS components |
| `build [component]` | Build a specific component (mgmtd, meta, storage, helperd, utils, client) |
| `test` | Run tests for all components |
| `restart [service]` | Restart a specific service (mgmtd, meta, storage, helperd) |
| `logs [service]` | Show logs for a specific service |
| `shell` | Get a shell in the main development container |
| `status` | Check status of BeeGFS services |
| `package [type]` | Create packages (deb or rpm) |
| `clean` | Clean build files |
| `help` | Show help message |

#### Example

```bash
# Start the development environment
./beegfs-dev.sh start

# Get a shell in the development container
./beegfs-dev.sh shell

# Check status of services
./beegfs-dev.sh status
```

### 2. `start-client.sh`

This script builds and starts the BeeGFS client container for mounting and testing BeeGFS.

#### Usage

```bash
./start-client.sh
```

#### What it does

1. Builds the client image using Dockerfile.client
2. Stops any existing client container
3. Identifies the network of the beegfs-dev container
4. Creates required directories on the host
5. Starts the client container with proper networking and volume mounts
6. Waits for BeeGFS to initialize
7. Verifies the mount status
8. Provides instructions for performance testing

#### Example

```bash
./start-client.sh
```

### 3. `beegfs-performance-test.sh`

A comprehensive performance testing script for BeeGFS.

#### Usage

```bash
./beegfs-performance-test.sh [OPTIONS]
```

#### Options

| Option | Long Option | Description |
|--------|-------------|-------------|
| `-c` | `--create` | Create test files on BeeGFS mount |
| `-i` | `--io` | Run I/O performance tests |
| `-s` | `--stats` | Collect system statistics |
| `-t` | `--targets` | Check storage targets |
| `-a` | `--all` | Run all tests |
| `-h` | `--help` | Display help message |

#### Functions

- `check_client`: Verifies the client container is running
- `create_test_files`: Creates various test files on the BeeGFS mount
- `run_io_tests`: Runs I/O performance tests using fio
- `collect_stats`: Collects system statistics
- `check_targets`: Checks BeeGFS targets status
- `check_file_chunks`: Examines the chunk distribution for a file
- `run_all_tests`: Runs all tests in sequence

#### Example

```bash
# Run all performance tests
./beegfs-performance-test.sh --all

# Create test files and run I/O tests
./beegfs-performance-test.sh --create --io
```

### 4. `quick-beegfs-benchmark.sh`

A simplified benchmark script for quick testing of BeeGFS performance.

#### Usage

```bash
./quick-beegfs-benchmark.sh
```

#### What it does

1. Verifies the BeeGFS client container is running
2. Checks that the BeeGFS mount point exists in the client container
3. Runs a write/read throughput test creating a 1GB test file
4. Performs metadata performance test (create/list/remove 1000 small files)
5. Displays benchmark results and completion time

#### Example

```bash
./quick-beegfs-benchmark.sh
```

## Internal Scripts

These scripts are used inside the containers for testing and configuration.

### 1. `/usr/local/bin/beegfs-test.sh` (in client container)

Provides various testing functions for BeeGFS performance evaluation.

#### Functions

| Function | Description |
|----------|-------------|
| `run_io_tests` | Runs various I/O tests (sequential/random read/write) using fio |
| `check_chunks` | Checks how files are distributed across storage targets |
| `check_all_targets` | Lists all metadata and storage targets with their state |
| `collect_stats` | Collects system statistics (CPU, memory, disk I/O, network) |
| `create_test_files` | Creates test files of various sizes and a directory structure |

#### Example (from inside client container)

```bash
# Source the script to get access to the functions
source /usr/local/bin/beegfs-test.sh

# Create test files
create_test_files /mnt/beegfs

# Run I/O tests
run_io_tests /mnt/beegfs 1G "Test Label"

# Collect system statistics
collect_stats
```

### 2. `/start.sh` (in client container)

Initialization script for the BeeGFS client container.

#### Functions

| Function | Description |
|----------|-------------|
| `setup_network` | Configures network settings for BeeGFS connectivity |
| `install_beegfs` | Installs and configures BeeGFS client packages |
| `test_connectivity` | Tests connectivity to BeeGFS services |
| `start_beegfs` | Starts BeeGFS client services and mounts the filesystem |

This script runs automatically when the client container starts.

## Output Files

The scripts generate several output files with performance data and configuration information:

### 1. `beegfs-performance-report.txt`

A comprehensive report of BeeGFS performance metrics, including:
- BeeGFS setup summary
- Sequential and random I/O performance
- System resource utilization 
- Storage structure details
- Performance conclusions

### 2. `beegfs-summary.txt`

A brief summary of the BeeGFS configuration:
- Server configuration (ports and services)
- Client configuration
- Connection details
- Resolved issues
- Next steps for full functionality

## Docker Configuration Files

### 1. `Dockerfile`

Defines the BeeGFS development and server container environment.

Key features:
- Ubuntu 22.04 base
- BeeGFS build dependencies
- Development tools
- Directory structure for BeeGFS services
- Configuration files for BeeGFS components

### 2. `Dockerfile.client`

Defines the BeeGFS client container environment.

Key features:
- Ubuntu 22.04 base
- BeeGFS client dependencies
- Performance testing tools (fio, iotop, bonnie++)
- Test scripts for performance evaluation
- Network configuration for connecting to BeeGFS services

### 3. `docker-compose.yml`

Defines the multi-container setup for the complete BeeGFS environment.

Components:
- `beegfs-dev`: Main development container
- `beegfs-mgmtd`: Management service
- `beegfs-meta`: Metadata service
- `beegfs-storage`: Storage service
- `beegfs-helperd`: Helper daemon
- `beegfs-client`: Client for mounting and testing

Volumes:
- `beegfs-conf`: Configuration files
- `beegfs-data`: Storage for BeeGFS data
- `beegfs-client-data`: Mount point for the client

Network:
- `beegfs-net`: Dedicated network for BeeGFS communication 