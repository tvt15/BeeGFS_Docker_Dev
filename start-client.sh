#!/bin/bash

set -e

echo "Building and starting BeeGFS client container..."

# Build client image
sudo docker build -t beegfs-client:latest -f Dockerfile.client .

# Check if client container is already running
if sudo docker ps | grep -q beegfs-client; then
  echo "Stopping existing client container..."
  sudo docker stop beegfs-client
  sudo docker rm beegfs-client
fi

# Check if the containers are running in the same network
BEEGFS_DEV_NETWORK=$(sudo docker inspect --format='{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' beegfs-dev 2>/dev/null)
if [ -z "$BEEGFS_DEV_NETWORK" ]; then
  echo "Warning: beegfs-dev container not found or not running."
  BEEGFS_DEV_NETWORK="beegfs_beegfs-net"
else
  echo "Using network: $BEEGFS_DEV_NETWORK"
fi

# Create required directories
sudo mkdir -p /tmp/beegfs_client_mount

# Start client container
sudo docker run -d \
  --name beegfs-client \
  --hostname beegfs-client \
  --privileged \
  --network $BEEGFS_DEV_NETWORK \
  -v $(pwd):/beegfs_client:rw \
  -v /tmp/beegfs_client_mount:/mnt/beegfs:rw \
  -p 2223:22 \
  beegfs-client:latest

echo "Client container started."
echo "To access the client container shell: sudo docker exec -it beegfs-client bash"
echo "To view client logs: sudo docker logs -f beegfs-client"
echo "To access the BeeGFS mount on the host: ls -la /tmp/beegfs_client_mount"

# Wait for BeeGFS to initialize
echo "Waiting for BeeGFS client to initialize (30 seconds)..."
sleep 30

# Check if mount is accessible
echo "Checking BeeGFS mount status:"
sudo docker exec beegfs-client df -h /mnt/beegfs

# Provide instructions for performance testing
echo ""
echo "To run performance tests inside the container:"
echo "  sudo docker exec -it beegfs-client bash"
echo "  /usr/local/bin/beegfs-test.sh"
echo ""
echo "Example commands for testing:"
echo "  # Create test files"
echo "  sudo docker exec beegfs-client bash -c 'create_test_files /mnt/beegfs'"
echo ""
echo "  # Check chunks and striping"
echo "  sudo docker exec beegfs-client bash -c 'check_chunks /mnt/beegfs/medium.dat'"
echo ""
echo "  # Run IO tests"
echo "  sudo docker exec beegfs-client bash -c 'run_io_tests /mnt/beegfs 512M \"BeeGFS Test\"'"
echo ""
echo "  # Check targets"
echo "  sudo docker exec beegfs-client bash -c 'check_all_targets'" 