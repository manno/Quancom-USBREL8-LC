#!/usr/bin/env ruby
#
require 'gtk2'
require "drb"

PROG_NAME = 'quancom simulator'
URL = 'druby://:9004'
DEFAULT_GLADE_FILENAME = 'gui.glade'
DEFAULT_GLADE = File.join( 'simulator', DEFAULT_GLADE_FILENAME )
DEFAULT_IMAGE = "usbrel8.gif"

glade_file = DEFAULT_GLADE_FILENAME
if( File.readable? DEFAULT_GLADE )
  glade_file = DEFAULT_GLADE
end

module Licht
  module Simulator
    module Callbacks
      def on_reset
        reset_outputs
      end
    end

  class Controller
    include Callbacks

    def initialize( glade_file )
      #@glade = GladeXML.new(glade_file, nil, PROG_NAME, nil, GladeXML::FILE) {|handler| method(handler)}
      @builder = Gtk::Builder.new
      @builder.add_from_file( glade_file )
      @builder.connect_signals { |handler| method(handler) }
    end
    attr_reader :builder

    def setup
      trap('INT') { self.quit }
      DRb.start_service URL, self
      #DRb.thread.join
      img = Gdk::Pixbuf.new(DEFAULT_IMAGE, 200, 200)
      @builder["image1"].pixbuf = img
      reset_outputs
    end

    def reset_outputs
      (1..8).each { |i|
        @builder["checkbutton#{i}"].active = false
      }
    end

    def quit
      puts "quit application"
      Gtk.main_quit
    end

    # for drb, set Output 1..8
    def setOut( i, state )
      state = state == 1
      puts "set state #{state} for #{i}"
      @builder["checkbutton#{i}"].active = state
    end
  end

  end
end

Gtk.init
@gui = Licht::Simulator::Controller.new(glade_file)
@gui.setup
@gui.builder['window1'].show
Thread.start {
  @gui.run
}
Gtk.main

