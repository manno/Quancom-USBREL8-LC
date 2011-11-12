#!/usr/bin/env ruby
$LOAD_PATH << './lib'
$TEST = true
if $TEST
    require 'quancom-test'
else
    require 'quancom-ffi'
end

# open card
handle = QAPI.openCard QAPI::USBREL8LC, 0

if (handle > 0)

  # set line 4 high
  QAPI.writeDO1 handle, 5-1, QAPI::TRUE, 0
  #! set lines 4 and 7 high, rest low
  QAPI.writeDO16 handle, 0, QAPI::OUT4 + QAPI::OUT7, 0
  #! set all lines high
  QAPI.writeDO16 handle, 0, QAPI::ALL, 0

  # set line 4 low
  QAPI.writeDO1 handle, 5-1, QAPI::FALSE, 0
  #! set lines 4 and 7 low, rest high
  QAPI.writeDO16 handle, 0, QAPI::ALL - QAPI::OUT4 - QAPI::OUT7, 0
  # set all lines low
  QAPI.writeDO16 handle, 0, 0, 0

  # close
  QAPI.closeCard handle

end
