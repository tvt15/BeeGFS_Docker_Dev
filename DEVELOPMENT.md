# BeeGFS Development Guide

This document provides information for developers working with the BeeGFS Docker development environment.

## Development Environment

The Docker setup in this repository provides a complete environment for developing, testing, and debugging BeeGFS components without affecting your host system.

## Getting Started

### Prerequisites

- Docker and Docker Compose installed
- Git
- Basic understanding of BeeGFS architecture
- At least 4GB RAM and 10GB disk space available

### Setting Up the Development Environment

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/beegfs-docker.git
   cd beegfs-docker
   ```

2. **Start the development environment**:
   ```bash
   ./beegfs-dev.sh start
   ```

3. **Access the development shell**:
   ```bash
   ./beegfs-dev.sh shell
   ```

## Development Workflow

### Building Components

To build specific BeeGFS components:

```bash
# Build all components
./beegfs-dev.sh build

# Build specific component (mgmtd, meta, storage, helperd, utils, client)
./beegfs-dev.sh build meta
```

### Making Code Changes

1. The source code is mounted from your host into the container, so you can edit files using your preferred editor on the host.

2. After making changes, rebuild the affected component:
   ```bash
   ./beegfs-dev.sh build <component>
   ```

3. Restart the service to apply changes:
   ```bash
   ./beegfs-dev.sh restart <service>
   ```

### Testing Changes

1. **Basic functionality testing**:
   - Start the client container:
     ```bash
     ./start-client.sh
     ```
   - Verify the mount:
     ```bash
     sudo ls /tmp/beegfs_client_mount
     ```
   - Create and manipulate files:
     ```bash
     sudo touch /tmp/beegfs_client_mount/test.txt
     ```

2. **Performance testing**:
   ```bash
   ./beegfs-performance-test.sh --all
   ```

3. **Quick benchmarking**:
   ```bash
   ./quick-beegfs-benchmark.sh
   ```

## Debugging

### Checking Logs

```bash
# View logs for a specific service
./beegfs-dev.sh logs mgmtd
./beegfs-dev.sh logs meta
./beegfs-dev.sh logs storage

# View client logs
sudo docker logs beegfs-client
```

### Using GDB

For debugging with GDB inside the container:

1. Access the development shell:
   ```bash
   ./beegfs-dev.sh shell
   ```

2. Find the process ID:
   ```bash
   ps aux | grep beegfs
   ```

3. Attach GDB:
   ```bash
   gdb attach <pid>
   ```

### Using Valgrind

For memory leak detection and profiling:

1. Access the development shell:
   ```bash
   ./beegfs-dev.sh shell
   ```

2. Run a component with Valgrind:
   ```bash
   valgrind --leak-check=full /beegfs/mgmtd/build/beegfs-mgmtd -f -s /beegfs_conf/beegfs-mgmtd.conf
   ```

## Advanced Development

### Creating Custom Configuration

1. Create custom configuration files:
   ```bash
   sudo docker exec -it beegfs-dev bash
   vi /beegfs_conf/beegfs-mgmtd.conf
   vi /beegfs_conf/beegfs-meta.conf
   vi /beegfs_conf/beegfs-storage.conf
   ```

2. Restart services to apply new configuration:
   ```bash
   ./beegfs-dev.sh restart mgmtd
   ./beegfs-dev.sh restart meta
   ./beegfs-dev.sh restart storage
   ```

### Building Packages

To create release packages:

```bash
# Create DEB packages
./beegfs-dev.sh package deb

# Create RPM packages
./beegfs-dev.sh package rpm
```

## Testing Client Features

To test client features:

1. Start the client container:
   ```bash
   ./start-client.sh
   ```

2. Access the client shell:
   ```bash
   sudo docker exec -it beegfs-client bash
   ```

3. Test file operations:
   ```bash
   cd /mnt/beegfs
   dd if=/dev/urandom of=testfile bs=1M count=100
   ```

4. For performance testing:
   ```bash
   source /usr/local/bin/beegfs-test.sh
   run_io_tests /mnt/beegfs 1G "Test"
   ```

## Network Configuration and Troubleshooting

The BeeGFS services communicate over a dedicated Docker network. If you encounter connectivity issues:

1. Check network configuration:
   ```bash
   sudo docker network inspect beegfs-net
   ```

2. Verify container IP addresses:
   ```bash
   sudo docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' beegfs-dev beegfs-client
   ```

3. Test connectivity:
   ```bash
   sudo docker exec beegfs-client ping -c 2 beegfs-dev
   ```

## Extending the Environment

### Adding Custom Test Scripts

1. Create your test script in the repository root.

2. Make it executable:
   ```bash
   chmod +x your-test-script.sh
   ```

3. For client tests, you can make them available inside the client container:
   ```bash
   sudo docker cp your-test-script.sh beegfs-client:/usr/local/bin/
   ```

### Modifying Client Container

If you need to modify the client container:

1. Edit `Dockerfile.client` to include additional tools or configuration.

2. Rebuild and restart the client:
   ```bash
   sudo docker stop beegfs-client
   sudo docker rm beegfs-client
   ./start-client.sh
   ```

## Best Practices

1. **Version Control**: Keep track of changes to configuration files and test scripts.

2. **Reproducible Tests**: Document test parameters and environment setup.

3. **Performance Baselines**: Establish baseline performance metrics with `beegfs-performance-test.sh` before making changes.

4. **Incremental Testing**: Test one component at a time to isolate issues.

5. **Cleanup**: Use `./beegfs-dev.sh stop` to clean up containers when finished.

## Common Issues and Solutions

### Client Can't Mount BeeGFS

1. Check if all services are running:
   ```bash
   ./beegfs-dev.sh status
   ```

2. Verify connectivity:
   ```bash
   sudo docker exec beegfs-client ping -c 2 beegfs-dev
   ```

3. Check service ports:
   ```bash
   sudo docker exec beegfs-dev netstat -tuln | grep -E '8008|8003|8005'
   ```

### Performance Issues

1. Check system resources:
   ```bash
   sudo docker exec beegfs-client bash -c 'source /usr/local/bin/beegfs-test.sh && collect_stats'
   ```

2. Verify there are no network bottlenecks:
   ```bash
   sudo docker exec beegfs-client iperf3 -c beegfs-dev
   ```

## References

- [BeeGFS Documentation](https://doc.beegfs.io/latest/)
- [BeeGFS GitHub Repository](https://github.com/ThinkParQ/beegfs)
- [Docker Documentation](https://docs.docker.com/) 