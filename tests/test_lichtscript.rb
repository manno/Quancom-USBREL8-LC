#!/usr/bin/env ruby
$LOAD_PATH << './lib'
require 'lichtscript'
require 'pp'

script = <<-EOF
label output 3 as Bathroom
turn off Bathroom
turn off all outputs
turn off all outputs in 1 minute
turn on output1 
turn on output 1 
turn on output 1, Bathroom, output 2
turn off output 1, Bathroom, output 2
turn on Bathroom
turn on Bathroom in 5 minutes for 45 seconds
turn on Bathroom in 1 hour 
set relay to output 1, Bathroom, output 2
EOF


licht = Licht::Script.load( script )

#handle = QAPI.openCard QAPI::USBREL8LC, 0
#exit unless handle > -1
handle = 1

licht.actions.each { |a|
  p a
  a.execute handle
}
