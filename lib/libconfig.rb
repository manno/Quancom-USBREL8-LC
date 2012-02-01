module Licht
  module Config
    require 'yaml'
    def Config.setup(relative='')
      dir = File.join( Dir.pwd, relative )
      config_file = %w{ config.yaml config-example.yaml }.collect { |file| File.join( dir, file ) }.select { |file| File.readable? file }.first
      begin
        config = YAML::load( File.open( config_file ) )
      rescue
        STDERR.puts "failed to load #{config_file}"
      end
      $DAEMON_URL = defined?( config['daemon']['drb_url'] ) ? config['daemon']['drb_url'] : 'druby://127.0.0.1:9001'
      $SIMULATOR_URL = defined?( config['simulator']['drb_url'] ) ? config['simulator']['drb_url'] : 'druby://:9004'
      $TEST = true if config['daemon']['test']
    end
  end
end
