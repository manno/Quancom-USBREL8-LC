$LOAD_PATH << './lib'
require "drb"
require 'lichtscript'
require 'data_mapper'

# run as daemon
#
# add RPC for simple control of relays
#
# load several Licht::ActionStack containing Licht::Action from lichtcontrol
#  using Licht::Script.load
#
# assign Licht::ActionRule to every script (start time, execution probability, ...)
# add custom shutoff rule: Licht::ClearQueueAction, which clears timers from queue
#
# execute scripts according to Licht::Rules every n minutes
#
# TODO keep state of all executed commands in log/db
$VERBOSE = true

module Licht

  class Logger
    class Relay
      include DataMapper::Resource
      property :id, Integer, :key => true
      property :state, Boolean
    end

    def initialize
      DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db_relays.db")
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

    def setOut(id, state)
      relay = Relay.new :id => id
      relay.state = false
      relay.update :state => state 
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
      @actions = {}
      @rules = {}
      @queue = []
      @cardHandle = 0

      @logger = Logger.new

      start_thread
    end
    attr_reader :cardHandle
    attr_writer :cardHandle

    # add Script::ActionStack
    #
    def addScript( actionId, action )
      puts "[ ] add action: #{ actionId }" if $VERBOSE
      @actions[actionId] = action
    end

    def removeScript( actionId )
      puts "[ ] remove action: #{ actionId }" if $VERBOSE
      @actions.delete( actionId )
    end

    # add Script::Rule::*
    #
    def addRule( actionId, rule )
      puts "[ ] add rule: #{ actionId }" if $VERBOSE
      @rules[actionId] = rule
    end
    
    def removeRule( actionId )
      puts "[ ] remove rule from: #{ actionId }" if $VERBOSE
      @rules.delete( actionId )
    end

    # Drb
    #
    def add( actionId, action, rule )
      puts "[ ] add action/rule id: #{ actionId }" if $VERBOSE
      addScript( actionId, action )
      addRule( actionId, rule )
    end

    # Drb
    #
    def remove( actionId )
      puts "[ ] remove action/rule id: #{ actionId }" if $VERBOSE
      removeRule( actionId )
      removeScript( actionId )
    end

    def clear
      @actions = {}
      @rules = {}
      @queue = []
    end

    # Drb
    #
    def status
      return @rules.collect { |id, rule|
        "  #{id}:\n" +  @actions[id].to_str
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
      puts "[ ] wakeup at #{ time }" if $VERBOSE
      #p @queue

      # queue actions
      @rules.each { |id, rule| 
        if rule.apply(time) 
          action = @actions[id]
          puts "[=] hit #{id}"
          # queue actions if this is a actionstack
          #   or clear queue if this is a queue clear action
          if action.respond_to?( 'actions' )
            action.actions.each { |a| 
              # put action in queue
              @queue << { :at => time + a.delay, :action => a }
              # queue appropiate stop action in delay+duration s if duration > 0
              if a.duration > 0
                @queue << { :at => time + a.delay + a.duration, :action => a.invert }
              end
            }
          else
            # this is a ClearQueueAction
            @queue = []
            break
          end
        end
      }

      # anything to execute?
      todo = []
      @queue.each_index { |i|
        # FIXME tolerance?
        difference = time - @queue[i][:at]
        if difference < 2 and difference > -2
          todo << i
        end
      }

      # execute and log queued actions
      if not todo.empty?
        handle = QAPI.openCard QAPI::USBREL8LC, @cardHandle
        todo.each { |i|
          @queue[i][:action].execute( handle )
          @queue[i][:action].log_execute( @logger )
        }
        QAPI.closeCard handle
      end

      # remove finished actions from queue
      todo.reverse.each { |i|
        @queue.delete_at( i )
      }
    end

    def start_thread
      @thread = Thread.new do
        loop do
          wakeup
          sleep(@interval)
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
