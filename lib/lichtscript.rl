# vim: ft=ragel
require 'lichtaction.rb'

$_VERBOSE=true
$DEBUG=false

module Licht
  module Parser

    def Parser.setup( c )
      @controller = c
      # Tokens by script
      @label_lookup = {}
    end

    %%{
      machine licht;

      action StartLabel { marker1 = p }
      action EndLabel { 
        str = data[marker1..p-1]
        # sadly label matches token 'output', exclude:
        unless str.index( 'output', 0 ) or str.index( 'all', 0 )
          labels << str
        end
      }

      action StartOutput { marker2 = p } # + "output".length }
      action EndOutput { 
        outputs << data[marker2..p].to_i
      }

      action EndLabelAll { outputs << 'ALL' }

      action StartTimeUnit { marker3 = p }
      action EndTimeUnit { 
        unit = data[marker3..p-1] 
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
        time = data[marker4..p-1].to_i
        time_unit_factor = 1
      }

      action EndTimeDelay { 
        time_delay = time * time_unit_factor
        time = 0
      }

      action EndTimeDuration { 
        time_duration = time * time_unit_factor
        time = 0
      }

      action CommandOn {
        labels.each { |l| outputs << @label_lookup[l] }
        labels.clear
        @controller.addOnCommand( outputs, time_delay, time_duration )
      }

      action CommandOff {
        labels.each { |l| outputs << @label_lookup[l] }
        labels.clear
        @controller.addOffCommand( outputs, time_delay, time_duration )
      }

      action CommandSet {
        labels.each { |l| outputs << @label_lookup[l] }
        labels.clear
        @controller.addSetCommand( outputs, time_delay, time_duration )
      }

      action CommandName {
        puts "[   ] Label relay" if $_VERBOSE
        label = labels.pop
        output = outputs.pop
        @label_lookup[label] = output
      }

      ws1 = ' '+;
      ws0 = ' '{0,};
      eol = /[\r\n]/ | '\r\n';

      output = 'output' ws0 digit+  >StartOutput %EndOutput; 
      label_all = 'all outputs'     %~EndLabelAll;
      label = alnum+                >StartLabel  %EndLabel;

      relay_name = ( label | output );
      relay_name_list_on = ( relay_name | relay_name ( ',' ws0 relay_name )* );
      relay_name_list_off = ( label_all | ( relay_name | relay_name ( ',' ws0 relay_name )* ) );

      time_unit = ( ( 'second' | 'minute' | 'hour' | 'day' ) 's'? )
        >StartTimeUnit %EndTimeUnit;

      time = digit+ >StartTime %EndTime;

      time_delay  = 'in' ws1 time ws0 time_unit     %EndTimeDelay;
      time_duration = 'for' ws1 time ws0 time_unit  %EndTimeDuration;

      time_selector = ( ( ws1 time_delay )? ( ws1 time_duration )? );

      command_name = ws0 'label' ws1 output ws1 'as' ws1 label ws0 eol
        @CommandName;

      command_on   = ws0 'turn on' ws1 relay_name_list_on time_selector ws0 eol
        @CommandOn;

      command_off  = ws0 'turn off' ws1 relay_name_list_off time_selector ws0 eol
        @CommandOff;

      command_set  = ws0 'set relay to' ws1 relay_name_list_on time_selector ws0 eol
        @CommandSet;

      main := ( /^#.*/ | command_name | command_on | command_off | command_set );

    }%%

    %% write data;

    def Parser.parse(data)
      # Tokens per line
      labels = []
      outputs = []
      time_unit_factor = 1
      time_delay = 0
      time_duration = 0

      %% write init;
      %% write exec;

      print "[ . ] Finished. The state of the machine is: #{cs} - p: #{p} pe: #{pe}\n\n" if $DEBUG
    end

    def Parser.get_lookup
      @label_lookup
    end

  end

  module Script
    def Script.load( input )
      include Licht::Parser
      licht = Licht::Script::ActionStack.new
      Licht::Parser.setup( licht )

      puts "[ ] Parsing commands:" if $_VERBOSE
      i=1
      input.each_line { |l| 
        print "[>] Line #{i}: #{l}" if $_VERBOSE
        Licht::Parser.parse(l)
        i += 1
      }

      if $DEBUG
        puts "[   ] Display actions:"
        licht.actions.each { |a| p a }
      end

      return licht
    end
  end
end
