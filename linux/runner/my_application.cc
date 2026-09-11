#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include <string>
#include <vector>

#include "flutter/generated_plugin_registrant.h"
#include "mpris_handler.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
  GtkWindow* window;
  FlMethodChannel* file_association_channel;
  bool file_association_ready;
  std::string launch_file_path;
  std::vector<std::string> pending_file_requests;
};

namespace {

constexpr char kFileAssociationChannelName[] =
    "com.musicfse.player/file_association";

std::string get_first_file_argument(GApplicationCommandLine* command_line,
                                    gchar** argv,
                                    int argc) {
  for (int i = 1; i < argc; ++i) {
    const gchar* argument = argv[i];
    if (argument == nullptr || argument[0] == '\0' || argument[0] == '-') {
      continue;
    }

    g_autoptr(GFile) file =
        g_application_command_line_create_file_for_arg(command_line, argument);
    if (file == nullptr) {
      continue;
    }

    g_autofree gchar* path = g_file_get_path(file);
    if (path != nullptr && path[0] != '\0') {
      return std::string(path);
    }
  }

  return std::string();
}

void file_association_method_call_handler(FlMethodChannel* channel,
                                          FlMethodCall* method_call,
                                          gpointer user_data) {
  MyApplication* self = MY_APPLICATION(user_data);
  const gchar* method = fl_method_call_get_name(method_call);

  if (g_strcmp0(method, "getLaunchFilePath") == 0) {
    self->file_association_ready = true;
    g_autoptr(FlValue) result_value = nullptr;
    if (self->launch_file_path.empty()) {
      result_value = fl_value_new_null();
    } else {
      result_value = fl_value_new_string(self->launch_file_path.c_str());
    }
    self->launch_file_path.clear();

    g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(
        fl_method_success_response_new(result_value));
    fl_method_call_respond(method_call, response, nullptr);
    return;
  }

  if (g_strcmp0(method, "consumePendingFilePaths") == 0) {
    self->file_association_ready = true;
    g_autoptr(FlValue) result_value = fl_value_new_list();
    for (const auto& file_path : self->pending_file_requests) {
      fl_value_append_take(result_value,
                           fl_value_new_string(file_path.c_str()));
    }
    self->pending_file_requests.clear();

    g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(
        fl_method_success_response_new(result_value));
    fl_method_call_respond(method_call, response, nullptr);
    return;
  }

  g_autoptr(FlMethodResponse) response =
      FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  fl_method_call_respond(method_call, response, nullptr);
}

void set_up_file_association_channel(MyApplication* self,
                                     FlBinaryMessenger* messenger) {
  if (self->file_association_channel != nullptr) {
    return;
  }

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  self->file_association_channel = fl_method_channel_new(
      messenger, kFileAssociationChannelName, FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      self->file_association_channel, file_association_method_call_handler,
      self, nullptr);
}

void queue_or_dispatch_file_request(MyApplication* self,
                                    const std::string& file_path) {
  if (file_path.empty()) {
    return;
  }

  if (self->file_association_channel == nullptr ||
      !self->file_association_ready) {
    if (self->launch_file_path.empty()) {
      self->launch_file_path = file_path;
    } else {
      self->pending_file_requests.push_back(file_path);
    }
    return;
  }

  fl_method_channel_invoke_method(
      self->file_association_channel, "openFile",
      fl_value_new_string(file_path.c_str()), nullptr, nullptr, nullptr);
}

void on_window_destroy(GtkWidget* widget, gpointer user_data) {
  MyApplication* self = MY_APPLICATION(user_data);
  self->window = nullptr;
}

}  // namespace

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Called when first Flutter frame received.
static void first_frame_cb(MyApplication* self, FlView* view) {
  gtk_widget_show(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  if (self->window != nullptr) {
    gtk_window_present(self->window);
    return;
  }

  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
  self->window = window;
  g_signal_connect(window, "destroy", G_CALLBACK(on_window_destroy), self);

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "Music FSE");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "Music FSE");
  }

  gtk_window_set_default_size(window, 1280, 720);

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  GdkRGBA background_color;
  // Background defaults to black, override it here if necessary, e.g. #00000000
  // for transparent.
  gdk_rgba_parse(&background_color, "#000000");
  fl_view_set_background_color(view, &background_color);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  // Show the window when Flutter renders.
  // Requires the view to be realized so we can start rendering.
  g_signal_connect_swapped(view, "first-frame", G_CALLBACK(first_frame_cb),
                           self);
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  // Initialize MPRIS D-Bus handler
  FlEngine* engine = fl_view_get_engine(view);
  FlBinaryMessenger* messenger = fl_engine_get_binary_messenger(engine);
  mpris_handler_init(messenger);
  set_up_file_association_channel(self, messenger);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::command_line.
static int my_application_command_line(GApplication* application,
                                       GApplicationCommandLine* command_line) {
  MyApplication* self = MY_APPLICATION(application);
  int argc = 0;
  gchar** argv = g_application_command_line_get_arguments(command_line, &argc);

  if (self->dart_entrypoint_arguments == nullptr) {
    self->dart_entrypoint_arguments = g_strdupv(argv + 1);
  }

  const std::string file_path =
      get_first_file_argument(command_line, argv, argc);
  if (!file_path.empty()) {
    queue_or_dispatch_file_request(self, file_path);
  }

  g_strfreev(argv);

  g_application_activate(application);
  return 0;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);

  // Clean up MPRIS D-Bus registration.
  mpris_handler_cleanup();

  g_clear_object(&self->file_association_channel);
  self->pending_file_requests.clear();
  self->launch_file_path.clear();

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  g_clear_object(&self->file_association_channel);
  self->window = nullptr;
  self->pending_file_requests.clear();
  self->launch_file_path.clear();
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->command_line = my_application_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {
  self->window = nullptr;
  self->file_association_channel = nullptr;
  self->file_association_ready = false;
}

MyApplication* my_application_new() {
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_HANDLES_COMMAND_LINE,
                                     nullptr));
}

void my_application_dispatch_open_file(MyApplication* self,
                                       const gchar* file_path) {
  if (self == nullptr || file_path == nullptr || file_path[0] == '\0') {
    return;
  }

  queue_or_dispatch_file_request(self, std::string(file_path));
  if (self->window != nullptr) {
    gtk_window_present(self->window);
  }
}
