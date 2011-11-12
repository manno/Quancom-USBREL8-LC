=begin

execute, log, edit, display commands

=end

require 'lib/quancom-ffi'

module Licht
  class Action
    include QAPI
      #QAPI::OUT1

    def initialize( outputs, delay, duration )
      @outputs = parse_outputs( outputs )
      @delay = delay
      @duration = duration
    end
    attr_reader :outputs, :delay, :duration

    def parse_outputs( outputs )
      # translate
      # ALL - QAPI::ALL
      # 1 - QAPI::OUT1
      outputs.each { |o|
        case o
        when 'ALL'
          @outputs = [1]
          break
        when /^\d+$/
          @outputs.push (1 << o-1)
        end
    end
  end

  class ActionStack
    def initialize
      @actions = []
    end

    def addOnCommand( outputs, time_delay_on, time_duration )
      @actions << Action.new( :on, outputs, time_delay_on, time_duration )
    end

    def addOffCommand( outputs, time_delay_off, time_duration )
      @actions << Action.new( :off, outputs, time_delay_off, time_duration )
    end

    def execute
      # TODO time related, handled by daemon
    end

    def get
    end

    def modify
    end

  end
end
