require 'rubygems'
require 'sinatra'

require 'data_mapper'
require "./lib/model"

require './MainWebApp'
require "./lib/routes_rules"
require "./lib/routes_scripts"

#enable :logging
set :port, 4567
set :environment, :development  

# this is needed for Routes* ?
enable :sessions
configure(:development) { set :session_secret, "RygVoohec2" }

#run MainWebApp

map "/" do
  run MainWebApp
end

map "/rule" do
  run Webapp::RoutesRules
end

map "/script" do
  run Webapp::RoutesScripts
end
