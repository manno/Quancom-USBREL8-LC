#!/usr/bin/env ruby
$LOAD_PATH << './lib'
require 'libconfig'
Licht::Config::setup

require "drb"
require 'lichtdaemon'
require 'lichtscript'

def start_client( url= 'druby://:9001' )
  DRb.start_service()
  obj = DRbObject.new nil, url
  obj
end

script1 = <<-EOF 
turn off output 1
turn on output 5 for 10 seconds
turn off output 8
EOF

script2 = <<-EOF 
turn on output 1
turn on output 2 in 10 seconds for 10 seconds
turn on output 3
turn on output 4
turn on output 5
turn on output 6
turn on output 7
turn on output 8
EOF

# start a daemon
#@server = Thread.start { 
#  Licht.start_daemon 
#}

# start the test client
#@client = Thread.start { 
  obj = start_client

  licht1 = Licht::Script.load( script1 )
  obj.addScript "one", licht1
  obj.addRule "one", Licht::Rule::RuleInterval.new( 12 )
  #sleep 5

  licht2 = Licht::Script.load( script2 )
  obj.addScript "two", licht2
  obj.addRule "two", Licht::Rule::RulePiT.new( Time.now.to_i + 4 )
  sleep 7

  #obj.remove( "two" )
  #sleep 10

  obj.addScript "clear", Licht::Script::ClearQueueAction.new
  obj.addRule "clear", Licht::Rule::RulePiT.new( Time.now.to_i + 10 )
  sleep 5

  puts obj.status
  
#}

# keep server running
#@server.join
