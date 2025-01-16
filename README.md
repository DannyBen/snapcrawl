# Snapcrawl - crawl a website and take screenshots

[![Gem Version](https://badge.fury.io/rb/snapcrawl.svg)](http://badge.fury.io/rb/snapcrawl)
[![Build Status](https://github.com/DannyBen/snapcrawl/workflows/Test/badge.svg)](https://github.com/DannyBen/snapcrawl/actions?query=workflow%3ATest)
[![Code Climate](https://codeclimate.com/github/DannyBen/snapcrawl/badges/gpa.svg)](https://codeclimate.com/github/DannyBen/snapcrawl)

---

Snapcrawl is a command line utility for crawling a website and saving
screenshots. 

---

## :warning: Project Status: On Hold

Snapcrawl relies on two deprecated libraries:  

- [Webshot](https://github.com/nezirz/ruby_webshot) (last updated in December 2019)  
- [PhantomJS](https://github.com/ariya/phantomjs) (last updated around 2020)  

As such, the project is **no longer actively maintained** and is unlikely to
receive updates or bug fixes.  

If you are interested in contributing and have ideas for replacing these
libraries with modern alternatives, you are welcome to propose changes via
pull requests or issues.

---

## Features

- Crawls a website to any given depth and saves screenshots
- Can capture the full length of the page
- Can use a specific resolution for screenshots
- Skips capturing if the screenshot was already saved recently
- Uses local caching to avoid expensive crawl operations if not needed
- Reports broken links

## Install

**Using Docker**

You can run Snapcrawl by using this docker image (which contains all the
necessary prerequisites):

```shell
$ alias snapcrawl='docker run --rm -it --network host --volume "$PWD:/app" dannyben/snapcrawl'
```

For more information on the Docker image, refer to the [docker-snapcrawl][3] repository.

**Using Ruby**

```shell
$ gem install snapcrawl
```

Note that Snapcrawl requires [PhantomJS][1] and [ImageMagick][2].

## Usage

Snapcrawl can be configured either through a configuration file (YAML), or by specifying options in the command line.

```shell
$ snapcrawl
Usage:
  snapcrawl URL [--config FILE] [SETTINGS...]
  snapcrawl -h | --help
  snapcrawl -v | --version
```

The default configuration filename is `snapcrawl.yml`.

Using the `--config` flag will create a template configuration file if it is not present:

```shell
$ snapcrawl example.com --config snapcrawl
```

### Specifying options in the command line

All configuration options can be specified in the command line as `key=value` pairs:

```shell
$ snapcrawl example.com log_level=0 depth=2 width=1024
```

### Sample configuration file

```yaml
# All values below are the default values

# log level (0-4) 0=DEBUG 1=INFO 2=WARN 3=ERROR 4=FATAL
log_level: 1

# log_color (yes, no, auto)
# yes  = always show log color
# no   = never use colors
# auto = only use colors when running in an interactive terminal
log_color: auto

# number of levels to crawl, 0 means capture only the root URL
depth: 1

# screenshot width in pixels
width: 1280

# screenshot height in pixels, 0 means the entire height
height: 0

# number of seconds to consider the page cache and its screenshot fresh
cache_life: 86400

# where to store the HTML page cache
cache_dir: cache

# where to store screenshots
snaps_dir: snaps

# screenshot filename template, where '%{url}' will be replaced with a 
# slug version of the URL (no need to include the .png extension)
name_template: '%{url}'

# urls not matching this regular expression will be ignored
url_whitelist: 

# urls matching this regular expression will be ignored
url_blacklist: 

# take a screenshot of this CSS selector only
css_selector: 

# when true, ignore SSL related errors
skip_ssl_verification: false

# set to any number of seconds to wait for the page to load before taking
# a screenshot, leave empty to not wait at all (only needed for pages with
# animations or other post-load events).
screenshot_delay: 
```

## Contributing / Support
If you experience any issue, have a question or a suggestion, or if you wish
to contribute, feel free to [open an issue][issues].

---

[1]: http://phantomjs.org/download.html
[2]: https://imagemagick.org/script/download.php
[3]: https://github.com/DannyBen/docker-snapcrawl
[issues]: https://github.com/DannyBen/snapcrawl/issues

