module Snapcrawl
  def crawl(url, opts={})
    Crawler.instance.crawl url, opts
  end
end

