#!/usr/bin/ruby
require 'rubygems'
require 'sinatra'
require 'haml'
#require 'cgi'

require 'datamapper'
require "lib/model.rb"
require "lib/daemon_client.rb"

# executed when?
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/database.db")
Webapp::Model::migrate

=begin

=end

class MainWebApp < Sinatra::Base
  include Webapp::Model
  set :environment, :development  

  def initialize
    super
    @daemon_client = DaemonClient.new

    # TODO tune this
    # show rule - script, unused script, rule activation status
    @relays = @daemon_client.getRelayState # [0,0,0,1...]
    @rules = Rule.all
    @scripts = Script.all
  end

  # list all rules, scripts and relays
	get '/' do
	  @message = ""
	  haml :index
	end

  # not needed, same as index
	# get '/rule' do
	#   haml :rule_list
	# end

  # == FORMS

  get '/form/rule' do
	  haml :rule_edit
  end

  get '/form/assign_rule/id:' do
	  haml :rule_assign
  end

  get '/form/rule/:id' do
    @rule = Rule.get param[:id]
	  haml :rule_edit
  end

  get '/form/rule/delete/:id' do
    @rule = Rule.get param[:id]
	  haml :rule_delete
  end

  # == ACTIONS

  post '/rule' do
    @rule = Rule.new
    id = @rule.id
    @message "rule created: #{id}"
    haml :index
  end

  post '/rule/:id' do
    @rule = Rule.get param[:id]
    @message "rule updated"
    haml :index
  end

  # TODO has no form, needs a button
  delete '/rule/:id' do
    @rule = Rule.get param[:id]
    @rule.destroy
    @message "rule destroyed"
    haml :index
  end

	# get '/rule/:id' do
  #   @rule = Rule.get param[:id]
	#   # return xml?
	# end

  # not needed, same as index
	#get '/script' do
	#  haml :script_list
	#end

  post '/toggle_rule/:id' do
    @rule = Rule.get param[:id]

    unless defined? @rule.script
      redirect :error
    end

    if @rule.active
      @daemon_client.remove @rule
    else
      @daemon_client.add @rule
    end

    @rule.active = ! @rule.active
    @rule.save
  end

  # TODO has no form, needs a button
  post '/assign_rule/:id' do
    @rule = Rule.get param[:id]
    @script = Script.get param 'script_id'
    @rule.script = @script
    @rule.save
  end

  # start if run directly
  run! if app_file == $0
end
