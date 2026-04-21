#ifndef FLUTTER_MY_APPLICATION_H_
#define FLUTTER_MY_APPLICATION_H_

#include <gtk/gtk.h>

G_DECLARE_FINAL_TYPE(MyApplication,
                     my_application,
                     MY,
                     APPLICATION,
                     GtkApplication)

/**
 * my_application_new:
 *
 * Creates a new Flutter-based application.
 *
 * Returns: a new #MyApplication.
 */
MyApplication* my_application_new();

/**
 * my_application_dispatch_open_file:
 * @self: application instance.
 * @file_path: absolute path of the file to open.
 *
 * Forwards a file-open request to the running Flutter layer.
 */
void my_application_dispatch_open_file(MyApplication* self,
                                       const gchar* file_path);

#endif  // FLUTTER_MY_APPLICATION_H_
