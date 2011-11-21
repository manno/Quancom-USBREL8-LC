#!/usr/bin/env ruby
$LOAD_PATH << './lib'
require 'drb'
require 'yaml'

config_file = File.readable?( 'config.yaml' ) ? 'config.yaml' : 'config-example.yaml'
config = YAML::load( File.open( config_file ) )
@url = defined?( config['daemon']['drb_url'] ) ? config['daemon']['drb_url'] : 'druby://127.0.0.1:9001'
$TEST = true if config['daemon']['test']

require 'lichtdaemon'
@server = Thread.start { Licht.start_daemon @url }
@server.join
