#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'haml'
require 'pp'

require "./lib/helpers"
require "./lib/daemon_client"

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
    @daemon_client = Webapp::DaemonClient.new $DAEMON_URL
    @relays = []
  end

  # list all rules, scripts and relays
	get '/' do
    @rules = Rule.all( :order => [ :active.desc, :script_id.desc, :execute_at.desc, :type.desc ] )
    @scripts = Script.all( :order => [ :name.asc, :created_at.desc ] )

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

  configure do
    if settings.environment != :development
      puts "################################ EXECUTE ONLY ONCE  #################"
      daemon_client = Webapp::DaemonClient.new
      daemon_client.init_from_db Rule.all
    end
  end

end

