=begin

execute, log, edit, display commands

=end

$_VERBOSE = true
if $TEST
  require 'quancom-test'
else
  require 'quancom-ffi'
end
require 'pp'

module Licht

  module Script

    # A single command
    #
    class QapiAction

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

      # remember state
      #
      def log_execute( logger )
        case @type
        when :set
          (1..8).each { |i| 
            if i >> output_mask == 0
              logger.setOut( i, true )
            else
              logger.setOut( i, false )
            end
          }
        when :on
          @outputs.each { |o| logger.setOut o, true }
        when :off
          @outputs.each { |o| logger.setOut o, false }
        end
      end

      def invert
        new = self.clone
        case @type
        when :on
          new.type = :off
        when :off
          new.type = :on
        when :set
          raise "not implemented"
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

    # List of actions, result of Script.load
    #
    class QapiActionStack
      def initialize
        @actions = []
      end
      attr_reader :actions

      def addOnCommand( outputs, time_delay_on, time_duration )
        puts "[ ] Add action ON" if $_VERBOSE
        @actions << QapiAction.new( :on, outputs, time_delay_on, time_duration )
        pp @actions[-1] if $DEBUG
      end

      def addOffCommand( outputs, time_delay_off, time_duration )
        puts "[ ] Add action OFF" if $_VERBOSE
        @actions << QapiAction.new( :off, outputs, time_delay_off, time_duration )
        pp @actions[-1] if $DEBUG
      end

      def addSetCommand( outputs, time_delay_off, time_duration )
        puts "[ ] Add action SET" if $_VERBOSE
        @actions << QapiAction.new( :set, outputs, time_delay_off, time_duration )
        pp @actions[-1] if $DEBUG
      end

      def to_str
        return @actions.collect { |a| "  "+ a.to_str }.join( "\n" )
      end

    end

    # Clear Queue
    # 
    class ClearQueueAction
      # contains nothing really
      def to_str
        return "      clear queue action"
      end
    end
  end

  module Rule

    # When to execute the action
    #
    class RuleInterval
      def initialize( interval=5, chance=100 )
        @interval = interval
        @chance = chance
        @last = Time.now.to_i
        puts "[!] Action interval: first hit at #{@last+@interval}"
      end
      def apply( time )
        p = rand(100)
        if p < @chance and @last + @interval < time 
          @last = time
          return true
        end
      end
    end

    # Point in Time
    #
    class RulePiT
      def initialize( time, chance=100 )
        @time = time
        @chance = chance
        puts "[!] Action PiT: first hit at #{@time}"
      end
      def apply( time )
        p = rand(100)
        difference = @time - time
        if p < @chance and  difference < 2 and difference > -2
          return true
        end
      end
    end

    # Daily
    #
    class RuleDaytime
      def initialize( time='18:00', chance=100 )
        a = time.split /:/
        @hour = a[0]
        @minute = a[1]
        @chance = chance
        puts "[!] Action ToD: every day at #{@hour}:#{@minute}"
      end
      def apply( time )
        t = Time.at time
        next_time = Time.new t.year, t.month, t.mday, @hour, @minute, 0
        puts "[=] check #{next_time} against #{t}" if $_VERBOSE

        p = rand(100)
        difference = next_time.to_i - time
        if p < @chance and  difference < 2 and difference > -2
          return true
        end
      end
    end
    
  end

end
