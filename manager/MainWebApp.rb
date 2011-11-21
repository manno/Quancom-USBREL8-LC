#!/usr/bin/ruby
require 'rubygems'
require 'sinatra'
require 'haml'
#require 'cgi'

require 'data_mapper'
require "./lib/model.rb"
require "./lib/daemon_client.rb"

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

    begin
      @daemon_client = Webapp::DaemonClient.new
      @relays = @daemon_client.getRelayState # [0,0,0,1...]
    rescue DRb::DRbConnError
      @relays = []
      @message = "Failed to connect to daemon"
    end

    # TODO tune this
    # show rule - script, unused script, rule activation status
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
    @data = {
      :type => 'clear',
      :interval_chance => '100',
      :interval_interval => '15',
      :pit_chance => '100',
      :pit_execute_at => '2010.12.31 18:00',
      :tod_chance => '100',
      :tod_execute_at => '18:00',
    }
	  haml :rule_edit
  end

  get '/form/rule/:id' do
    @rule = Rule.get params[:id]
    @data = get_form_from_rule @rule
    # TODO parse type into names
	  haml :rule_edit
  end

  get '/form/rule/delete/:id' do
    @rule = Rule.get params[:id]
	  haml :rule_delete
  end

  get '/form/rule/assign/:id' do
    @rule_id = params[:id]
	  haml :rule_assign
  end

  # == ACTIONS

  post '/rule' do
    id = -1
    @rule = Rule.new
    update_rule_from_form @rule, params[:data]
    id = @rule.id
    redirect '/'
  end

  post '/rule/:id' do
    @rule = Rule.get params[:id]
    update_rule_from_form @rule, params[:data]
    redirect '/'
  end

  delete '/rule/:id' do
    @rule = Rule.get params[:id]
    @rule.destroy
    @message = "rule destroyed"
    haml :index
  end

	# get '/rule/:id' do
  #   @rule = Rule.get params[:id]
	#   # return xml?
	# end

  # not needed, same as index
	#get '/script' do
	#  haml :script_list
	#end

  get '/rule/toggle/:id' do
    @rule = Rule.get params[:id]

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

  post '/rule/assign/:id' do
    @rule = Rule.get params[:id]
    @script = Script.get params[:script_id]
    @rule.script = @script
    @rule.save
  end

  helpers do
    def update_rule_from_form( rule, params )
      type = params[:type]
      unless %w{clear interval pit tod}.include? type
        type = 'clear'
      end
      rule.type = type
      rule.created_at = Time.now

      case type
      when 'interval'
        rule.chance = params[:interval_chance]
        rule.interval = params[:interval_interval]
      when 'pit'
        rule.chance = params[:pit_chance]
        rule.execute_at = params[:pit_execute_at]
      when 'tod'
        rule.chance = params[:tod_chance]
        rule.execute_at = params[:tod_execute_at]
      end
      rule.save
    end

    def get_form_from_rule( rule )
      data = {
        :type => rule.type,
      }
      case rule.type
      when 'interval'
        data[:interval_chance] = rule.chance
          data[:interval_interval] = rule.interval
      when 'pit'
        data[:pit_chance] = rule.chance
          data[:pit_execute_at] = rule.execute_at
      when 'tod'
        data[:tod_chance] = rule.chance
          data[:tod_execute_at] = rule.execute_at
      end
      data
    end
  end

  # start if run directly
  run! if app_file == $0
end
