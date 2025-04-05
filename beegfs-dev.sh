#!/bin/bash

# Helper script for BeeGFS development with Docker

set -e

function show_help {
    echo "BeeGFS Development Helper Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start          - Start the development environment"
    echo "  stop           - Stop the development environment"
    echo "  build          - Build all BeeGFS components in the container"
    echo "  build [component] - Build a specific component (mgmtd, meta, storage, helperd, utils)"
    echo "  test           - Run tests for all components"
    echo "  restart [service] - Restart a specific service (mgmtd, meta, storage, helperd)"
    echo "  logs [service] - Show logs for a specific service"
    echo "  shell          - Get a shell in the main development container"
    echo "  status         - Check status of BeeGFS services"
    echo "  package [type] - Create packages (deb or rpm)"
    echo "  clean          - Clean build files"
    echo "  help           - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 build meta"
    echo "  $0 shell"
    echo "  $0 restart mgmtd"
    echo "  $0 package deb"
}

function start_environment {
    echo "Starting BeeGFS development environment..."
    docker-compose up -d
}

function stop_environment {
    echo "Stopping BeeGFS development environment..."
    docker-compose down
}

function build_component {
    if [ -z "$1" ]; then
        echo "Building all BeeGFS components..."
        docker exec -it beegfs-dev bash -c "cd /beegfs && make -j\$(nproc)"
    else
        case "$1" in
            mgmtd|meta|storage|helperd)
                echo "Building BeeGFS $1 component..."
                docker exec -it beegfs-dev bash -c "cd /beegfs && make $1-all"
                ;;
            utils)
                echo "Building BeeGFS utilities..."
                docker exec -it beegfs-dev bash -c "cd /beegfs && make utils"
                ;;
            client)
                echo "Building BeeGFS client module..."
                docker exec -it beegfs-dev bash -c "cd /beegfs && make client"
                ;;
            *)
                echo "Unknown component: $1"
                echo "Valid components: mgmtd, meta, storage, helperd, utils, client"
                exit 1
                ;;
        esac
    fi
}

function run_tests {
    echo "Running BeeGFS tests..."
    docker exec -it beegfs-dev bash -c "cd /beegfs && make test"
}

function restart_service {
    if [ -z "$1" ]; then
        echo "Please specify a service to restart (mgmtd, meta, storage, helperd)"
        exit 1
    fi

    case "$1" in
        mgmtd|meta|storage|helperd)
            echo "Restarting BeeGFS $1 service..."
            docker restart "beegfs-$1"
            ;;
        *)
            echo "Unknown service: $1"
            echo "Valid services: mgmtd, meta, storage, helperd"
            exit 1
            ;;
    esac
}

function show_logs {
    if [ -z "$1" ]; then
        echo "Please specify a service to show logs for (mgmtd, meta, storage, helperd, dev)"
        exit 1
    fi

    case "$1" in
        mgmtd|meta|storage|helperd|dev)
            echo "Showing logs for BeeGFS $1 service..."
            docker logs "beegfs-$1" -f
            ;;
        *)
            echo "Unknown service: $1"
            echo "Valid services: mgmtd, meta, storage, helperd, dev"
            exit 1
            ;;
    esac
}

function get_shell {
    echo "Getting shell in BeeGFS development container..."
    docker exec -it beegfs-dev bash
}

function check_status {
    echo "Checking status of BeeGFS services..."
    docker-compose ps
    
    echo ""
    echo "Checking service status inside container..."
    docker exec -it beegfs-dev bash -c "ps aux | grep beegfs | grep -v grep || echo 'No BeeGFS services running'"
    
    echo ""
    echo "Checking connectivity..."
    docker exec -it beegfs-dev bash -c "if [ -f /beegfs/ctl/build/beegfs-ctl ]; then /beegfs/ctl/build/beegfs-ctl --listnodes --nodetype=all 2>/dev/null || echo 'BeeGFS services not responding'; else echo 'beegfs-ctl not built yet'; fi"
}

function create_packages {
    if [ -z "$1" ]; then
        echo "Please specify a package type (deb or rpm)"
        exit 1
    fi

    case "$1" in
        deb)
            echo "Creating DEB packages..."
            docker exec -it beegfs-dev bash -c "cd /beegfs && make package-deb PACKAGE_DIR=/tmp/beegfs-packages"
            ;;
        rpm)
            echo "Creating RPM packages..."
            docker exec -it beegfs-dev bash -c "cd /beegfs && make package-rpm PACKAGE_DIR=/tmp/beegfs-packages"
            ;;
        *)
            echo "Unknown package type: $1"
            echo "Valid types: deb, rpm"
            exit 1
            ;;
    esac
    
    echo "Packages created in container at /tmp/beegfs-packages"
    echo "To retrieve them, run: sudo docker cp beegfs-dev:/tmp/beegfs-packages ."
}

function clean_build {
    echo "Cleaning BeeGFS build files..."
    docker exec -it beegfs-dev bash -c "cd /beegfs && make clean"
}

# Main script logic
if [ -z "$1" ]; then
    show_help
    exit 0
fi

case "$1" in
    start)
        start_environment
        ;;
    stop)
        stop_environment
        ;;
    build)
        build_component "$2"
        ;;
    test)
        run_tests
        ;;
    restart)
        restart_service "$2"
        ;;
    logs)
        show_logs "$2"
        ;;
    shell)
        get_shell
        ;;
    status)
        check_status
        ;;
    package)
        create_packages "$2"
        ;;
    clean)
        clean_build
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac 