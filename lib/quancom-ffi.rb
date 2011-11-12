#!/usr/bin/ruby
require 'ffi'
require 'quancom'

=begin

USBREL8LC Minimum API

TODO find shared object?

=end

module QAPI
  include QuancomConstants
  extend FFI::Library
  ffi_lib './libqlib.so'
  ffi_convention :stdcall


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

