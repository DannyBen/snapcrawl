require 'sinatra'

class Public < Sinatra::Base

  get '/' do
    "<a href='/page'>Hello World</a><br>" +
    "<a href='/errors'>Errors</a>"
  end

  get '/page' do
    "Some Page with links:<br>" + 
    "<a href='/broken'>Broken Link</a><br>" +
    "<a href='/ok'>Valid Link</a><br>" +    
    "<a href='https://www.example.com/'>External</a><br>" +
    "<a href='https://www.\u0105.com/'>Unicode</a><br>" +
    "<a href='\\problematic \: link'>problematic link</a><br>" +
    "<a name='anchor-without-href'>without href</a><br>" +
    "<a href='#id'>with hash only href</a><br>"
  end
  
  get '/errors' do
    "<a href='/secret'>Basic Auth Dialog Link</a><br>" +
    "<a href='/500'>500 Link</a><br>" +
    "<a href='/401'>401 Link</a><br>" +
    "<a href='/403'>403 Link</a><br>"
  end

  get '/ok' do
    "<a href='/deeper/ok'>Depper Valid Link</a><br>" +
    "OK"
  end

  get '/deeper/ok' do
    "ALSO OK"
  end

  get '/selector' do
    "<p>" +
    "Outside section with a long text:" +
    "Where could they be? Close the blast doors! Open the blast doors! Open the blast doors! I've been waiting for you, Obi-Wan. We meet again, at last. The circle is now complete. When I left you, I was but the learner, now I am the master. Only a master of evil, Darth. Your powers are weak, old man. You can't win, Darth. If you strike me down, I shall become more powerful than you can possibly imagine." +
    "The entire starfleet couldn't destroy the whole planet. It'd take a thousand ships with more fire power than I've... There's another ship coming in. Maybe they know what happened. It's an Imperial fighter. It followed us! No. It's a short range fighter. There aren't any bases around here. Where did it come from? It sure is leaving in a big hurry. If they identify us, we're in big trouble. Not if I can help it. Chewie...jam it's transmissions. It'd be as well to let it go. It's too far out of range. Not for long..." +
    "</p>" +
    "<p class='select-me'>And a small one</p>"
  end

  get '/filters' do
    "<a href='/filters/include-me/1'>Included</a><br>" + 
    "<a href='/filters/include-me/2'>Included</a><br>" + 
    "<a href='/filters/exclude-me/1'>Excluded</a><br>" + 
    "<a href='/filters/exclude-me/2'>Excluded</a><br>" 
  end

  get '/filters/include-me/:id' do
    "include-me #{params[:id]}"
  end

  get '/filters/exclude-me/:id' do
    "exclude-me #{params[:id]}"
  end

  get '/500' do
    raise "server error"
  end

  get '/401' do
    status 401
    '401 Unauthorized'
  end

  get '/403' do
    status 403
    '403 Forbidden'
  end
end

class Protected < Sinatra::Base
  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == 'user' && password == 'pass'
  end

  get('/') { "secret" }
end

run Rack::URLMap.new({
  "/" => Public,
  "/secret" => Protected
})
