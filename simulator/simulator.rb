#!/usr/bin/env ruby
#
require 'gtk2'
require "drb"

$LOAD_PATH << 'lib'
require 'libconfig'
Licht::Config::setup

PROG_NAME = 'quancom simulator'
DEFAULT_GLADE = 'gui.glade'
DEFAULT_IMAGE = "usbrel8.gif"
resource_path = './simulator'

module Licht
  module Simulator
    module Callbacks
      def on_reset
        reset_outputs
      end
    end

  class Controller
    include Callbacks

    def initialize( resource_path )
      @resource_path = resource_path
      @builder = Gtk::Builder.new
      @builder.add_from_file( File.join( @resource_path, DEFAULT_GLADE ))
      @builder.connect_signals { |handler| method( handler ) }
    end
    attr_reader :builder

    def setup
      trap('INT') { self.quit }
      DRb.start_service $SIMULATOR_URL, self
      #DRb.thread.join
      
      image_path = File.join( @resource_path, DEFAULT_IMAGE )
      if File.readable? image_path
        img = Gdk::Pixbuf.new( image_path, 200, 200 )
        @builder["image1"].pixbuf = img
      end

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
@gui = Licht::Simulator::Controller.new( resource_path )
@gui.setup
@gui.builder['window1'].show
Thread.start {
  @gui.run
}
Gtk.main

