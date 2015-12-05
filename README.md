# SnapCrawl - crawl a website and take screenshots

SnapCrawl is a command line utility for crawling a website and saving
screenshots.

## Features

- Crawls a website to any given depth and save screenshots
- Can capture the full length of the page
- Can use a specific resolution for screenshots
- Skips capturing if the screenshot was already saved recently
- Uses local caching to avoid expensive crawl operations if not needed
- Reports broken links

## Install

	$ gem install snapcrawl

## Usage

	$ snapcrawl --help

    Snapcrawl
    
    Usage:
      snapcrawl go <url> [options]
      snapcrawl -h | --help 
      snapcrawl -v | --version
    
    Options:
      -f --folder <path>     Where to save screenshots [default: snaps]
      -a --age <n>           Number of seconds to consider screenshots fresh
                             [default: 86400]
      -d --depth <n>         Number of levels to crawl [default: 1]
      -h --help              Show this screen
      -v --version           Show version

---