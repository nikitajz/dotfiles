#!/bin/bash
set -euo pipefail

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"

# Source common test functions
source "$SCRIPT_DIR/test_common.sh"

# Detect environmental conditions upfront
IN_DOCKER=false
IS_MACOS=false

if [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null || \
   grep -q docker /proc/self/cgroup 2>/dev/null || \
   (command -v systemd-detect-virt >/dev/null && systemd-detect-virt -q --container); then
  IN_DOCKER=true
fi

if [ "$(uname)" = "Darwin" ]; then
  IS_MACOS=true
fi

# Function to run local tests
run_local_tests() {
    log_section "Running Local Installation Tests"
    "$SCRIPT_DIR/test_install.sh"
}

# Function to run a comprehensive Docker test
run_docker_test() {
    log_section "Running Comprehensive Docker Test"
    
    # Build Docker image
    log_info "Building Docker image..."
    if ! docker build -t "dotfiles-test" "$DOTFILES_ROOT"; then
        log_error "Docker build failed"
        return 1
    fi
    
    # Run test with all features enabled
    log_info "Running test with all features enabled..."
    if ! docker run --rm \
        -e HOME=/home/ubuntu \
        -e USER=ubuntu \
        -e NVIDIA=yes \
        -e OPTIONAL=yes \
        -e DOTF=yes \
        -e SHELL=/bin/bash \
        "dotfiles-test" 2>&1; then
        log_error "Comprehensive test failed"
        docker rmi "dotfiles-test" >/dev/null 2>&1 || true
        return 1
    fi
    
    # Clean up
    log_info "Cleaning up..."
    docker rmi "dotfiles-test" >/dev/null 2>&1 || true
    return 0
}

# Function to run Docker-based tests
run_docker_tests() {
    log_section "Running Docker-based Tests"
    
    # Verify Docker is available
    if ! assert_docker_available; then
        # If we're already inside Docker, just run the local tests
        if $IN_DOCKER; then
            log_info "Already inside Docker container, running local tests instead"
            run_local_tests
            return $?
        fi
        return 1
    fi
    
    if ! run_docker_test; then
        log_error "Docker test failed"
        return 1
    fi
    
    log_success "All Docker tests passed"
    return 0
}

# Parse command line arguments
# Set default mode based on environment
if $IN_DOCKER; then
    MODE="local"
elif $IS_MACOS; then
    MODE="docker"
else
    MODE="local"
fi

# Process command line flags (override default mode if specified)
while [[ $# -gt 0 ]]; do
    case $1 in
        --docker)
            MODE="docker"
            shift
            ;;
        --local)
            MODE="local"
            shift
            ;;
        --all)
            MODE="all"
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Usage: $0 [--docker|--local|--all]"
            exit 1
            ;;
    esac
done

# Log the mode being used
log_info "Running in $MODE mode"

# Run tests based on mode
case $MODE in
    "local")
        run_local_tests
        ;;
    "docker")
        run_docker_tests
        ;;
    "all")
        run_local_tests
        run_docker_tests
        ;;
esac

log_success "All tests completed!" 