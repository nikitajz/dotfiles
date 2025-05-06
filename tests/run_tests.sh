#!/bin/bash
set -euo pipefail

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"

# Source common test functions
source "$SCRIPT_DIR/test_common.sh"

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
    if ! docker run --rm -e NVIDIA=yes -e OPTIONAL=yes -e DOTF=yes "dotfiles-test"; then
        log_error "Comprehensive test failed"
        docker rmi "dotfiles-test" >/dev/null 2>&1 || true
        return 1
    fi
    
    log_success "Comprehensive Docker test passed"
    docker rmi "dotfiles-test" >/dev/null 2>&1 || true
    return 0
}

# Function to run Docker-based tests
run_docker_tests() {
    log_section "Running Docker-based Tests"
    
    # Verify Docker is available
    if ! assert_docker_available; then
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
MODE="local"
while [[ $# -gt 0 ]]; do
    case $1 in
        --docker)
            MODE="docker"
            shift
            ;;
        --all)
            MODE="all"
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Usage: $0 [--docker|--all]"
            exit 1
            ;;
    esac
done

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