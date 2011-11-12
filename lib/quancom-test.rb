require 'quancom'
require 'pp'

# emulate quancom ffi lib
# 
module QAPI
  include QuancomConstants
  
  def QAPI.special( *args )
    puts "special( #{args.join(', ')} )"
  end
  def QAPI.openCard( *args )
    puts "openCard( #{args.join(', ')} )"
    1
  end
  def QAPI.writeDO1( *args )
    puts "writeDO1( #{args.join(', ')} )"
  end
  def QAPI.writeDO16( *args )
    puts "writeDO16( #{args.join(', ')} )"
  end
  def QAPI.closeCard( *args )
    puts "closeCard( #{args.join(', ')} )"
  end
end
