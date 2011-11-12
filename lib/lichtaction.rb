=begin

execute, log, edit, display commands

=end

$TEST = true
if $TEST
  require 'quancom-test'
else
  require 'quancom-ffi'
end
require 'pp'

module Licht
  class Action
    #include QAPI
    #QAPI::OUT1

    def initialize( type, outputs, delay, duration )
      @type = type
      @outputs = []
      parse_outputs( outputs )
      @delay = delay
      @duration = duration
    end
    attr_reader :type, :outputs, :delay, :duration

    def parse_outputs( outputs )
      # translate relay number to bit position
      # 3 -> 0x4
      outputs.each { |o|
        case o
        when 'ALL'
          @outputs = [ QAPI::ALL ]
          break
        else
          val =  1 << o-1
          @outputs.push( val )
        end
      }
      @outputs
    end

    def output_mask
      val = 0
      @outputs.each { |o| val += o } 
      val
    end

    def execute( handle )
      # time related, handled by daemon
      case @type
      when :set
        QAPI.writeDO16 handle, output_mask, 0
      when :on
        @outputs.each { |o|
          QAPI.writeDO1 handle, o-1, QAPI::TRUE, 0
        }
      when :off
        @outputs.each { |o|
          QAPI.writeDO1 handle, o-1, QAPI::FALSE, 0
        }
      end
      
    end
  end

  class ActionStack
    def initialize
      @actions = []
    end
    attr_reader :actions

    def addOnCommand( outputs, time_delay_on, time_duration )
      puts "[   ] Add action ON" if $VERBOSE
      @actions << Action.new( :on, outputs, time_delay_on, time_duration )
      pp @actions[-1] if $DEBUG
    end

    def addOffCommand( outputs, time_delay_off, time_duration )
      puts "[   ] Add action OFF" if $VERBOSE
      @actions << Action.new( :off, outputs, time_delay_off, time_duration )
      pp @actions[-1] if $DEBUG
    end

    def addSetCommand( outputs, time_delay_off, time_duration )
      puts "[   ] Add action SET" if $VERBOSE
      @actions << Action.new( :set, outputs, time_delay_off, time_duration )
      pp @actions[-1] if $DEBUG
    end

  end
end
