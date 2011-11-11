#!/usr/bin/ruby
# vim: ft=ragel
require 'lichtcontrol'

$VERBOSE=1

module Licht
  module Parser

    def controller( c )
      @controller = c
    end

    # label relay 1 Bad
    # turn off Bad
    # turn off all relays
    # turn off all relays after 1 minute
    # turn on relay 1 
    # turn on Bad
    # turn on Bad in 5 minutes for 45 seconds
    # turn on Bad in 1 hour 
    %%{
      machine licht;

      action CommandStart { }
      action CommandEnd { 
      }

      action OnCommand {
        @controller.add( )
      }
      action OffCommand {
        @controller.add( )
      }
      action NameCommand {
        @controller.add( )
      }

      ws1 = ' '+;
      ws0 = ' '{0,};

      command_name = ( register ws1 'mv'   ws1 filename ws1 filename ws0 '\n' ) @NameCommand;
      command_on = ( register ws1 'calc' ws1 filename ws1 operator ws0 increment ws0 '\n' ) @OnCommand;
      command_off = ( register ws1 'calc' ws1 filename ws1 operator ws0 increment ws0 '\n' ) @OffCommand;
      main := ( /^#.*/ | command_name | command_on | command_off );


    }%%

    %% write data;

    def parse(data)
      # States
      #@outputs = []
      #stack = []

      %% write init;
      %% write exec;

      print "Finished. The state of the machine is: #{cs} - p: #{p} pe: #{pe}" if $DEBUG
      #@outputs.clear
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
