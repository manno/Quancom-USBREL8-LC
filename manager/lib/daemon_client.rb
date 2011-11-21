$LOAD_PATH << '../lib'
require 'lichtaction'
require 'lichtscript'
require 'lichtdaemon'

module Webapp
  DaemonURL = 'druby://:9001'

  class DaemonClient

    def initialize( url= 'druby://:9001' )
      DRb.start_service()
      @client = DRbObject.new nil, url
      @client
    end

    def getRelayState
      @client.getRelayState
    end

    def add( rule )
      scriptObj = Licht::load @rule.script.text
      case rule.type
      when 'clear'
        ruleObj = Licht::Script::Rule.ClearQueueAction.new
      when 'interval'
        ruleObj = Licht::Script::Rule.ActionRuleInterval.new( rule.interval, rule.chance )
      when 'pit'
        ruleObj = Licht::Script::Rule.ActionRulePiT.new( rule.execute_at, rule.chance )
      when 'tod'
        ruleObj = Licht::Script::Rule.ActionRuleDaytime.new( rule.execute_at, rule.chance )
      end
      @client.add rule.id, scriptObj, ruleObj
    end

    def remove( rule )
      @client.remove rule.id
    end

    def status
      @client.status
    end

  end

end
