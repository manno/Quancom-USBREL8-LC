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

    def initialize( type, outputs, delay, duration )
      @type = type
      @outputs = []
      parse_outputs( outputs )
      @delay = delay
      @duration = duration
    end
    attr_reader :type, :outputs, :delay, :duration
    attr_writer :type

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

    def invert
      new = self.clone
      case @type
      when :on
        new.type = :off
      when :off
        new.type = :on
      end
      return new
    end

    def to_str
      case @type
      when :set
        return "    QAPI.writeDO16 handle, #{output_mask}, 0\n"
      when :on
        return @outputs.collect { |o|
          "    QAPI.writeDO1 handle, #{o-1}, QAPI::TRUE, 0"
        }.join( "\n" )
      when :off
        return @outputs.collect { |o|
          "    QAPI.writeDO1 handle, #{o-1}, QAPI::FALSE, 0"
        }.join( "\n" )
      end
    end

  end

  # List of actions
  #
  class ActionStack
    def initialize
      @actions = []
    end
    attr_reader :actions

    def addOnCommand( outputs, time_delay_on, time_duration )
      puts "[ ] Add action ON" if $VERBOSE
      @actions << Action.new( :on, outputs, time_delay_on, time_duration )
      pp @actions[-1] if $DEBUG
    end

    def addOffCommand( outputs, time_delay_off, time_duration )
      puts "[ ] Add action OFF" if $VERBOSE
      @actions << Action.new( :off, outputs, time_delay_off, time_duration )
      pp @actions[-1] if $DEBUG
    end

    def addSetCommand( outputs, time_delay_off, time_duration )
      puts "[ ] Add action SET" if $VERBOSE
      @actions << Action.new( :set, outputs, time_delay_off, time_duration )
      pp @actions[-1] if $DEBUG
    end

    def to_str
      return @actions.collect { |a| "  "+ a.to_str }.join( "\n" )
    end

  end

  # Clear Queue Action
  # 
  class ClearQueueAction
    # contains nothing really
    def to_str
      return "clear queue action"
    end
  end

  # When to execute the action
  #
  class ActionRuleIntervall
    def initialize( intervall=5, chance=100 )
      @intervall = intervall
      @chance = chance
      @last = Time.now.to_i
      puts "[!] Action intervall: first hit at #{@last+@intervall}"
    end
    def apply( time )
      p = rand(100)
      if p < @chance and @last + @intervall < time 
        @last = time
        return true
      end
    end
  end

  # Point in Time
  #
  class ActionRulePiT
    def initialize( time, chance=100 )
      @time = time
      @chance = chance
      puts "[!] Action PiT: first hit at #{@time}"
    end
    def apply( time )
      # FIXME does this work?
      p = rand(100)
      difference = @time - time
      if p < @chance and  difference < 2 and difference > -2
        return true
      end
    end
  end

end
