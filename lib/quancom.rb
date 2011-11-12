module QuancomConstants
  # CONSTANTS (qlib.h)
  TRUE = 1
  FALSE = 0
  MAXDEVICES = 8
  OUT1 = 0x1
  OUT2 = 0x2
  OUT3 = 0x4
  OUT4 = 0x8
  OUT5 = 0x10
  OUT6 = 0x20
  OUT7 = 0x40
  OUT8 = 0x80
  ALL  = OUT1+OUT2+OUT3+OUT4+OUT5+OUT6+OUT7+OUT8
  NONE = 0

  # QAPIExtOpenCard (quancom.h)
  USBREL8 = 6
  USBREL8LC = 8

  # QAPIExtSpecial
  JOB_GET_DEVICEID          = 2
  JOB_READ_IN_FFS           = 10
  JOB_ENABLE_TIMEOUT        = 11
  JOB_DISABLE_TIMEOUT       = 12
  JOB_RESET_TIMEOUT_STATUS  = 13
  JOB_READ_TIMEOUT_STATUS   = 14
  JOB_TIMEOUT               = 92
end
