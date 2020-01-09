require 'sinatra'
require "sinatra/reloader" if development?

set :port, 4567
set :bind, '0.0.0.0'

before do
  @log = params[:log].nil? ? '/dev/null' : params[:log]
end

get '/' do
  "<a href='/page'>Hello World</a>"
end

get '/page' do
  "Some Page with links:<br>" + 
  "<a href='/broken'>Broken Link</a><br>" +
  "<a href='/ok'>Valid Link</a><br>" +
  "<a href='https://www.example.com/'>External</a><br>" +
  "<a href='https://www.\u0105.com/'>Unicode</a><br>" +
  "<a href='\\problmatic \: link'>problematic link</a><br>" +
  "<a name='anchor-without-href'>without href</a><br>" +
  "<a href='#id'>with hash only href</a><br>"
end

get '/ok' do
  "OK"
end

get '/selector' do
  "<p>" +
  "Outside section with a long text:" +
  "Where could they be? Close the blast doors! Open the blast doors! Open the blast doors! I've been waiting for you, Obi-Wan. We meet again, at last. The circle is now complete. When I left you, I was but the learner, now I am the master. Only a master of evil, Darth. Your powers are weak, old man. You can't win, Darth. If you strike me down, I shall become more powerful than you can possibly imagine." +
  "The entire starfleet couldn't destroy the whole planet. It'd take a thousand ships with more fire power than I've... There's another ship coming in. Maybe they know what happened. It's an Imperial fighter. It followed us! No. It's a short range fighter. There aren't any bases around here. Where did it come from? It sure is leaving in a big hurry. If they identify us, we're in big trouble. Not if I can help it. Chewie...jam it's transmissions. It'd be as well to let it go. It's too far out of range. Not for long..." +
  "</p>" +
  "<p class='select-me'>And a small one</p>"
end
