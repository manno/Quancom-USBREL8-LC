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
EOF

script2 = <<-EOF 
turn on output 1
EOF

# start a daemon
#@server = Thread.start { 
#  Licht.start_daemon 
#}

# start the test client
#@client = Thread.start { 
  obj = start_client

  licht1 = Licht::Script.load( script1 )
  obj.addActionStack "one", licht1
  obj.addRule "one", Licht::ActionRuleIntervall.new( 12 )
  obj.addActionStack "oneone", licht1
  obj.addRule "oneone", Licht::ActionRuleIntervall.new( 12 )
  sleep 5

  licht2 = Licht::Script.load( script2 )
  obj.addActionStack "two", licht2
  obj.addRule "two", Licht::ActionRulePiT.new( Time.now.to_i + 4 )
  sleep 7

  obj.remove( "two" )
  sleep 10

  puts obj.status
  
#}

# keep server running
#@server.join
