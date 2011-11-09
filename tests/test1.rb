require 'lib/quancom-ffi.rb'
=begin

TEST

=end

# open card
handle = QAPI.openCard QAPI::USBREL8LC, 0

if (handle > 0)

  # set lines high
  QAPI.writeDO1 handle, 5-1, QAPI::TRUE, 0
  QAPI.writeDO16 handle, 0, QAPI::OUT4 + QAPI::OUT7, 0

  # set lines low
  QAPI.writeDO16 handle, 0, 0, 0

  # close
  QAPI.closeCard handle

end
