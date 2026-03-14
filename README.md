Prerequisites
- Go (1.19+)
- Google Chrome / Chromium (Required for headless browser engine)

Installation
1. Clone the Repository
```
git clone https://github.com/your-username/xss-scanner.git
cd xss-scanner
```
2. Setup Modules & Dependencies
```
go mod init xss-scanner
go get github.com/chromedp/chromedp
go get github.com/chromedp/cdproto/page
go get github.com/fatih/color
go mod tidy
```
3. Build the Binary
```
go build -o xss_scanner xss_scanner.go
```

Usage
Run the tool and provide the required paths:
```
./xss_scanner
```
or
```
sudo cp -r xss_scanner /usr/bin
xss_scanner
```

Required Inputs:
- Base URL: Target domain/IP (e.g., https://34.278.22.12/)
- ParamSpider File: Path to your ParamSpider results (ensure FUZZ is present)
- Payload File: Path to your xss.txt file
