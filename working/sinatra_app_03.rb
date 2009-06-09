require 'rubygems'
require 'sinatra'

get '/:id' do
  `cat #{params[:id]}*`
end
