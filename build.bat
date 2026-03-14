@echo off
REM XSS Scanner - Build Script for Windows
REM Requires Go to be installed and in PATH

echo.
echo ================================
echo XSS Scanner - Golang Build Tool
echo ================================
echo.

REM Check if Go is installed
where go >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [!] Go is not installed or not in PATH
    echo [i] Download from: https://golang.org/dl/
    pause
    exit /b 1
)

for /f "tokens=3" %%i in ('go version') do set GO_VERSION=%%i
echo [i] Go version: %GO_VERSION%
echo.

REM Create builds directory
if not exist "builds" mkdir builds

echo [i] Building for different platforms...
echo.

REM Function to build
setlocal enabledelayedexpansion
call :build_platform windows amd64 xss_scanner_windows_x64.exe
call :build_platform windows arm64 xss_scanner_windows_arm64.exe
call :build_platform linux amd64 xss_scanner_linux_x64
call :build_platform linux arm64 xss_scanner_linux_arm64
call :build_platform darwin amd64 xss_scanner_macos_intel
call :build_platform darwin arm64 xss_scanner_macos_arm64

echo.
echo ================================
echo [+] Build complete!
echo [i] All binaries in .\builds\
echo ================================
echo.
echo Next steps:
echo 1. Run: .\builds\xss_scanner_windows_x64.exe
echo 2. For Linux targets, copy xss_scanner_linux_x64 to Linux machine
echo.
pause
exit /b 0

:build_platform
setlocal
set OS=%~1
set ARCH=%~2
set OUTPUT=%~3

echo [*] Building %OS%/%ARCH%...

set GOOS=%OS%
set GOARCH=%ARCH%

go build -o "builds\%OUTPUT%" xss_scanner.go

if %ERRORLEVEL% EQU 0 (
    if exist "builds\%OUTPUT%" (
        for %%F in ("builds\%OUTPUT%") do set SIZE=%%~zF
        echo     [OK] builds\%OUTPUT% (!SIZE! bytes)
    )
) else (
    echo     [FAILED]
)

endlocal
exit /b 0
