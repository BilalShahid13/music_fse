#ifndef MPRIS_HANDLER_H_
#define MPRIS_HANDLER_H_

#include <flutter_linux/flutter_linux.h>

// Initialises the MPRIS D-Bus service and wires it to the given Flutter
// binary messenger so that Dart-side method channel calls are handled.
void mpris_handler_init(FlBinaryMessenger* messenger);

// Cleans up the MPRIS D-Bus registration.
void mpris_handler_cleanup();

#endif // MPRIS_HANDLER_H_
