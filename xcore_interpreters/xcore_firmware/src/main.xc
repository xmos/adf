// Copyright 2021 XMOS LIMITED. This Software is subject to the terms of the
// XMOS Public License: Version 1

// Workaround the "-D_clock_defined" workaround for tools bug id=18509
//   that is implemented in the CMakeLists.txt.
//   .xc files that include platform.h will not compile if _clock_defined
//   is defined.  The undef must occur before including platform.h or other
//   plaform specific headers.
#ifdef _clock_defined
#undef _clock_defined
#endif

#include <platform.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <xscope.h>

extern "C" {
void xscope_main();
void xscope_data_recv(void *data, size_t size);
}

unsafe {
  void process_xscope(chanend xscope_data_in) {
    int bytes_read = 0;
    unsigned char buffer[256];

    xscope_connect_data_from_host(xscope_data_in);
    xscope_mode_lossless();
    while (1) {
      select {
        case xscope_data_from_host(xscope_data_in, buffer, bytes_read):
          xscope_data_recv(buffer, bytes_read);
          break;
      }
    }
  }
}

int main(void) {
  chan xscope_data_in;
  par {
    xscope_host_data(xscope_data_in);
    on tile[0] : {
      xscope_main();
      process_xscope(xscope_data_in);
    }
  }

  return 0;
}