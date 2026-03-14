# Makefile for XSS Scanner - Golang Edition

.PHONY: help build run clean test install build-all deps

# Default binary name
BINARY_NAME=xss_scanner
BINARY_LINUX=$(BINARY_NAME)_linux
BINARY_WINDOWS=$(BINARY_NAME).exe
BINARY_MACOS=$(BINARY_NAME)_macos

# Go variables
GO=go
GOFLAGS=-v
LDFLAGS=-ldflags "-s -w"

help:
	@echo "XSS Scanner - Golang Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  make help          - Show this help message"
	@echo "  make build         - Build for current platform"
	@echo "  make build-linux   - Build for Linux x64"
	@echo "  make build-windows - Build for Windows x64"
	@echo "  make build-macos   - Build for macOS"
	@echo "  make build-all     - Build for all platforms"
	@echo "  make run           - Build and run scanner"
	@echo "  make clean         - Remove built binaries"
	@echo "  make deps          - Download dependencies"
	@echo "  make test          - Run basic tests"
	@echo ""

deps:
	@echo "[*] Downloading dependencies..."
	$(GO) mod download
	$(GO) mod tidy
	@echo "[+] Dependencies ready"

build: deps
	@echo "[*] Building for current platform..."
	$(GO) build $(GOFLAGS) $(LDFLAGS) -o $(BINARY_NAME) xss_scanner.go
	@echo "[+] Build complete: $(BINARY_NAME)"

build-linux: deps
	@echo "[*] Building for Linux..."
	GOOS=linux GOARCH=amd64 $(GO) build $(LDFLAGS) -o $(BINARY_LINUX) xss_scanner.go
	@echo "[+] Build complete: $(BINARY_LINUX)"

build-linux-arm: deps
	@echo "[*] Building for Linux ARM64..."
	GOOS=linux GOARCH=arm64 $(GO) build $(LDFLAGS) -o $(BINARY_NAME)_linux_arm64 xss_scanner.go
	@echo "[+] Build complete: $(BINARY_NAME)_linux_arm64"

build-windows: deps
	@echo "[*] Building for Windows..."
	GOOS=windows GOARCH=amd64 $(GO) build $(LDFLAGS) -o $(BINARY_WINDOWS) xss_scanner.go
	@echo "[+] Build complete: $(BINARY_WINDOWS)"

build-windows-arm: deps
	@echo "[*] Building for Windows ARM64..."
	GOOS=windows GOARCH=arm64 $(GO) build $(LDFLAGS) -o $(BINARY_NAME)_windows_arm64.exe xss_scanner.go
	@echo "[+] Build complete: $(BINARY_NAME)_windows_arm64.exe"

build-macos: deps
	@echo "[*] Building for macOS..."
	GOOS=darwin GOARCH=amd64 $(GO) build $(LDFLAGS) -o $(BINARY_MACOS)_intel xss_scanner.go
	GOOS=darwin GOARCH=arm64 $(GO) build $(LDFLAGS) -o $(BINARY_MACOS)_arm64 xss_scanner.go
	@echo "[+] Build complete: $(BINARY_MACOS)_intel, $(BINARY_MACOS)_arm64"

build-all: build-linux build-linux-arm build-windows build-windows-arm build-macos
	@echo "[+] All builds complete!"
	@echo ""
	@echo "Binaries:"
	@ls -lh $(BINARY_NAME)_* 2>/dev/null || echo "No binaries found"

run: build
	@echo "[*] Running scanner..."
	./$(BINARY_NAME)

clean:
	@echo "[*] Cleaning up..."
	rm -f $(BINARY_NAME) $(BINARY_LINUX) $(BINARY_WINDOWS) $(BINARY_MACOS)_*
	rm -rf builds/
	@echo "[+] Clean complete"

test:
	@echo "[*] Running basic tests..."
	@if [ -f "$(BINARY_NAME)" ] || [ -f "$(BINARY_NAME).exe" ]; then \
		echo "[+] Binary exists and is executable"; \
	else \
		echo "[!] Binary not found. Run 'make build' first"; \
		exit 1; \
	fi

install: build
	@echo "[*] Installing to /usr/local/bin..."
	@if [ -z "$$SUDO_USER" ]; then \
		cp $(BINARY_NAME) /usr/local/bin/$(BINARY_NAME); \
	else \
		sudo cp $(BINARY_NAME) /usr/local/bin/$(BINARY_NAME); \
	fi
	@echo "[+] Installation complete. Run 'xss_scanner' from anywhere"

format:
	@echo "[*] Formatting code..."
	$(GO) fmt ./...
	@echo "[+] Code formatted"

version:
	@echo "XSS Scanner - Golang Edition"
	@echo "Go version: $(shell $(GO) version)"
	@echo "System: $(shell uname -s)"

info:
	@echo "Build Information:"
	@echo "  Go: $(shell $(GO) version)"
	@echo "  OS: $(shell uname -s)"
	@echo "  Arch: $(shell uname -m)"
	@echo ""
	@echo "File information:"
	@ls -lh xss_scanner.go go.mod 2>/dev/null

.DEFAULT_GOAL := help
