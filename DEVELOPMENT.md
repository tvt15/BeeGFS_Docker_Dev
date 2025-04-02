# BeeGFS Development Environment

This guide explains how to use the Docker-based development environment for BeeGFS.

## Overview

The development environment consists of Docker containers that:
1. Mount the BeeGFS source code from your host machine
2. Build the code within the container
3. Run various BeeGFS services
4. Allow you to edit the code on your host and quickly test changes

## Prerequisites

- Docker
- Docker Compose
- Git (for BeeGFS source code)

## Getting Started

### Option 1: All-in-One Container

This option runs a single container with all BeeGFS components:

```bash
# Build and start the development container
docker-compose up -d beegfs-dev

# SSH into the container (password: beegfs)
ssh -p 2222 root@localhost

# Inside the container, build BeeGFS
cd /beegfs
make -j$(nproc)

# Start all BeeGFS services
/beegfs/mgmtd/build/beegfs-mgmtd -f -s /beegfs_conf/beegfs-mgmtd.conf &
sleep 2
/beegfs/meta/build/beegfs-meta -f -s /beegfs_conf/beegfs-meta.conf &
sleep 2
/beegfs/storage/build/beegfs-storage -f -s /beegfs_conf/beegfs-storage.conf &
sleep 2
/beegfs/helperd/build/beegfs-helperd -f -s /beegfs_conf/beegfs-helperd.conf &
```

### Option 2: Multi-Container Setup

This option runs each BeeGFS service in a separate container:

```bash
# Start all containers
docker-compose up -d

# Only build the code (no services started)
docker-compose up -d beegfs-dev

# Start specific services
docker-compose up -d beegfs-mgmtd beegfs-meta
```

## Development Workflow

1. Edit the BeeGFS source code on your host machine
2. Rebuild the specific component you're working on (inside the container):
   ```bash
   cd /beegfs
   make mgmtd-all  # For management daemon
   make meta-all   # For metadata service
   make storage-all # For storage service
   # etc.
   ```
3. Restart the specific service to test your changes
4. Debug issues using the tools provided in the container (gdb, valgrind, etc.)

## Common Tasks

### Building Specific Components

Inside the container:
```bash
# Build a specific component
cd /beegfs
make mgmtd-all    # Management daemon
make meta-all     # Metadata service
make storage-all  # Storage service
make helperd-all  # Helper daemon
make utils        # Utilities (ctl, fsck, etc.)
make client       # Client module (kernel module)
```

### Running Services Manually

Inside the container:
```bash
# Management daemon
/beegfs/mgmtd/build/beegfs-mgmtd -f -s /beegfs_conf/beegfs-mgmtd.conf

# Metadata service
/beegfs/meta/build/beegfs-meta -f -s /beegfs_conf/beegfs-meta.conf

# Storage service
/beegfs/storage/build/beegfs-storage -f -s /beegfs_conf/beegfs-storage.conf

# Helper daemon
/beegfs/helperd/build/beegfs-helperd -f -s /beegfs_conf/beegfs-helperd.conf
```

### Using beegfs-ctl

Inside the container:
```bash
# Check the file system status
/beegfs/ctl/build/beegfs-ctl --listnodes --nodetype=meta
/beegfs/ctl/build/beegfs-ctl --listnodes --nodetype=storage

# Check file system state
/beegfs/ctl/build/beegfs-ctl --getentryinfo /mnt/beegfs

# More beegfs-ctl commands
/beegfs/ctl/build/beegfs-ctl --help
```

### Debugging with GDB

```bash
# Debug the management daemon
gdb --args /beegfs/mgmtd/build/beegfs-mgmtd -f -s /beegfs_conf/beegfs-mgmtd.conf
```

### Profile with Valgrind

```bash
# Profile the metadata service
valgrind --leak-check=full /beegfs/meta/build/beegfs-meta -f -s /beegfs_conf/beegfs-meta.conf
```

## Container File Structure

- `/beegfs` - Mounted BeeGFS source code from host
- `/beegfs_conf` - Configuration files for BeeGFS services
- `/data` - Data directories for BeeGFS storage targets

## Customizing Configuration

Edit the configuration files in the `/beegfs_conf` directory inside the container to customize BeeGFS behavior.

## Testing Changes

1. Make code changes on your host
2. Rebuild inside the container (`make component-all`)
3. Restart the service to test your changes

## Packaging

To create distribution packages:

```bash
# Inside the container
cd /beegfs

# For DEB packages (Ubuntu/Debian)
make package-deb PACKAGE_DIR=/tmp/beegfs-packages

# For RPM packages (CentOS/RHEL)
make package-rpm PACKAGE_DIR=/tmp/beegfs-packages
```

## Troubleshooting

- Check the logs of running services with `docker logs container_name`
- SSH into containers for debugging: `ssh -p 2222 root@localhost` (password: beegfs)
- If services fail to start, check if the ports are already in use on your host machine 