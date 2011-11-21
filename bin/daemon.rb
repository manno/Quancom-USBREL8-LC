#!/usr/bin/env ruby
$LOAD_PATH << './lib'
require 'drb'
require 'yaml'

config_file = File.readable?( 'config.yaml' ) ? 'config.yaml' : 'config-example.yaml'
config = YAML::load( File.open( config_file ) )
@url = sprintf 'druby://%s:%s',
  config['daemon']['listen_host'] || '127.0.0.1', config['daemon']['listen_port'] || '9001'

if config['daemon']['test']
    $TEST = true
end
require 'lichtdaemon'

@server = Thread.start { Licht.start_daemon @url }
@server.join
