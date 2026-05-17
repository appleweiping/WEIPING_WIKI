# Auto-install script for agent-browser on Windows
# This script checks and installs all required dependencies automatically

Write-Host "ğŸ” Checking agent-browser installation..." -ForegroundColor Cyan

# Define paths
$AB_HOME = "$HOME\Documents\agent-browser"
$AB_BIN = "$AB_HOME\bin\agent-browser.cmd"

# Check if agent-browser binary exists
if (Test-Path $AB_BIN) {
    Write-Host "âœ?agent-browser binary found" -ForegroundColor Green

    # Test if it works
    Set-Location $AB_HOME
    $env:AGENT_BROWSER_HOME = $AB_HOME
    try {
        & $AB_BIN --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "âœ?agent-browser is working correctly" -ForegroundColor Green
            exit 0
        }
    } catch {
        Write-Host "âš ï¸  agent-browser binary exists but not working, rebuilding..." -ForegroundColor Yellow
    }
}

# Check if repository exists
if (-not (Test-Path $AB_HOME)) {
    Write-Host "ğŸ“¦ Cloning agent-browser repository..." -ForegroundColor Cyan
    Set-Location "$HOME\Documents"
    git clone https://github.com/vercel-labs/agent-browser.git
    Set-Location agent-browser
} else {
    Write-Host "âœ?Repository found" -ForegroundColor Green
    Set-Location $AB_HOME
}

# Check Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "â?Node.js not found. Please install Node.js first." -ForegroundColor Red
    Write-Host "Download from: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}
Write-Host "âœ?Node.js found: $(node --version)" -ForegroundColor Green

# Check pnpm
if (-not (Get-Command pnpm -ErrorAction SilentlyContinue)) {
    Write-Host "ğŸ“¦ Installing pnpm..." -ForegroundColor Cyan
    npm install -g pnpm
}
Write-Host "âœ?pnpm found: $(pnpm --version)" -ForegroundColor Green

# Install dependencies
Write-Host "ğŸ“¦ Installing dependencies..." -ForegroundColor Cyan
pnpm install

# Install Playwright Chromium
Write-Host "ğŸ“¦ Installing Playwright Chromium..." -ForegroundColor Cyan
npx playwright install chromium

# Check Rust/Cargo
$cargoPath = "$HOME\.cargo\bin\cargo.exe"
if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    if (Test-Path $cargoPath) {
        Write-Host "âœ?Cargo found in ~/.cargo/bin, adding to PATH" -ForegroundColor Green
        $env:PATH = "$HOME\.cargo\bin;$env:PATH"
    } else {
        Write-Host "â?Rust/Cargo not found. Installing rustup..." -ForegroundColor Yellow
        Write-Host "Downloading rustup installer..." -ForegroundColor Cyan

        # Download and run rustup installer
        $rustupInit = "$env:TEMP\rustup-init.exe"
        Invoke-WebRequest -Uri "https://win.rustup.rs/x86_64" -OutFile $rustupInit

        Write-Host "Running rustup installer (this may take a few minutes)..." -ForegroundColor Cyan
        & $rustupInit -y --default-toolchain stable --profile minimal

        Remove-Item $rustupInit
        $env:PATH = "$HOME\.cargo\bin;$env:PATH"
    }
}

# Ensure cargo is in PATH
$env:PATH = "$HOME\.cargo\bin;$env:PATH"

# Check if default toolchain is set
try {
    $rustupOutput = rustup default 2>&1
    if ($rustupOutput -notmatch "stable") {
        Write-Host "ğŸ“¦ Setting up Rust stable toolchain..." -ForegroundColor Cyan
        rustup default stable
    }
} catch {
    Write-Host "ğŸ“¦ Setting up Rust stable toolchain..." -ForegroundColor Cyan
    rustup default stable
}

$rustVersion = rustc --version
Write-Host "âœ?Rust found: $rustVersion" -ForegroundColor Green

# Build agent-browser
Write-Host "ğŸ”¨ Building agent-browser..." -ForegroundColor Cyan
npm run build:native

# Verify installation
if (Test-Path $AB_BIN) {
    Write-Host "âœ?agent-browser installed successfully!" -ForegroundColor Green
    Write-Host "Binary location: $AB_BIN" -ForegroundColor Cyan
} else {
    Write-Host "â?Installation failed - binary not found" -ForegroundColor Red
    exit 1
}
