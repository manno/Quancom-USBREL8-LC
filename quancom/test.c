// main.c : Sample project for the USBOPTOREL16 and USBOPTO16IO Modules for Linux
//
// Author: Michael Reimer, QUANCOM Informationssysteme GmbH, Germany
//
// Copyright QUANCOM Informationssysteme GmbH, Germany
//
// Website: http://www.quancom.de
// Product:
// Linux USB Relay Module http://www.quancom.de/qprod01/eng/pb/usbrel8.htm
// Linux USB Opto Relay Module http://www.quancom.de/qprod01/eng/pb/usbrel8.htm
// Linux USB Opto I/O Module http://www.quancom.de/qprod01/eng/pb/usbrel8.htm
// Information:
//
// To use the QLIB Commands in your source, do the following:
//
// (1) Install the USB driver
// (2) Add file "qlib.c" to your makefile.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include "../qlib/qlib.h"
#include <sys/select.h>

int kbhit(void)
{
  struct timeval tv;
  fd_set read_fd;

  /* Do not wait at all, not even a microsecond */
  tv.tv_sec=0;
  tv.tv_usec=0;

  /* Must be done first to initialize read_fd */
  FD_ZERO(&read_fd);

  /* Makes select() ask if input is ready:
   * 0 is the file descriptor for stdin    */
  FD_SET(0,&read_fd);

  /* The first parameter is the number of the
   * largest file descriptor to check + 1. */
  if(select(1, &read_fd, NULL, NULL, &tv) == -1)
    return 0;   /* An error occured */

  /*    read_fd now holds a bit map of files that are
   * readable. We test the entry for the standard
   * input (file 0). */
  if(FD_ISSET(0,&read_fd))
    /* Character pending on stdin */
    return 1;

  /* no characters were pending */
  return 0;
}

int main(int argc, char **argv)
{
  ULONG handle;
  int ch;
  int j;      
  int di = FALSE;

  handle = QAPIExtOpenCard(USBREL8LC,0);


  //
  // If there are no modules terminate application
  //

  if ( handle == 0 )
  {
    printf("No USB Modules found!\n");
    return FALSE;
  }

  // Ok, we found a QUANCOM USB Module

  // ---------------------------------------------------------------------------
  // PART 1: Setting the outputs
  //
  // The following constants can be used to program the outputs:
  // ---------------------------------------------------------------------------

#define OUT1        0x1
#define OUT2        0x2
#define OUT3        0x4
#define OUT4        0x8
#define OUT5        0x10
#define OUT6        0x20
#define OUT7        0x40
#define OUT8        0x80

  ULONG lines = 0;

  //
  // Reset all lines to "Low"
  //

  printf("Reset all lines to 'Low' ( Press return to continue ):\n");

  QAPIExtWriteDO16(handle, 0, lines, 0);

  ch = getchar();

  //
  // Set the outputs OUT4,OUT7 to "High" ( 16-Bit )
  //

  printf("Set OUT4 and OUT7 to 'High' ( Press return to continue ):\n");

  lines = OUT4 + OUT7;

  QAPIExtWriteDO16(handle, 0, lines, 0);

  ch = getchar();

  //
  // Set the output OUT1, OUT4,OUT7 to "High" ( 16-Bit )
  //

  printf("Set OUT1, OUT4 and OUT7 to 'High' ( Press return to continue ):\n");

  lines = OUT1 + OUT4 + OUT7;

  QAPIExtWriteDO16(handle, 0, lines, 0);

  ch = getchar();

  //
  // Reset line OUT7 to "Low"
  //

  printf("Reset line OUT7 to 'Low' ( Press return to continue ):\n");

  QAPIExtWriteDO1(handle, 7 - 1, FALSE, 0);

  ch = getchar();

  //
  // Set line OUT5 to "High"
  //

  printf("Set line OUT5 to 'High' ( Press return to continue ):\n");

  QAPIExtWriteDO1(handle, 5 - 1, TRUE, 0);

  ch = getchar();

  //
  // Reset all lines to "Low"
  //

  printf("Reset all to 'Low' ( Press return to continue ):\n");

  lines = 0;

  QAPIExtWriteDO16(handle, 0, lines, 0);

  ch = getchar();

  QAPIExtCloseCard(handle);

  // TODO timers on USBREL8LC ?

  return 0;
}
