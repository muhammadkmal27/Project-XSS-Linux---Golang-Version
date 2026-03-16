package main

import (
	"bufio"
	"context"
	"fmt"
	"net/url"
	"os"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"github.com/chromedp/cdproto/page"
	"github.com/chromedp/chromedp"
	"github.com/fatih/color"
)

var (
	green  = color.New(color.FgGreen, color.Bold)
	yellow = color.New(color.FgYellow)
	red    = color.New(color.FgRed)
	cyan   = color.New(color.FgCyan)
	white  = color.New(color.FgWhite)
)

type Scanner struct {
	BaseURL      string
	Paths        []string
	Payloads     []string
	Concurrency  int
	Timeout      time.Duration
	FoundCount   int32
	ScannedCount int32
}


func preparePayload(p string) string {
	
	if strings.Contains(p, "%") {
		decoded, _ := url.QueryUnescape(p)
		return url.QueryEscape(decoded)
	}

	return url.QueryEscape(p)
}


func cleanPath(path string) string {
	r := strings.NewReplacer("&amp;", "&", "&amp%3B", "&", "%3B", ";")
	return r.Replace(path)
}

func (s *Scanner) verifyXSS(targetURL string) bool {
	opts := append(chromedp.DefaultExecAllocatorOptions[:],
		chromedp.NoSandbox,
		chromedp.DisableGPU,
		chromedp.Flag("headless", true),
		chromedp.Flag("ignore-certificate-errors", true),
		chromedp.UserAgent("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"),
	)

	allocCtx, cancel := chromedp.NewExecAllocator(context.Background(), opts...)
	defer cancel()
	ctx, cancel := chromedp.NewContext(allocCtx)
	defer cancel()

	ctx, cancel = context.WithTimeout(ctx, s.Timeout)
	defer cancel()

	var fired bool
	var mu sync.Mutex

	chromedp.ListenTarget(ctx, func(ev interface{}) {
		
		if _, ok := ev.(*page.EventJavascriptDialogOpening); ok {
			mu.Lock()
			fired = true
			mu.Unlock()
			go func() {
				chromedp.Run(ctx, page.HandleJavaScriptDialog(true))
			}()
		}
	})

	err := chromedp.Run(ctx,
		chromedp.Navigate(targetURL),
		chromedp.Sleep(2500*time.Millisecond), 
	)

	if err != nil {
		return false
	}

	mu.Lock()
	defer mu.Unlock()
	return fired
}

func (s *Scanner) run() {
	sem := make(chan struct{}, s.Concurrency)
	var wg sync.WaitGroup

	for _, payload := range s.Payloads {
		pClean := preparePayload(payload)

		for _, path := range s.Paths {
			pFixed := cleanPath(path)
			
			targetURL := strings.ReplaceAll(s.BaseURL+pFixed, "FUZZ", pClean)

			wg.Add(1)
			sem <- struct{}{}

			go func(u string) {
				defer wg.Done()
				defer func() { <-sem }()

				current := atomic.AddInt32(&s.ScannedCount, 1)
				fmt.Printf("[%d] Testing: %s\n", current, u)

				if s.verifyXSS(u) {
					fmt.Println(strings.Repeat("-", 70))
					green.Printf("[VULNERABLE] Detected XSS!\nPAYLOAD: %s\nURL: %s\n", payload, u)
					fmt.Println(strings.Repeat("-", 70))
					atomic.AddInt32(&s.FoundCount, 1)
				}
			}(targetURL)
		}
	}
	wg.Wait()
}

func main() {
	cyan.Print(`
###############################################
#        XSS SCANNER GOLANG VERSION           #
#   Supports: Emojis, Obfuscation, & Decays   #
#        -  By Muhammad Akmal Imat  -         #
###############################################
`)

	var bURL, pFile, payFile string
	white.Print("[?] Base URL: ")
	fmt.Scanln(&bURL)
	white.Print("[?] ParamSpider Path: ")
	fmt.Scanln(&pFile)
	white.Print("[?] Payload Path: ")
	fmt.Scanln(&payFile)

	bURL = strings.TrimSuffix(bURL, "/")

	
	var paths []string
	f, err := os.Open(pFile)
	if err != nil {
		red.Println("[!] ParamSpider file not found!")
		return
	}
	fs := bufio.NewScanner(f)
	for fs.Scan() {
		line := fs.Text()
		if strings.Contains(line, "FUZZ") {
			
			u, err := url.Parse(line)
			if err == nil {
				p := u.Path
				if u.RawQuery != "" { p += "?" + u.RawQuery }
				paths = append(paths, p)
			} else {
				
				idx := strings.Index(line, "/default") 
				if idx != -1 { paths = append(paths, line[idx:]) }
			}
		}
	}

	
	var payloads []string
	pf, _ := os.Open(payFile)
	pfs := bufio.NewScanner(pf)
	for pfs.Scan() {
		p := strings.TrimSpace(pfs.Text())
		if p != "" { payloads = append(payloads, p) }
	}

	scanner := &Scanner{
		BaseURL:     bURL,
		Paths:       paths,
		Payloads:    payloads,
		Concurrency: 2, 
		Timeout:     30 * time.Second,
	}

	yellow.Printf("\n[*] Starting an attack on %d targets...\n\n", len(paths)*len(payloads))
	scanner.run()
	
	green.Printf("\n[DONE] Scan completed. Total Vulnerabilities: %d\n", scanner.FoundCount)
}