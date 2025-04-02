# BeeGFS Parallel File System
BeeGFS (formerly FhGFS) is the leading parallel cluster file system,
developed with a strong focus on performance and designed for very easy
installation and management.
If I/O intensive workloads are your problem, BeeGFS is the solution.

Homepage: https://www.beegfs.io

# Build Instructions

## Prerequisites
Before building BeeGFS, install the following dependency packages:

### Red Hat / CentOS
```
$ yum install libuuid-devel libibverbs-devel librdmacm-devel libattr-devel redhat-rpm-config \
  rpm-build xfsprogs-devel zlib-devel gcc-c++ gcc \
  redhat-lsb-core java-devel unzip libcurl-devel elfutils-libelf-devel kernel-devel \
  libblkid-devel libnl3-devel
```

The `elfutils-libelf-devel` and `kernel-devel` packages can be omitted if you don't intend to
build the client module.

On RHEL releases older than 8, the additional `devtoolset-7` package is also required,
which provides a newer compiler version. The installation steps are outlined here.
Please consult the documentation of your distribution for details.

  1. Install a package with repository for your system:
   - On CentOS, install package centos-release-scl available in CentOS repository:
     ```
     $ sudo yum install centos-release-scl
     ```
   - On RHEL, enable RHSCL repository for you system:
     ```
     $ sudo yum-config-manager --enable rhel-server-rhscl-7-rpms
     ```
  2. Install the collection:
     ```
     $ sudo yum install devtoolset-7
     ```

  3. Start using software collections:
     ```
     $ scl enable devtoolset-7 bash
     ```
  4. Follow the instructions below to build BeeGFS.

### Debian and Ubuntu

#### Option 1: Semi-automatic installation of build dependencies

Install required utilities:
```
$ apt install --no-install-recommends devscripts equivs
```
Automatically install build dependencies:
```
$ mk-build-deps --install debian/control
```

#### Option 2: Manual installation of build dependencies

Run this command to install the required packages:
```
$ sudo apt install build-essential autoconf automake pkg-config devscripts debhelper \
  libtool libattr1-dev xfslibs-dev lsb-release kmod librdmacm-dev libibverbs-dev \
  default-jdk zlib1g-dev libssl-dev libcurl4-openssl-dev libblkid-dev uuid-dev \
  libnl-3-200 libnl-3-dev libnl-genl-3-200 libnl-route-3-200 libnl-route-3-dev dh-dkms
```
Note: If you have an older Debian system you might have to install the `module-init-tools`
package instead of `kmod`.  You also have the choice between the openssl, nss, or gnutls version
of `libcurl-dev`. Choose the one you prefer. On Debian versions older than 12, replace `dh-dkms`
by `dkms`.

## Building Packages

### For development systems

BeeGFS comes with a Makefile capable of building packages for the system on which it is executed.
These include all services, the client module and utilities.

To build RPM packages, run
```
 $ make package-rpm PACKAGE_DIR=packages
```
You may also enable parallel execution with
```
 $ make package-rpm PACKAGE_DIR=packages RPMBUILD_OPTS="-D 'MAKE_CONCURRENCY <n>'"
```
where `<n>` is the number of concurrent processes.

For DEB packages use this command:
```
 $ make package-deb PACKAGE_DIR=packages
```
Or start with `<n>` jobs running in parallel:
```
 $ make package-deb PACKAGE_DIR=packages DEBUILD_OPTS="-j<n>"
```

This will generate individual packages for each service (management, meta-data, storage)
as well as the client kernel module and administration tools.

The above examples use `packages` as the output folder for packages, which must not exist
and will be created during the build process.
You may specify any other non-existent directory instead.

Note, however, that having `PACKAGE_DIR` on a NFS or similar network share may slow down
the build process significantly.

### For production systems, or from source snapshots

By default the packaging system generates version numbers suitable only for development
packages. Packages intended for installation on production systems must be built differently.
All instructions to build development packages (as given above) apply, but additionally the
package version must be explicitly set. This is done by passing `BEEGFS_VERSION=<version>`
in the make command line, e.g.
```
 $ make package-deb PACKAGE_DIR=packages DEBUILD_OPTS="-j<n>" BEEGFS_VERSION=7.1.4-local1
```

