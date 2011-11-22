require 'quancom'
require 'drb'
$SIMULATOR_URL ||= 'druby://:9004'

# emulate quancom ffi lib
# 
module QAPI
  include QuancomConstants
  
  def QAPI.special( *args )
    puts "special( #{args.join(', ')} )"
  end

  def QAPI.openCard( *args )
    puts "openCard( #{args.join(', ')} )"
    DRb.start_service
    @simulator = DRbObject.new nil, $SIMULATOR_URL
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
    # translate bit position to int position (8=3)
    (1..8).each { |i| 
      if i >> relay == 0
        @simulator.setOut( i, state )
      end
    }
  end

  def QAPI.writeDO16( handle, arg1, output_mask, arg2 )
    puts "writeDO16( #{handle}, #{arg1}, #{output_mask}, #{arg2} )"
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
