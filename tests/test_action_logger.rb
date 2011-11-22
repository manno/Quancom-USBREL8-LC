#!/usr/bin/env ruby
$LOAD_PATH << './lib'
require 'libconfig'
Licht::Config::setup

require 'lichtaction'
require 'lichtscript'

script1 = <<-EOF 
turn on output 1
turn on output 2
EOF
licht1 = Licht::Script.load( script1 )
p licht1
puts licht1.to_str


require 'lichtdaemon'
logger = Licht::Logger.new

licht1.actions.each { |action| 
  action.execute 0
  action.log_execute logger
}
