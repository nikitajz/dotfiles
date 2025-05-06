#!/bin/bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Global test status
TEST_FAILURES=0

# Logging functions
log_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    ((TEST_FAILURES++))
}

log_section() {
    echo -e "\n${YELLOW}📋 $1${NC}"
    echo -e "${YELLOW}$(printf '=%.0s' {1..50})${NC}\n"
}

# Core assertion functions
assert_true() {
    local message=$1
    local condition=$2
    
    if eval "$condition"; then
        log_success "$message"
        return 0
    else
        log_error "$message"
        return 1
    fi
}

assert_command() {
    local cmd=$1
    assert_true "Command '$cmd' is available" "command -v $cmd >/dev/null 2>&1"
}

assert_directory() {
    local dir=$1
    assert_true "Directory '$dir' exists" "[ -d '$dir' ]"
}

assert_file() {
    local file=$1
    assert_true "File '$file' exists" "[ -f '$file' ]"
}

assert_executable() {
    local file=$1
    assert_true "File '$file' is executable" "[ -x '$file' ]"
}

assert_symlink() {
    local file=$1
    assert_true "File '$file' is symlinked" "[ -L '$file' ]"
}

assert_contains() {
    local file=$1
    local pattern=$2
    assert_true "File '$file' contains pattern '$pattern'" "grep -q '$pattern' '$file'"
}

assert_in_path() {
    local dir=$1
    assert_true "'$dir' is in PATH" "[[ ':$PATH:' == *':$dir:'* ]]"
}

# Test grouping
start_test_group() {
    local name=$1
    log_section "$name"
    TEST_FAILURES=0
}

end_test_group() {
    local name=$1
    if [ $TEST_FAILURES -eq 0 ]; then
        log_success "All tests in '$name' passed"
    else
        log_error "$TEST_FAILURES test(s) failed in '$name'"
    fi
    return $TEST_FAILURES
}

# Docker test helpers
assert_docker_available() {
    if ! command -v docker >/dev/null 2>&1; then
        log_error "Docker is not installed"
        return 1
    fi
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon is not running"
        return 1
    fi
    log_success "Docker is available and running"
    return 0
}

# Error handling
handle_error() {
    log_error "Error on line $1"
    exit 1
}

trap 'handle_error $LINENO' ERR 