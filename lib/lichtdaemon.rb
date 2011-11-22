$LOAD_PATH << './lib'
require "drb"
require 'lichtscript'
require 'data_mapper'

# daemon, periodic execution of relay commands
#
# = Scripts
#
# load several Licht::Script::QapiActionStack containing 
#   Licht::Script::QapiAction from lichtcontrol
#   using Licht::Script.load
#
# There is a  custom shutoff Object
#   Licht::Script::ClearQueueAction, which clears timers from queue
#
# = Rules
#
# assign Licht::Rule to every script (start time, execution probability, ...)
#
# each rule can have one script
# each script may belong to several rules
#
# execute scripts according to Licht::Rules every n minutes
#
# = State
#
# keeps state of all executed commands in log/db
#
$_VERBOSE = true

module Licht

  class Relay
    include DataMapper::Resource
    property :id, Integer, :key => true
    property :state, Boolean
  end

  class Logger

    def initialize
      DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db_relays.db")
      DataMapper.finalize
      migrate
    end

    def migrate
      unless Relay.storage_exists?
        Relay.auto_migrate! 
        (1..8).each { |id|
          relay = Relay.new :id => id
          relay.state = false
          relay.save
        }
      end 
    end

    # expect integer position of relay as id
    #
    def setOut(id, state)
      relay = Relay.get id
      relay.state = state
      relay.save
    end

    def getState
      state = {}
      Relay.all.each { |row|
        state[ row.id ] = row.state
      }
      state
    end
  end

  class Daemon

    def initialize
      #@interval = 60
      @interval = 3
      @scripts = {}
      @rules = {}
      @queue = []
      @cardNumber = 0

      @logger = Logger.new

      start_thread
    end
    attr_reader :cardNumber
    attr_writer :cardNumber

    def start_thread
      @thread = Thread.new do
        loop do
          wakeup
          sleep(@interval)
        end
      end
      @thread
    end

    # add Script::QapiActionStack
    #
    def addScript( ruleId, script )
      puts "[ ] add script: #{ ruleId }" if $_VERBOSE
      puts script.to_str if $_VERBOSE
      @scripts[ruleId] = script
    end

    def removeScript( ruleId )
      puts "[ ] remove script: #{ ruleId }" if $_VERBOSE
      @scripts.delete( ruleId )
    end

    # add Script::Rule::*
    #
    def addRule( ruleId, rule )
      puts "[ ] add rule: #{ ruleId }" if $_VERBOSE
      @rules[ruleId] = rule
    end
    
    def removeRule( ruleId )
      puts "[ ] remove rule from: #{ ruleId }" if $_VERBOSE
      @rules.delete( ruleId )
    end

    # Drb
    #
    def add( ruleId, script, rule )
      puts "[ ] add script/rule id: #{ ruleId }" if $_VERBOSE
      addScript( ruleId, script )
      addRule( ruleId, rule )
    end

    # Drb
    #
    def remove( ruleId )
      puts "[ ] remove script/rule id: #{ ruleId }" if $_VERBOSE
      removeRule( ruleId )
      removeScript( ruleId )
    end

    def clear
      @scripts = {}
      @rules = {}
      @queue = []
    end

    # Drb
    #
    def status
      # TODO returns junk
      return @rules.collect { |id, rule|
        "  #{id}:\n" +  @scripts[id].to_str
      }.join( "\n" )
    end

    # Drb
    #
    def getRelayState
      @logger.getState
    end

    # Drb
    #
    def getRuleIds
      @rules.collect { |id, rule|
        id
      }
    end

    def wakeup
      time = Time.now.to_i
      puts "[ ] wakeup at #{ time }" if $_VERBOSE
      #p @queue

      queue_actions_from_rules time

      queue_execute_actions time
    end

    private

    def queue_actions_from_rules( time )
      # queue scripts
      @rules.each { |id, rule| 
        if rule.apply(time) 
          script = @scripts[id]
          puts "[=] executing rule #{id}"
          # queue actions if this is an actionstack
          #   or add single action if this is an action
          #   or clear queue if this is a queue clear rule
          if script.respond_to?( 'actions' )
            script.actions.each { |a| queue_add_action time, a }
          elsif script.respond_to?( 'execute' )
            queue_add_action time, script
          else
            # this is a ClearQueueAction
            @queue = []
            break
          end
        end
      }
    end

    def queue_add_action( time, a )
      # put action in queue
      @queue << { :at => time + a.delay, :action => a }
      # queue appropiate stop action in delay+duration s if duration > 0
      if a.duration > 0
        @queue << { :at => time + a.delay + a.duration, :action => a.invert }
      end
    end

    def queue_execute_actions( time )
      # anything to execute?
      todo = []
      @queue.each_index { |i|
        # TODO tolerance working?
        difference = time - @queue[i][:at]
        if difference < 2 and difference > -2
          todo << i
        end
      }

      # execute and log queued actions
      if not todo.empty?
        handle = QAPI.openCard QAPI::USBREL8LC, @cardNumber
        if handle > 0
          puts "[ ] QAPI card open success (#{handle})" if $_VERBOSE
          todo.each { |i|
            action = @queue[i][:action]
            puts "[=] execute QAPI action" if $_VERBOSE
            puts action.to_str if $_VERBOSE
            action.execute( handle )
            action.log_execute( @logger )
          }
          QAPI.closeCard handle
        else
          puts "[!] QAPI card open failed!"
        end
      end

      # remove finished actions from queue
      todo.reverse.each { |i|
        @queue.delete_at( i )
      }
    end

  end

  def Licht.start_daemon( url = 'druby://:9001' )
    puts "[ ] starting daemon" if $_VERBOSE
    serverObject = Daemon.new
    DRb.start_service url, serverObject
    DRb.thread.join
  end

end
