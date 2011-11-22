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
# keeps state of all executed commands in log/db
$_VERBOSE = true

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
      @cardNumber = 0

      @logger = Logger.new

      start_thread
    end
    attr_reader :cardNumber
    attr_writer :cardNumber

    # add Script::ActionStack
    #
    def addScript( actionId, action )
      puts "[ ] add action: #{ actionId }" if $_VERBOSE
      @actions[actionId] = action
    end

    def removeScript( actionId )
      puts "[ ] remove action: #{ actionId }" if $_VERBOSE
      @actions.delete( actionId )
    end

    # add Script::Rule::*
    #
    def addRule( actionId, rule )
      puts "[ ] add rule: #{ actionId }" if $_VERBOSE
      @rules[actionId] = rule
    end
    
    def removeRule( actionId )
      puts "[ ] remove rule from: #{ actionId }" if $_VERBOSE
      @rules.delete( actionId )
    end

    # Drb
    #
    def add( actionId, action, rule )
      puts "[ ] add action/rule id: #{ actionId }" if $_VERBOSE
      addScript( actionId, action )
      addRule( actionId, rule )
    end

    # Drb
    #
    def remove( actionId )
      puts "[ ] remove action/rule id: #{ actionId }" if $_VERBOSE
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
      # TODO returns junk
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
      puts "[ ] wakeup at #{ time }" if $_VERBOSE
      #p @queue

      # queue actions
      @rules.each { |id, rule| 
        if rule.apply(time) 
          action = @actions[id]
          puts "[=] executing rule #{id}"
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
        handle = QAPI.openCard QAPI::USBREL8LC, @cardNumber
        if handle > 0
          puts "[ ] QAPI card open success e#{handle})" if $_VERBOSE
          todo.each { |i|
            action = @queue[i][:action]
            puts "[=] QAPI action: #{action.to_str}" if $_VERBOSE
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
    puts "[ ] starting daemon" if $_VERBOSE
    serverObject = Daemon.new
    DRb.start_service url, serverObject
    DRb.thread.join
  end

end
