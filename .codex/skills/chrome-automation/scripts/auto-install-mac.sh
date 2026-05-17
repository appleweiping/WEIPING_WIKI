#!/bin/bash
# Auto-install script for agent-browser on macOS
# This script checks and installs all required dependencies automatically

set -e

echo "ğŸ” Checking agent-browser installation..."

# Define paths
AB_HOME="$HOME/Documents/agent-browser"
AB_BIN="$AB_HOME/bin/agent-browser"

# Check if agent-browser binary exists
if [ -f "$AB_BIN" ]; then
    echo "âœ?agent-browser binary found"

    # Test if it works
    cd "$AB_HOME"
    if AGENT_BROWSER_HOME="$AB_HOME" "$AB_BIN" --version 2>/dev/null; then
        echo "âœ?agent-browser is working correctly"
        exit 0
    else
        echo "âš ï¸  agent-browser binary exists but not working, rebuilding..."
    fi
fi

# Check if repository exists
if [ ! -d "$AB_HOME" ]; then
    echo "ğŸ“¦ Cloning agent-browser repository..."
    cd "$HOME/Documents"
    git clone https://github.com/vercel-labs/agent-browser.git
    cd agent-browser
else
    echo "âœ?Repository found"
    cd "$AB_HOME"
fi

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "â?Node.js not found. Please install Node.js first."
    exit 1
fi
echo "âœ?Node.js found: $(node --version)"

# Check pnpm
if ! command -v pnpm &> /dev/null; then
    echo "ğŸ“¦ Installing pnpm..."
    npm install -g pnpm
fi
echo "âœ?pnpm found: $(pnpm --version)"

# Install dependencies
echo "ğŸ“¦ Installing dependencies..."
pnpm install

# Install Playwright Chromium
echo "ğŸ“¦ Installing Playwright Chromium..."
npx playwright install chromium

# Check Rust/Cargo
if ! command -v cargo &> /dev/null; then
    # Check if cargo exists in default location
    if [ -f "$HOME/.cargo/bin/cargo" ]; then
        echo "âœ?Cargo found in ~/.cargo/bin, adding to PATH"
        export PATH="$HOME/.cargo/bin:$PATH"
    else
        echo "â?Rust/Cargo not found. Installing rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
fi

# Ensure cargo is in PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Check if default toolchain is set
if ! rustup default 2>/dev/null | grep -q "stable"; then
    echo "ğŸ“¦ Setting up Rust stable toolchain..."
    rustup default stable
fi
echo "âœ?Rust found: $(rustc --version)"

# Build agent-browser
echo "ğŸ”¨ Building agent-browser..."
npm run build:native

# Verify installation
if [ -f "$AB_BIN" ]; then
    echo "âœ?agent-browser installed successfully!"
    echo "Binary location: $AB_BIN"
else
    echo "â?Installation failed - binary not found"
    exit 1
fi