Setting the version explicitly is required to generate packages that can be easily upgraded
with the system package manager.


## Building without packaging
To build the complete project without generating any packages,
simply run
```
$ make
```

The sub-projects have individual make targets, for example `storage-all`,
`meta-all`, etc.

To speed things you can use the `-j` option of `make`.
Additionally, the build system supports `distcc`:
```
$ make DISTCC=distcc
```

# Setup Instructions
A detailed guide on how to configure a BeeGFS system can be found in
the BeeGFS wiki: https://www.beegfs.io/wiki/

# Share your thoughts
Of course, we are curious about what you are doing with the BeeGFS sources, so
don't forget to drop us a note...

# BeeGFS Docker Development and Testing Environment

This repository contains a Docker-based environment for building, testing, and evaluating the BeeGFS (Bee GNU/Linux File System) parallel file system, designed for high-performance computing environments.

## Overview

The containerized setup enables you to build, test, and run BeeGFS components without affecting your host system. It includes comprehensive testing tools to evaluate performance and verify filesystem operation.

## Features

- Complete development environment with all required dependencies
- Separate containerized server and client components
- Automated setup of management, metadata, and storage services
- Performance testing tools (fio, bonnie++, iotop, etc.)
- Monitoring and statistics collection utilities
- Pre-configured benchmarking scripts

## System Architecture

This environment consists of the following components:

1. **Server Container (`beegfs-dev`)**
   - Runs the core BeeGFS services:
     - Management service (port 8008)
     - Metadata service (port 8003)
     - Storage service (port 8005)
   - Provides storage targets for file distribution
   - Built from the `Dockerfile` in this repository

2. **Client Container (`beegfs-client`)**
   - Mounts the BeeGFS filesystem
   - Provides testing and benchmarking tools
   - Built from the `Dockerfile.client` in this repository

## Quick Start

### 1. Starting the BeeGFS Server

```bash
# Build and start the BeeGFS development container
sudo ./beegfs-dev.sh start
```

### 2. Starting the BeeGFS Client

```bash
# Build and start the BeeGFS client container
sudo ./start-client.sh
```

### 3. Running Performance Tests

```bash
# Run comprehensive performance tests
sudo ./beegfs-performance-test.sh --all

# Or run a quick benchmark
sudo ./quick-beegfs-benchmark.sh
```

## Setup Instructions

### Prerequisites

- Docker installed on your system
- sudo privileges
- At least 4GB RAM and 10GB disk space available

### Server Setup

1. **Clone this repository**:
   ```bash
   git clone https://github.com/yourusername/beegfs-docker.git
   cd beegfs-docker
   ```

2. **Start the BeeGFS server**:
   ```bash
   sudo ./beegfs-dev.sh start
   ```

3. **Verify server services are running**:
   ```bash
   sudo ./beegfs-dev.sh status
   ```

### Client Setup

1. **Start the client container**:
   ```bash
   sudo ./start-client.sh
   ```

2. **Verify the client mount**:
   ```bash
   sudo ls /tmp/beegfs_client_mount
   ```

## Available Scripts

### `beegfs-dev.sh`

Management script for the BeeGFS server container:

```bash
# Commands:
./beegfs-dev.sh start          # Start the development environment
./beegfs-dev.sh stop           # Stop the development environment
./beegfs-dev.sh build          # Build all BeeGFS components
./beegfs-dev.sh build [comp]   # Build a specific component (mgmtd, meta, storage, etc.)
./beegfs-dev.sh restart [svc]  # Restart a specific service
./beegfs-dev.sh logs [svc]     # Show logs for a specific service
./beegfs-dev.sh shell          # Get a shell in the development container
./beegfs-dev.sh status         # Check status of BeeGFS services
```

### `start-client.sh`

Script to build and run the BeeGFS client container:

```bash
# Usage:
./start-client.sh
```

