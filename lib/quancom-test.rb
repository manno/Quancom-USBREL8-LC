require 'quancom'
require 'drb'
require 'pp'

# emulate quancom ffi lib
# 
module QAPI
  include QuancomConstants
  URL = 'druby://:9004'
  
  def QAPI.special( *args )
    puts "special( #{args.join(', ')} )"
  end

  def QAPI.openCard( *args )
    puts "openCard( #{args.join(', ')} )"
    DRb.start_service
    @simulator = DRbObject.new nil, URL
    begin
      @simulator.respond_to? 'setOut'
    rescue
      @simulator = nil
      STDERR.puts "[!] failed to connect to simulator"
      return -1
    end
    return 1
  end

  def QAPI.writeDO1( handle, relay, state, arg )
    puts "writeDO1( #{handle}, #{relay}, #{state}, #{arg} )"
    return unless defined? @simulator
    @simulator.setOut( relay, state )
  end

  def QAPI.writeDO16( handle, output_mask, arg )
    puts "writeDO16( #{handle}, #{output_mask}, #{arg} )"
    return unless defined? @simulator
    (1..8).each { |i| 
      if i >> output_mask == 0
        @simulator.setOut( i, true )
      else
        @simulator.setOut( i, false )
      end
    }
  end

  def QAPI.closeCard( *args )
    puts "closeCard( #{args.join(', ')} )"
    @simulator = nil
  end
end
