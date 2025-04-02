FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies for building BeeGFS
RUN apt-get update &&  apt-get install -y \
    build-essential \
    autoconf \
    automake \
    pkg-config \
    devscripts \
    debhelper \
    libtool \
    libattr1-dev \
    xfslibs-dev \
    lsb-release \
    kmod \
    librdmacm-dev \
    libibverbs-dev \
    default-jdk \
    zlib1g-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libblkid-dev \
    uuid-dev \
    libnl-3-200 \
    libnl-3-dev \
    libnl-genl-3-200 \
    libnl-route-3-200 \
    libnl-route-3-dev \
    dkms \
    git \
    vim \
    nano \
    sudo \
    openssh-server \
    gdb \
    valgrind \
    strace \
    procps \
    iproute2 \
    net-tools \
    iputils-ping \
    netcat \
    telnet \
    netbase \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /beegfs

# Copy a startup script that will be used to initialize the environment
RUN echo '#!/bin/bash\n\
echo "BeeGFS Development Environment"\n\
\n\
# Create directory structure for BeeGFS services\n\
mkdir -p /var/lib/beegfs\n\
mkdir -p /data/mgmt_tgt_mgmt01 /data/meta_01_tgt_0101 /data/stor_01_tgt_101 /data/stor_01_tgt_102\n\
\n\
# Start SSH server\n\
service ssh start\n\
\n\
# If requested, build BeeGFS\n\
if [ "$BUILD_ON_START" = "true" ]; then\n\
  echo "Building BeeGFS..."\n\
  cd /beegfs && make -j$(nproc)\n\
fi\n\
\n\
# Run specified service or keep container running\n\
if [ ! -z "$START_SERVICE" ]; then\n\
  case "$START_SERVICE" in\n\
    "mgmtd")\n\
      echo "Starting BeeGFS Management Service..."\n\
      /beegfs/mgmtd/build/beegfs-mgmtd -f -s /beegfs_conf/beegfs-mgmtd.conf\n\
      ;;\n\
    "meta")\n\
      echo "Starting BeeGFS Metadata Service..."\n\
      /beegfs/meta/build/beegfs-meta -f -s /beegfs_conf/beegfs-meta.conf\n\
      ;;\n\
    "storage")\n\
      echo "Starting BeeGFS Storage Service..."\n\
      /beegfs/storage/build/beegfs-storage -f -s /beegfs_conf/beegfs-storage.conf\n\
      ;;\n\
    "helperd")\n\
      echo "Starting BeeGFS Helper Daemon..."\n\
      /beegfs/helperd/build/beegfs-helperd -f -s /beegfs_conf/beegfs-helperd.conf\n\
      ;;\n\
    "client")\n\
      echo "Starting BeeGFS Client..."\n\
      # This would require the module to be built and loaded\n\
      echo "Client module needs to be built and loaded separately."\n\
      ;;\n\
    "all")\n\
      echo "Starting All BeeGFS Services..."\n\
      /beegfs/mgmtd/build/beegfs-mgmtd -f -s /beegfs_conf/beegfs-mgmtd.conf &\n\
      sleep 2\n\
      /beegfs/meta/build/beegfs-meta -f -s /beegfs_conf/beegfs-meta.conf &\n\
      sleep 2\n\
      /beegfs/storage/build/beegfs-storage -f -s /beegfs_conf/beegfs-storage.conf &\n\
      sleep 2\n\
      /beegfs/helperd/build/beegfs-helperd -f -s /beegfs_conf/beegfs-helperd.conf &\n\
      ;;\n\
    *)\n\
      echo "Unknown service: $START_SERVICE"\n\
      ;;\n\
  esac\n\
fi\n\
\n\
# Keep container running\n\
tail -f /dev/null\n' > /start.sh && \
    chmod +x /start.sh

# Create default configuration directory
RUN mkdir -p /beegfs_conf

# Set up SSH for remote access
RUN mkdir -p /var/run/sshd && \
    echo 'root:beegfs' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Add script to create default configurations
RUN echo '#!/bin/bash\n\
\n\
# Create basic configuration files for BeeGFS services\n\
mkdir -p /beegfs_conf\n\
\n\
# Management service config\n\
cat > /beegfs_conf/beegfs-mgmtd.conf << EOF\n\
storeMgmtdDirectory = /data/mgmt_tgt_mgmt01\n\
connInterfacesList = eth0\n\
connAuthFile = /beegfs_conf/conn_auth\n\
storeAllowFirstRunInit = true\n\
EOF\n\
\n\
# Metadata service config\n\
cat > /beegfs_conf/beegfs-meta.conf << EOF\n\
storeMetaDirectory = /data/meta_01_tgt_0101\n\
sysMgmtdHost = localhost\n\
connInterfacesList = eth0\n\
connAuthFile = /beegfs_conf/conn_auth\n\
storeAllowFirstRunInit = true\n\
EOF\n\
\n\
# Storage service config\n\
cat > /beegfs_conf/beegfs-storage.conf << EOF\n\
storeStorageDirectory = /data/stor_01_tgt_101,/data/stor_01_tgt_102\n\
sysMgmtdHost = localhost\n\
connInterfacesList = eth0\n\
connAuthFile = /beegfs_conf/conn_auth\n\
storeAllowFirstRunInit = true\n\
EOF\n\
\n\
# Helper daemon config\n\
cat > /beegfs_conf/beegfs-helperd.conf << EOF\n\
sysMgmtdHost = localhost\n\
connInterfacesList = eth0\n\
connAuthFile = /beegfs_conf/conn_auth\n\
EOF\n\
\n\
# Create a shared secret for authentication\n\
echo "secret_key_for_development" > /beegfs_conf/conn_auth\n\
chmod 400 /beegfs_conf/conn_auth\n\
\n\
echo "Configuration files created in /beegfs_conf/"\n\
' > /setup-configs.sh && \
    chmod +x /setup-configs.sh && \
    /setup-configs.sh

# Expose ports
# 8008: Management service
# 8003: Metadata service
# 8003: Storage service
# 8006: Helper daemon
# 22: SSH
EXPOSE 22 8008 8003 8004 8005 8006

# Create volumes for:
# - Code mounting from host
# - Configuration files
# - Storage targets
VOLUME ["/beegfs", "/beegfs_conf", "/data"]

# Set environment variables with defaults
ENV BUILD_ON_START=false
ENV START_SERVICE=none

CMD ["/start.sh"] 