#!/usr/bin/ruby
# vim: ft=ragel
require 'lichtaction.rb'

$VERBOSE=1

module Licht
  module Parser

    def controller( c )
      @controller = c
    end

    # label output 1 Bathroom
    # turn off Bathroom
    # turn off all outputs
    # turn off all outputs after 1 minute
    # turn on output 1 
    # turn on output 1, Bathroom, output 2
    # turn on Bathroom
    # turn on Bathroom in 5 minutes for 45 seconds
    # turn on Bathroom in 1 hour 
    %%{
      machine licht;

      action StartLabel { marker1 = p }
      action EndLabel { labels << data[marker1..p] }

      action StartOutput { marker2 = p + "output".length }
      action EndOutput { outputs << data[marker2..p].strip }

      action EndLabelAll { outputs << 'ALL' }

      action StartTimeUnit { marker3 = p }
      action EndTimeUnit { 
        unit = data[marker3..p] 
        case unit
          when /minute/
            time_unit_factor = 60
          when /hour/
            time_unit_factor = 60*60
          when /day/
            time_unit_factor = 24*60*60
        end
      }

      action StartTime { marker4 = p }
      action EndTime { 
        time = data[marker4..p].to_i * time_unit_factor
        time_unit_factor = 1
      }

      action EndTimeDelayOff { 
        time_delay_off = time
        time = 0
      }

      action EndTimeDelayOn { 
        time_delay_on = time
        time = 0
      }

      action EndTimeDuration { 
        time_duration = time
        time = 0
      }

      action CommandOn {
        labels.each { |l| outputs << label_lookup[l] }
        labels.clear
        @controller.addOnCommand( outputs, time_delay_on, time_duration )
      }

      action CommandOff {
        labels.each { |l| outputs << label_lookup[l] }
        labels.clear
        @controller.addOffCommand( outputs, time_delay_off, time_duration )
      }

      action CommandName {
        label = labels.pop!
        output = outputs.pop!
        label_lookup[label] = output
      }

      ws1 = ' '+;
      ws0 = ' '{0,};

      label = alpha                                                                  >StartLabel %~EndLabel;
      output = 'output' ws0 digit+                                                   >StartOutput %~EndOutput; 
      label_all = "all outputs"                                                      %~EndLabelAll;
      relay_name = ( label | output );
      relay_name_list_on = ( relay_name | ( "," ws0 relay_name )? );
      relay_name_list_off = ( label_all | ( relay_name | ( "," ws0 relay_name )? ) );

      time_unit = ( "second" "s"? | "minute" "s"? | "hour" "s"? | "day" "s"? )      >StartTimeUnit %~EndTimeUnit;
      time = digit+ ws0 time_unit                                                   >StartTime %~EndTime;

      time_delay_off = "after" time                                                 %~EndTimeDelayOff;
      time_delay_on  = "in" time                                                    %~EndTimeDelayOn;
      time_duration = "for" time                                                    %~EndTimeDuration;

      command_name = ( ws1 'label' ws1 output label ws0 '\n' )          @CommandName;
      command_on = ( ws1 'turn on' ws1 relay_name_list_on ws0 '\n' )    @CommandOn;
      command_off = ( ws1 'turn off' ws1 relay_name_list_off ws0 '\n' ) @CommandOff;
      main := ( /^#.*/ | command_name | command_on | command_off );

    }%%

    %% write data;

    def parse(data)
      # States
      labels = []
      outputs = []
      time_unit_factor = 1
      time_delay_on = 0
      time_delay_off = 0
      time_duration = 0

      %% write init;
      %% write exec;

      print "Finished. The state of the machine is: #{cs} - p: #{p} pe: #{pe}" if $DEBUG
    end

  end

  class Script
    def load
      include Licht::Parser
      licht = Licht::ActionStack.new
      Licht::Parser.controller(licht)

      puts "Parsing commands" if $VERBOSE
      while gets
        Licht::Parser.parse($_)
      end

      if $DEBUG
        puts "Display actions" if $VERBOSE
        licht.display
      end

      return licht
    end
  end
end
