require 'sinatra'
require "sinatra/config_file"
require "sinatra/reloader" if development?

config_file 'config.yml'

set :port, settings.port
set :bind, settings.bind

before do
  @log = params[:log].nil? ? '/dev/null' : params[:log]
end

get '/' do
  "<a href='/page'>Hello World</a>"
end

get '/page' do
  "Some Page with a <a href='/broken'>Broken Link</a><br>" +
  "And a non broken link to follow <a href='/ok'>OK Link</a>"
end

get '/ok' do
  "OK"
end