This script:
- Builds the client container using `Dockerfile.client`
- Stops any existing client container
- Creates the mount directory on the host
- Starts the client container with proper network and volume mounts
- Waits for the BeeGFS client to initialize
- Provides instructions for performance testing

### `beegfs-performance-test.sh`

Comprehensive performance testing script:

```bash
# Usage:
./beegfs-performance-test.sh [OPTIONS]

# Options:
-c, --create      # Create test files on BeeGFS mount
-i, --io          # Run I/O performance tests
-s, --stats       # Collect system statistics
-t, --targets     # Check storage targets
-a, --all         # Run all tests
-h, --help        # Display help message
```

### `quick-beegfs-benchmark.sh`

Simplified benchmark script for quick tests:

```bash
# Usage:
./quick-beegfs-benchmark.sh
```

This script:
- Verifies the BeeGFS client container is running
- Checks that the BeeGFS mount point exists
- Runs throughput tests (write/read)
- Performs metadata performance tests (create/list/remove files)
- Displays summary results

## Performance Testing

### Running Full Performance Tests

```bash
sudo ./beegfs-performance-test.sh --all
```

This will:
1. Create test files of various sizes
2. Check file chunk distribution
3. Run sequential and random I/O performance tests
4. Collect system statistics
5. Check storage targets status

### Quick Benchmarking

```bash
sudo ./quick-beegfs-benchmark.sh
```

This simplified benchmark focuses on:
1. Basic write/read throughput
2. Metadata operations performance
3. Simple system verification

### Viewing Results

Performance reports and statistics are available in:
- `beegfs-performance-report.txt` - Comprehensive performance report
- `beegfs-summary.txt` - Brief summary of configuration and tests

## Container Access

### Accessing the Server Container

```bash
sudo docker exec -it beegfs-dev bash
```

### Accessing the Client Container

```bash
sudo docker exec -it beegfs-client bash
```

### Accessing the BeeGFS Mount

On the host:
```bash
sudo ls /tmp/beegfs_client_mount
```

In the client container:
```bash
ls /mnt/beegfs
```

## Docker Compose Configuration

The project includes a `docker-compose.yml` file that defines:

1. **beegfs-dev**: Main development container with services
2. **beegfs-client**: Client container for mounting and testing

### Volumes:
- `beegfs-conf`: Configuration files
- `beegfs-data`: Storage for BeeGFS data
- `beegfs-client-data`: Mount point for the client

### Network:
- `beegfs-net`: Dedicated network for BeeGFS communication

## Customization

### Modifying Server Configuration

Edit the configuration files in the `beegfs-dev` container:
```bash
sudo docker exec -it beegfs-dev vi /beegfs_conf/beegfs-mgmtd.conf
sudo docker exec -it beegfs-dev vi /beegfs_conf/beegfs-meta.conf
sudo docker exec -it beegfs-dev vi /beegfs_conf/beegfs-storage.conf
```

### Modifying Client Configuration

Edit the client configuration file:
```bash
sudo docker exec -it beegfs-client vi /etc/beegfs/beegfs-client.conf
```

## Troubleshooting

### Common Issues

1. **Client can't connect to server**:
   - Check that both containers are on the same network:
     ```bash
     sudo docker network inspect beegfs-net
     ```
   - Verify server services are running:
     ```bash
     sudo ./beegfs-dev.sh status
     ```

2. **Mount fails**:
   - Check client logs:
     ```bash
     sudo docker logs beegfs-client
     ```
   - Try restarting the client:
     ```bash
     sudo docker restart beegfs-client
     ```

3. **Performance issues**:
   - Run the performance statistics collector:
     ```bash
     sudo docker exec -it beegfs-client bash -c 'source /usr/local/bin/beegfs-test.sh && collect_stats'
     ```

## License

This Docker environment is provided under the same license as BeeGFS. See the LICENSE.txt file for details.

## Resources

- [BeeGFS Official Website](https://www.beegfs.io)
- [BeeGFS Documentation](https://doc.beegfs.io/latest/)
- [BeeGFS GitHub Repository](https://github.com/ThinkParQ/beegfs)
