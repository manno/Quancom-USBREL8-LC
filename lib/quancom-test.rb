require 'quancom'
require 'pp'

# emulate quancom ffi lib
# 
module QAPI
  include QuancomConstants
  
  def QAPI.special( *args )
    pp args
  end
  def QAPI.openCard( *args )
    pp args
    1
  end
  def QAPI.writeDO1( *args )
    pp args
  end
  def QAPI.writeDO16( *args )
    pp args
  end
  def QAPI.closeCard( *args )
    pp args
  end
end
