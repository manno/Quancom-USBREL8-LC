require 'rubygems'
require 'sinatra'
require 'data_mapper'
require "./lib/model"

$LOAD_PATH << '../lib'
require 'libconfig'
Licht::Config::setup '..'

require './MainWebApp'
require "./lib/routes_rules"
require "./lib/routes_scripts"
require "./lib/routes_relays"

map "/" do
  run MainWebApp
end

map "/rule" do
  run Webapp::RoutesRules
end

map "/script" do
  run Webapp::RoutesScripts
end

map "/relay" do
  run Webapp::RoutesRelays
end
