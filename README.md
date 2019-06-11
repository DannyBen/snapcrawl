Snapcrawl - crawl a website and take screenshots
==================================================

[![Gem Version](https://badge.fury.io/rb/snapcrawl.svg)](http://badge.fury.io/rb/snapcrawl)
[![Code Climate](https://codeclimate.com/github/DannyBen/snapcrawl/badges/gpa.svg)](https://codeclimate.com/github/DannyBen/snapcrawl)

---

Snapcrawl is a command line utility for crawling a website and saving
screenshots. 


Features
--------------------------------------------------

- Crawls a website to any given depth and save screenshots
- Can capture the full length of the page
- Can use a specific resolution for screenshots
- Skips capturing if the screenshot was already saved recently
- Uses local caching to avoid expensive crawl operations if not needed
- Reports broken links


Prerequisites
--------------------------------------------------

Snapcrawl requires [PhantomJS][1] and [ImageMagick][2].


Docker Image
--------------------------------------------------

You can run Snapcrawl by using this docker image (which contains all the
necessary prerequisites):

    $ docker pull dannyben/snapcrawl

Then you can use it like this:

    $ docker run --rm -it dannyben/snapcrawl --help

For more information refer to the [docker-snapcrawl][3] repository.


Install
--------------------------------------------------

	$ gem install snapcrawl


Usage
--------------------------------------------------

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
      -W --width <n>         Screen width in pixels [default: 1280]
      -H --height <n>        Screen height in pixels. Use 0 to capture the full 
                             page [default: 0]
      -s --selector <s>      CSS selector to capture
      -o --only <regex>      Include only URLs that match <regex>
      -h --help              Show this screen
      -v --version           Show version
    
    Examples:
      snapcrawl go example.com
      snapcrawl go example.com -d2 -fscreens
      snapcrawl go example.com -d2 > out.txt 2> err.txt &
      snapcrawl go example.com -W360 -H480
      snapcrawl go example.com --selector "#main-content"
      snapcrawl go example.com --only "products|collections"

---

Notes
--------------------------------------------------

If a URL cannot be found, Snapcrawl will report to stderr. 
You can create a report by running

    $ snapcrawl go example.com 2> err.txt



---

[1]: http://phantomjs.org/download.html
[2]: https://imagemagick.org/script/download.php
[3]: https://github.com/DannyBen/docker-snapcrawl
