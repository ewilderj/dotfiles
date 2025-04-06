#!/bin/bash
set -e

# Function to log test results
log_test() {
    if [ $? -eq 0 ]; then
        echo "✅ $1 passed"
    else
        echo "❌ $1 failed"
        exit 1
    fi
}

# Test if required dotfiles exist
test_dotfile_existence() {
    for file in .zshrc .vimrc .gitconfig; do
        if [ -f "$HOME/$file" ]; then
            echo "Found $file"
        else
            echo "Missing $file"
            return 1
        fi
    done
}

# Test if shell is properly configured
test_shell_config() {
    if [ "$SHELL" = "/bin/zsh" ]; then
        return 0
    else
        echo "Shell is not zsh"
        return 1
    fi
}

# Run tests
echo "🔍 Testing dotfile installation..."

echo "Testing dotfile existence..."
test_dotfile_existence
log_test "Dotfile existence"

echo "Testing shell configuration..."
test_shell_config
log_test "Shell configuration"

echo "✨ All tests completed successfully!"