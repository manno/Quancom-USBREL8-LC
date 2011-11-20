#!/usr/bin/env ruby
$LOAD_PATH << './lib'



require 'lichtaction'
rule1 = Licht::Rule::ActionRuleIntervall.new( 12 )
rule2 = Licht::Rule::ActionRulePiT.new( Time.now.to_i )
rule1.apply( Time.now.to_i )
rule2.apply( Time.now.to_i )


require 'lichtscript'
script1 = <<-EOF 
turn on output 1
EOF
script2 = <<-EOF 
turn on output 1
EOF
licht1 = Licht::Script.load( script1 )
licht2 = Licht::Script.load( script2 )

require 'lichtdaemon'
obj = Licht::Daemon.new
obj.addScript "one", licht1
obj.addRule "one", rule1
obj.addScript "two", licht2
obj.addRule "two", rule2
thread = obj.start_thread
thread.join

