=begin

execute, log, edit, display commands

=end

#require 'quancom-ffi'
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
      # translate
      # ALL - QAPI::ALL
      # 1 - QAPI::OUT1
      outputs.each { |o|
        case o
        when 'ALL'
          #@outputs = [ QAPI::ALL ]
          @outputs = [ 255 ]
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

    def execute
      # TODO time related, handled by daemon
    end

    def modify
    end

  end
end
