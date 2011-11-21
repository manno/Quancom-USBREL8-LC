#!/usr/bin/ruby
require 'rubygems'
require 'sinatra'
require 'haml'
require 'pp'

require "./lib/daemon_client"
require "./lib/helpers"

=begin

=end

class MainWebApp < Sinatra::Base
  include Webapp::Model
  helpers Webapp::Helpers
  set :root, File.dirname(__FILE__)
  set :static, true
  enable :sessions
  configure(:development) { set :session_secret, "RygVoohec2" }

  def initialize
    super
    # drb client
    @relays = []
    @daemon_client = Webapp::DaemonClient.new
    @daemon_client.init_from_db Rule.all
  end

  # list all rules, scripts and relays
	get '/' do
    @rules = Rule.all
    @scripts = Script.all

    @relays = @daemon_client.getRelayState
    @daemon_client.synchronize @rules

    get_message
	  haml :index
	end

  get '/status' do
    @status = @daemon_client.status
    haml :status
  end

  get '/error' do
    get_message
    haml :error
  end

  # moved to config.ru layout
  # one app, multiple files
  #use Webapp::RoutesRules
  #use Webapp::RoutesScripts
  # start if run directly
  #run! if app_file == $0

end

