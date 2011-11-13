$LOAD_PATH << './lib'
require "drb"
require 'lichtscript'

# run as daemon
#
# add RPC for simple control of relays
#
# load several Licht::ActionStacks with Licht::Action from lichtcontrol
#  using Licht::Script.load
#
# assign Licht::Rule to every script (start time, execution probability, ...)
# add custom shutoff rule: clears all rules, inclusive timers from stack
#   so nothing executes thereafter
#
# execute scripts according to Licht::Rules every n minutes
#
# keep state of all executed commands in log/db
$VERBOSE = true

module Licht

  class Daemon

    def initialize
      @intervall = 3
      @actionstacks = {}
      @rules = {}

      start_thread
    end

    def addActionStack( actionId, stack )
      puts "[ ] add actionstack: #{ actionId }" if $VERBOSE
      @actionstacks[actionId] = stack
    end

    def removeActionStack( actionId )
      @actionstacks.delete( actionId )
    end

    def addRule( actionId, rule )
      puts "[ ] add rule: #{ actionId }" if $VERBOSE
      @rules[actionId] = rule
    end
    
    def removeRule( actionId )
      @rules.delete( actionId )
    end

    def remove( actionId )
      puts "[ ] remove id: #{ actionId }" if $VERBOSE
      removeRule( actionId )
      removeActionStack( actionId )
    end

    def status
      return @rules.collect { |id, rule|
        "  #{id}:\n" +  @actionstacks[id].to_s
      }.join( "\n" )
    end

    def wakeup
      time = Time.now.to_i
      puts "[ ] wakeup at #{ time }" if $VERBOSE

      @rules.each { |id, rule| 
        if rule.apply(time) 
          actionstack = @actionstacks[id]
          puts "[=] hit #{id}"
          #actionstack.actions.each { |a| #}
        end
      }
    end

    def start_thread
      @thread = Thread.new do
        loop do
          wakeup
          sleep(@intervall)
        end
      end
      @thread
    end

  end

  def Licht.start_daemon( url = 'druby://:9001' )
    puts "[ ] starting daemon" if $VERBOSE
    serverObject = Daemon.new
    DRb.start_service url, serverObject
    DRb.thread.join
  end

end
