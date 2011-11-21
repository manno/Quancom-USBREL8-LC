require 'rubygems'
require 'sinatra'
require 'data_mapper'
require "./lib/model"

require './MainWebApp'
require "./lib/routes_rules"
require "./lib/routes_scripts"

set :port, 4567
#enable :logging
#set :environment, :development

map "/" do
  run MainWebApp
end

map "/rule" do
  run Webapp::RoutesRules
end

map "/script" do
  run Webapp::RoutesScripts
end
