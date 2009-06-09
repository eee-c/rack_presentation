require 'rubygems'
require 'sinatra'

map '/premium' do
  require 'sinatra_app_01'
  run Sinatra::Application
end

map '/free' do
  require 'sinatra_app_02'
  run Sinatra::Application
end

map '/' do
  require 'sinatra_app_03'
  run Sinatra::Application
end
