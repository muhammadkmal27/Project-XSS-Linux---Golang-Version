#!/bin/bash

# XSS Scanner - Build Script for Multiple Platforms
# Usage: ./build.sh

echo "================================"
echo "XSS Scanner - Golang Build Tool"
echo "================================"
echo ""

# Get Go version
GO_VERSION=$(go version | awk '{print $3}')
echo "[i] Go version: $GO_VERSION"
echo ""

# Create build output directory
mkdir -p builds

echo "[i] Building for different platforms..."
echo ""

# Function to build
build_platform() {
    local os=$1
    local arch=$2
    local output=$3
    
    echo "[*] Building $os/$arch..."
    GOOS=$os GOARCH=$arch go build -o "builds/$output" xss_scanner.go
    
    if [ $? -eq 0 ]; then
        filesize=$(ls -lh "builds/$output" | awk '{print $5}')
        echo "    ✓ Done: builds/$output ($filesize)"
    else
        echo "    ✗ Failed!"
    fi
}

# Build for Linux
echo "[*] Linux Builds:"
build_platform "linux" "amd64" "xss_scanner_linux_x64"
build_platform "linux" "arm64" "xss_scanner_linux_arm64"
echo ""

# Build for Windows
echo "[*] Windows Builds:"
build_platform "windows" "amd64" "xss_scanner_windows_x64.exe"
build_platform "windows" "arm64" "xss_scanner_windows_arm64.exe"
echo ""

# Build for macOS
echo "[*] macOS Builds:"
build_platform "darwin" "amd64" "xss_scanner_macos_intel"
build_platform "darwin" "arm64" "xss_scanner_macos_arm64"
echo ""

echo "================================"
echo "[+] Build complete!"
echo "[i] All binaries in ./builds/"
echo "================================"
echo ""
echo "Next steps:"
echo "1. chmod +x builds/xss_scanner_linux_* (on Linux)"
echo "2. Copy to target system or add to PATH"
echo "3. Run: ./xss_scanner_linux_x64"
