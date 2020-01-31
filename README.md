Snapcrawl - crawl a website and take screenshots
==================================================

[![Gem Version](https://badge.fury.io/rb/snapcrawl.svg)](http://badge.fury.io/rb/snapcrawl)
[![Build Status](https://github.com/DannyBen/snapcrawl/workflows/Test/badge.svg)](https://github.com/DannyBen/snapcrawl/actions?query=workflow%3ATest)
[![Code Climate](https://codeclimate.com/github/DannyBen/snapcrawl/badges/gpa.svg)](https://codeclimate.com/github/DannyBen/snapcrawl)

---

Snapcrawl is a command line utility for crawling a website and saving
screenshots. 


Features
--------------------------------------------------

- Crawls a website to any given depth and saves screenshots
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

```
$ docker pull dannyben/snapcrawl
```

Then you can use it like this:

```
$ docker run --rm -it dannyben/snapcrawl --help
```

For more information refer to the [docker-snapcrawl][3] repository.


Install
--------------------------------------------------

```
$ gem install snapcrawl
```


Usage
--------------------------------------------------

```
$ snapcrawl --help

Snapcrawl

Usage:
  snapcrawl URL [options]
  snapcrawl -h | --help 
  snapcrawl -v | --version

Options:
  -f, --folder PATH
    Where to save screenshots [default: snaps]

  -n, --name TEMPLATE
    Filename template. Include the string '%{url}' anywhere in the name to 
    use the captured URL in the filename [default: %{url}]

  -a, --age SECONDS
    Number of seconds to consider screenshots fresh [default: 86400]

  -d, --depth LEVELS
    Number of levels to crawl [default: 1]

  -W, --width PIXELS
    Screen width in pixels [default: 1280]

  -H, --height PIXELS
    Screen height in pixels. Use 0 to capture the full page [default: 0]

  -s, --selector SELECTOR
    CSS selector to capture

  -o, --only REGEX
    Include only URLs that match REGEX

  -h, --help
    Show this screen

  -v, --version
    Show version number

Examples:
  snapcrawl example.com
  snapcrawl example.com -d2 -fscreens
  snapcrawl example.com -d2 > out.txt 2> err.txt &
  snapcrawl example.com -W360 -H480
  snapcrawl example.com --selector "#main-content"
  snapcrawl example.com --only "products|collections"
  snapcrawl example.com --name "screenshot-%{url}"
  snapcrawl example.com --name "`date +%Y%m%d`_%{url}"
```

---

[1]: http://phantomjs.org/download.html
[2]: https://imagemagick.org/script/download.php
[3]: https://github.com/DannyBen/docker-snapcrawl


