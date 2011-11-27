$LOAD_PATH << '../lib'
require 'lichtaction'
require 'lichtscript'
require 'lichtdaemon'

module Webapp

  class DaemonClient

    def initialize( url= 'druby://:9001' )
      @url = url
      DRb.start_service
      begin
        @client = DRbObject.new nil, @url
      rescue DRb::DRbConnError
        STDERR.puts "[!] Failed to connect to drb daemon #{@url}" if $DEBUG
      end
      @client
    end

    def getRelayState
      begin
        @client.getRelayState
      rescue DRb::DRbConnError
        STDERR.puts "[!] Failed to connect to drb daemon #{@url}" if $DEBUG
      end
    end

    def add( rule )
      return if rule.script.nil?
      scriptObj = Licht::Script.load rule.script.text
      case rule.type
      when 'interval'
        ruleObj = Licht::Rule::RuleInterval.new( rule.interval.to_i, rule.chance.to_i )
      when 'pit'
        ruleObj = Licht::Rule::RulePiT.new( rule.execute_at, rule.chance.to_i )
      when 'tod'
        ruleObj = Licht::Rule::RuleDaytime.new( rule.execute_at, rule.chance.to_i )
      end
      begin
        @client.add rule.id, scriptObj, ruleObj
      rescue DRb::DRbConnError
        STDERR.puts "[!] Failed to connect to drb daemon #{@url}" if $DEBUG
      end
    end

    def remove( rule )
      id = rule
      if rule.respond_to? 'id'
        id = rule.id
      end
      begin
        @client.remove id
      rescue DRb::DRbConnError
        STDERR.puts "[!] Failed to connect to drb daemon #{@url}" if $DEBUG
      end
    end

    def executeAction( type, relay=0 )
      case type
      when :on
        action  = Licht::Script::QapiAction.new( :on, [relay] )
      when :off
        action  = Licht::Script::QapiAction.new( :off, [relay] )
      when :set_on
        action  = Licht::Script::QapiAction.new( :set, ['ALL'] )
      when :set_off
        action  = Licht::Script::QapiAction.new( :set, ['NONE'] )
      end
      begin
        @client.executeAction( action )
      rescue DRb::DRbConnError
        STDERR.puts "[!] Failed to connect to drb daemon #{@url}" if $DEBUG
      end
    end

    def status
      begin
        @client.status
      rescue DRb::DRbConnError
        STDERR.puts "[!] Failed to connect to drb daemon #{@url}" if $DEBUG
      end
    end

    def synchronize( rules )
      # TODO filter in db, not in query results
      rules_db = rules.select { |rule| rule.active }.collect { |rule| rule.id }
      rules_daemon = @client.getRuleIds
      rules_db.each { |id|
        unless rules_daemon.include? id
          STDERR.puts "[!] webinterface had one to many, deactivate #{id}"
          rule = rules.select { |rule| rule.id == id }.first
          rule.active = false
          rule.save
        end
      }
      rules_daemon.each { |id|
        unless rules_db.include? id
          STDERR.puts "[!] daemon had one to many, remove #{id}"
          remove id
        end
      }
    end

    def init_from_db( rules )
      # TODO filter in db, not in query results
      rules_db = rules.select { |rule| rule.active }.collect { |rule| rule.id }
      rules_daemon = @client.getRuleIds
      rules_daemon.each { |id|
        unless rules_db.include? id
          STDERR.puts "[!] daemon had one to many, remove #{id}"
          remove id
        end
      }
      rules_db.each { |id|
        unless rules_daemon.include? id
          STDERR.puts "[!] daemon is missing rule #{id}, adding"
          rule = rules.select { |rule| rule.id == id }.first
          add rule
        end
      }
    end


  end
end
