#!/usr/bin/env ruby
$LOAD_PATH << './lib'
require 'drb'

require 'libconfig'
Licht::Config::setup

$stdout.sync = true
$stderr.sync = true

require 'lichtdaemon'
@server = Thread.start { Licht.start_daemon $DAEMON_URL }
@server.join
