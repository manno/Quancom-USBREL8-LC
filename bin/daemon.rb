#!/usr/bin/env ruby
$LOAD_PATH << './lib'
require "drb"
require 'lichtdaemon'

URL = 'druby://127.0.0.1:9001'

@server = Thread.start { 
  Licht.start_daemon 
}

@server.join
