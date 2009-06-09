require 'rubygems'
require 'sinatra'

class Cowsays
  def initialize(app); @app = app end
  def call(env)
    http_code, headers, original_body = @app.call(env)

    body = ""
    original_body.each do |line|
      body << line
    end

    puts body
    body = `cowsay "#{body.strip}"`

    puts body

    [http_code, headers.merge('Content-Type' => 'text/plain'), body]
  end
end

map '/premium' do
  require 'rack_fake_auth'

  use Rack::Session::Cookie
  use Rack::FakeAuth

  require 'sinatra_app_01'
  run Sinatra::Application
end

map '/free' do
  require 'sinatra_app_02'
  run Sinatra::Application
end

map '/' do

  use Cowsays

  require 'sinatra_app_03'
  run Sinatra::Application
end
