#!/bin/bash

# Test script for dotfiles installation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$HOME/.local/bin:$PATH"
TEST_LOG="$SCRIPT_DIR/test_results.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
    echo "[INFO] $1" >> "$TEST_LOG"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    echo "[WARN] $1" >> "$TEST_LOG"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[ERROR] $1" >> "$TEST_LOG"
}

# Test function template
run_test() {
    local test_name="$1"
    local test_command="$2"

    echo "Running test: $test_name"
    if (eval "$test_command") >> "$TEST_LOG" 2>&1; then
        log_info "✓ $test_name - PASSED"
        return 0
    else
        log_error "✗ $test_name - FAILED"
        return 1
    fi
}

# Initialize test log
echo "Dotfiles Installation Test Report" > "$TEST_LOG"
echo "Generated: $(date)" >> "$TEST_LOG"
echo "========================================" >> "$TEST_LOG"

log_info "Starting dotfiles installation tests..."

# Test 1: Check if required commands are available
log_info "Testing system requirements..."

for cmd in git stow zsh starship fzf asdf node npm gh gcloud claude codex copilot; do
    run_test "$cmd available" "command -v $cmd >/dev/null 2>&1"
done
run_test "Default shell is zsh" "[ \"\$(getent passwd \"\$USER\" | cut -d: -f7)\" = \"\$(command -v zsh)\" ]"
run_test "ja_JP.UTF-8 locale generated" "locale -a | grep -qi '^ja_JP\\.utf-\\?8\$'"

if command -v docker >/dev/null 2>&1; then
    log_info "✓ docker available (Docker Desktop WSL integration)"
else
    log_warn "docker not found - enable WSL integration in Docker Desktop"
fi

# Test 2: Validate configuration files
log_info "Testing configuration file validity..."

run_test "Install script executable" "test -x $SCRIPT_DIR/install"
run_test "apt packages installed" "sed -e 's/#.*//' -e '/^[[:space:]]*\$/d' $SCRIPT_DIR/apt-packages.txt | xargs dpkg -s >/dev/null"

# Test 3: Check stow symlinks
log_info "Testing stow configurations..."

for package in shell bash zsh git asdf starship; do
    if [ -d "$SCRIPT_DIR/packages/$package" ]; then
        while IFS= read -r src; do
            rel="${src#"$SCRIPT_DIR/packages/$package/"}"
            case "$rel" in *.example) continue ;; esac
            run_test "~/$rel linked" "[ \"\$(readlink -f $HOME/$rel)\" = \"\$(readlink -f $src)\" ]"
        done < <(find "$SCRIPT_DIR/packages/$package" -type f)
    else
        log_warn "Package directory not found: $package"
    fi
done

# Test 4: Validate .tool-versions
log_info "Testing asdf configuration..."

if [ -f "$SCRIPT_DIR/packages/asdf/.tool-versions" ]; then
    while read -r plugin version; do
        if [ -n "$plugin" ] && [ -n "$version" ]; then
            run_test "asdf $plugin $version installed" "asdf list $plugin 2>/dev/null | grep -q \"$version\""
        fi
    done < "$SCRIPT_DIR/packages/asdf/.tool-versions"
else
    log_warn ".tool-versions file not found"
fi

# Test 5: Shell configuration syntax
log_info "Testing shell configurations..."

if [ -f "$SCRIPT_DIR/packages/zsh/.zshrc" ]; then
    run_test "Zsh config syntax" "zsh -n $SCRIPT_DIR/packages/zsh/.zshrc"
    if [ -t 0 ]; then
        run_test "Zsh config loads without errors" "[ -z \"\$(zsh -ic exit 2>&1 >/dev/null)\" ]"
    else
        log_warn "No terminal, skipping zsh load test"
    fi
fi

if [ -f "$SCRIPT_DIR/packages/bash/.bashrc" ]; then
    run_test "Bash config syntax" "bash -n $SCRIPT_DIR/packages/bash/.bashrc"
fi

# Test 6: Git configuration
log_info "Testing git configuration..."

run_test "Git config valid" "git config -f $SCRIPT_DIR/packages/git/.gitconfig --list >/dev/null"
run_test "Git user.name set" "git config --global user.name | grep -qv 'Your Full Name'"

# Test 7: Starship configuration
if [ -f "$SCRIPT_DIR/packages/starship/.config/starship.toml" ]; then
    if command -v starship >/dev/null 2>&1; then
        run_test "Starship config valid" "STARSHIP_CONFIG=$SCRIPT_DIR/packages/starship/.config/starship.toml starship module character >/dev/null"
    else
        log_warn "Starship not installed, skipping configuration test"
    fi
fi

# Summary
echo "" >> "$TEST_LOG"
echo "Test Summary:" >> "$TEST_LOG"
echo "=============" >> "$TEST_LOG"

passed_tests=$(grep -o "PASSED" "$TEST_LOG" | wc -l | tr -d ' ')
failed_tests=$(grep -o "FAILED" "$TEST_LOG" | wc -l | tr -d ' ')
total_tests=$((passed_tests + failed_tests))

log_info "Tests completed: $total_tests total, $passed_tests passed, $failed_tests failed"

if [ "$failed_tests" -eq 0 ]; then
    log_info "All tests passed! ✅"
    exit 0
else
    log_error "Some tests failed. Check $TEST_LOG for details."
    exit 1
fi