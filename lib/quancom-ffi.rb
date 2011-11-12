#!/usr/bin/ruby
require 'ffi'

=begin

USBREL8LC Minimum API

TODO find shared object?

=end

module QAPI
  extend FFI::Library
  ffi_lib './libqlib.so'
  ffi_convention :stdcall

  # CONSTANTS (qlib.h)
  TRUE = 1
  FALSE = 0
  OUT1 = 0x1
  OUT2 = 0x2
  OUT3 = 0x4
  OUT4 = 0x8
  OUT5 = 0x10
  OUT6 = 0x20
  OUT7 = 0x40
  OUT8 = 0x80
  ALL  = 1
  NONE = 0

  # QAPIExtOpenCard (quancom.h)
  USBREL8 = 6
  USBREL8LC = 8

  # QAPIExtSpecial
  JOB_READ_IN_FFS = 10
  JOB_GET_DEVICEID = 2

  # ULONG QAPIExtSpecial(int fd, ULONG jobcode, ULONG para1, ULONG para2);
  attach_function :special, :QAPIExtSpecial,[ :int, :ulong, :ulong, :ulong ], :ulong

  # int QAPIExtOpenCard(ULONG device, ULONG module);
  attach_function :openCard, :QAPIExtOpenCard,[ :ulong, :ulong ], :int

  # void QAPIExtWriteDO1 (int fd,ULONG channel,ULONG value,ULONG mode);
  attach_function :writeDO1, :QAPIExtWriteDO1,[ :int, :ulong, :ulong, :ulong ], :void

  # void QAPIExtWriteDO16 (int fd,ULONG channel,ULONG value,ULONG mode);
  attach_function :writeDO16, :QAPIExtWriteDO16,[ :int, :ulong, :ulong, :ulong ], :void

  # void  QAPIExtCloseCard(int handle);
  attach_function :closeCard, :QAPIExtCloseCard,[ :int ], :void

end

=begin

== no inputs on USBREL8LC
  
  # ULONG QAPIExtReadDI8 (int fd, ULONG channel, ULONG mode);
  attach_function :readDI8, :QAPIExtReadDI8,[ :int, :ulong, :ulong ], :ulong

== not in qlib?

  # ULONG QAPIPutDO ( ULONG cardid ULONG channel ULONG value );
  # ULONG QAPINumOfCards (void);
  # LPCARDDATAS QAPIGetCardInfo ( ULONG cardid );
  # ULONG QAPIGetCardInfoEx( ULONG cardid LPCARDDATAS lpcd );
  # ULONG QAPIExtNumOfCards (void);
  # LPCARDDATAS QAPIExtGetCardInfo( ULONG cardid );
  # ULONG QAPIExtGetCardInfoEx( ULONG cardid LPCARDDATAS lpcd );
  # void QAPIExtReleaseCardInfo( LPCARDDATAS carddatas );

=end

