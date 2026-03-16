Prerequisites
- Go (1.19+)
- Google Chrome / Chromium (Required for headless browser engine)

Installation
Clone the Repository
```
go install github.com/muhammadkmal27/imat-xss@latest
```

Usage
After installation, you can move the binary to /usr/bin so you can run it from anywhere without typing the full path:
```
sudo cp $(go env GOPATH)/bin/imat-xss /usr/local/bin/
```

Now, just type the command to start:
```
imat-xss
```

Required Inputs:
- Base URL: Target domain/IP (e.g., https://example.com/ or https://34.278.22.12/)
- ParamSpider File: Path to your ParamSpider results (ensure FUZZ is present)
- Payload File: Path to your xss.txt file
