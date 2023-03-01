require 'sinatra/base'

class Public < Sinatra::Base
  get '/' do
    "<a href='/page'>Hello World</a><br>" \
      "<a href='/errors'>Errors</a>"
  end

  get '/page' do
    <<~HTML
      Some Page with links:<br>
      <a href='/broken'>Broken Link</a><br>
      <a href='/ok'>Valid Link</a><br>
      <a href='https://www.example.com/'>External</a><br>
      <a href='https://www.\u0105.com/'>Unicode</a><br>
      <a href='\\problematic : link'>problematic link</a><br>
      <a name='anchor-without-href'>without href</a><br>
      <a href='#id'>with hash only href</a><br>
    HTML
  end

  get '/errors' do
    <<~HTML
      <a href='/secret'>Basic Auth Dialog Link</a><br>
      <a href='/500'>500 Link</a><br>
      <a href='/401'>401 Link</a><br>
      <a href='/403'>403 Link</a><br>
    HTML
  end

  get '/ok' do
    "<a href='/deeper/ok'>Depper Valid Link</a><br>OK"
  end

  get '/deeper/ok' do
    'ALSO OK'
  end

  get '/selector' do
    <<~HTML
      <p>
      Outside section with a long text:
      Where could they be? Close the blast doors! Open the blast doors! Open the
      blast doors! I've been waiting for you, Obi-Wan. We meet again, at last.
      The circle is now complete. When I left you, I was but the learner,
      now I am the master. Only a master of evil, Darth. Your powers are weak,
      old man. You can't win, Darth. If you strike me down, I shall become more
      powerful than you can possibly imagine.
      </p>
      <p class='select-me'>And a small one</p>
    HTML
  end

  get '/filters' do
    <<~HTML
      <a href='/filters/include-me/1'>Included</a><br>
      <a href='/filters/include-me/2'>Included</a><br>
      <a href='/filters/exclude-me/1'>Excluded</a><br>
      <a href='/filters/exclude-me/2'>Excluded</a><br>
    HTML
  end

  get '/filters/include-me/:id' do
    "include-me #{params[:id]}"
  end

  get '/filters/exclude-me/:id' do
    "exclude-me #{params[:id]}"
  end

  get '/500' do
    raise 'server error'
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
  use Rack::Auth::Basic, 'Protected Area' do |username, password|
    username == 'user' && password == 'pass'
  end

  get('/') { 'secret' }
end

run Rack::URLMap.new({
  '/'       => Public,
  '/secret' => Protected,
})
