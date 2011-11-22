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

  # Return >0 if i is in bitfield
  # => 0
  #
  def QAPI.checkBitSet( i, bitfield )
    bitfield & (1<<i)
  end

  def QAPI.writeDO1( handle, relay, state, arg )
    puts "writeDO1( #{handle}, #{relay}, #{state}, #{arg} )"
    return unless defined? @simulator
    @simulator.setOut( relay+1, state )
  end

  def QAPI.writeDO16( handle, arg1, output_mask, arg2 )
    puts "writeDO16( #{handle}, #{arg1}, #{output_mask}, #{arg2} )"
    return unless defined? @simulator
    (0..7).each { |i| 
      relay = i + 1
      if checkBitSet( i, output_mask ) > 0
        @simulator.setOut( relay, true )
      else
        @simulator.setOut( relay, false )
      end
    }
  end

  def QAPI.closeCard( *args )
    puts "closeCard( #{args.join(', ')} )"
    @simulator = nil
  end
end
