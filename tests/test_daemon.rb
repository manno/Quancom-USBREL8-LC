#!/usr/bin/env ruby
$LOAD_PATH << './lib'
require "drb"
require 'lichtdaemon'
require 'lichtscript'

URL = 'druby://:9001'

def start_client( url= 'druby://:9001' )
  DRb.start_service()
  obj = DRbObject.new nil, url
  obj
end

script1 = <<-EOF 
turn on output 1
turn off output 2
EOF

script2 = <<-EOF 
turn on output 2 in 10 seconds for 10 seconds
turn off output 3
EOF

# start a daemon
#@server = Thread.start { 
#  Licht.start_daemon 
#}

# start the test client
#@client = Thread.start { 
  obj = start_client

  licht1 = Licht::Script.load( script1 )
  obj.addAction "one", licht1
  obj.addRule "one", Licht::ActionRuleIntervall.new( 12 )
  #sleep 5

  licht2 = Licht::Script.load( script2 )
  obj.addAction "two", licht2
  obj.addRule "two", Licht::ActionRulePiT.new( Time.now.to_i + 4 )
  #sleep 7

  #obj.remove( "two" )
  sleep 10

  #obj.addAction "clear", Licht::ClearQueueAction.new
  #obj.addRule "clear", Licht::ActionRulePiT.new( Time.now.to_i + 10 )
  #sleep 5

  puts obj.status
  
#}

# keep server running
#@server.join
