#include "mpris_handler.h"

#include <gio/gio.h>
#include <cstring>
#include <string>

// ---------------------------------------------------------------------------
// MPRIS D-Bus introspection XML
// ---------------------------------------------------------------------------

static const gchar kMprisIntrospection[] =
    "<node>"
    "  <interface name='org.mpris.MediaPlayer2'>"
    "    <property name='Identity' type='s' access='read'/>"
    "    <property name='CanQuit' type='b' access='read'/>"
    "    <property name='CanRaise' type='b' access='read'/>"
    "    <property name='HasTrackList' type='b' access='read'/>"
    "    <method name='Quit'/>"
    "    <method name='Raise'/>"
    "  </interface>"
    "  <interface name='org.mpris.MediaPlayer2.Player'>"
    "    <method name='Play'/>"
    "    <method name='Pause'/>"
    "    <method name='PlayPause'/>"
    "    <method name='Stop'/>"
    "    <method name='Next'/>"
    "    <method name='Previous'/>"
    "    <property name='PlaybackStatus' type='s' access='read'/>"
    "    <property name='Metadata' type='a{sv}' access='read'/>"
    "    <property name='CanPlay' type='b' access='read'/>"
    "    <property name='CanPause' type='b' access='read'/>"
    "    <property name='CanGoNext' type='b' access='read'/>"
    "    <property name='CanGoPrevious' type='b' access='read'/>"
    "  </interface>"
    "</node>";

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

struct MprisState {
  FlMethodChannel* channel = nullptr;
  guint bus_name_id = 0;
  GDBusConnection* connection = nullptr;
  guint root_reg_id = 0;
  guint player_reg_id = 0;
  GDBusNodeInfo* node_info = nullptr;

  // Current metadata
  std::string title;
  std::string artist;
  std::string album;
  std::string art_uri;
  gint64 duration_us = 0;  // microseconds
  bool is_playing = false;
};

static MprisState g_state;

// ---------------------------------------------------------------------------
// Property helpers
// ---------------------------------------------------------------------------

static GVariant* build_metadata_variant() {
  GVariantBuilder builder;
  g_variant_builder_init(&builder, G_VARIANT_TYPE("a{sv}"));

  g_variant_builder_add(&builder, "{sv}", "xesam:title",
                        g_variant_new_string(g_state.title.c_str()));
  g_variant_builder_add(&builder, "{sv}", "xesam:artist",
                        g_variant_new(
                            "as", g_variant_new_string(g_state.artist.c_str())));

  // xesam:artist must be an array of strings
  GVariantBuilder artist_builder;
  g_variant_builder_init(&artist_builder, G_VARIANT_TYPE("as"));
  g_variant_builder_add(&artist_builder, "s", g_state.artist.c_str());

  // Rebuild properly
  g_variant_builder_init(&builder, G_VARIANT_TYPE("a{sv}"));
  g_variant_builder_add(&builder, "{sv}", "xesam:title",
                        g_variant_new_string(g_state.title.c_str()));
  g_variant_builder_add(&builder, "{sv}", "xesam:artist",
                        g_variant_builder_end(&artist_builder));
  g_variant_builder_add(&builder, "{sv}", "xesam:album",
                        g_variant_new_string(g_state.album.c_str()));
  g_variant_builder_add(&builder, "{sv}", "mpris:length",
                        g_variant_new_int64(g_state.duration_us));

  if (!g_state.art_uri.empty()) {
    g_variant_builder_add(&builder, "{sv}", "mpris:artUrl",
                          g_variant_new_string(g_state.art_uri.c_str()));
  }

  return g_variant_builder_end(&builder);
}

static void emit_properties_changed(const gchar* interface_name,
                                    GVariant* changed_properties) {
  if (g_state.connection == nullptr) return;

  g_dbus_connection_emit_signal(
      g_state.connection, nullptr, "/org/mpris/MediaPlayer2",
      "org.freedesktop.DBus.Properties", "PropertiesChanged",
      g_variant_new("(sa{sv}as)", interface_name, changed_properties, nullptr),
      nullptr);
}

// ---------------------------------------------------------------------------
// D-Bus method handlers
// ---------------------------------------------------------------------------

static void handle_root_method(GDBusConnection*,
                               const gchar*,
                               const gchar*,
                               const gchar*,
                               const gchar* method_name,
                               GVariant*,
                               GDBusMethodInvocation* invocation,
                               gpointer) {
  if (g_strcmp0(method_name, "Quit") == 0) {
    // Forward to Dart
    fl_method_channel_invoke_method(
        g_state.channel, "stop", nullptr, nullptr, nullptr, nullptr);
    g_dbus_method_invocation_return_value(invocation, nullptr);
  } else if (g_strcmp0(method_name, "Raise") == 0) {
    g_dbus_method_invocation_return_value(invocation, nullptr);
  } else {
    g_dbus_method_invocation_return_dbus_error(
        invocation, "org.mpris.MediaPlayer2.Error", "Not implemented");
  }
}

static GVariant* handle_root_get_property(GDBusConnection*,
                                          const gchar*,
                                          const gchar*,
                                          const gchar*,
                                          const gchar* property_name,
                                          GError**,
                                          gpointer) {
  if (g_strcmp0(property_name, "Identity") == 0)
    return g_variant_new_string("Music FSE");
  if (g_strcmp0(property_name, "CanQuit") == 0)
    return g_variant_new_boolean(TRUE);
  if (g_strcmp0(property_name, "CanRaise") == 0)
    return g_variant_new_boolean(FALSE);
  if (g_strcmp0(property_name, "HasTrackList") == 0)
    return g_variant_new_boolean(FALSE);
  return nullptr;
}

static void handle_player_method(GDBusConnection*,
                                 const gchar*,
                                 const gchar*,
                                 const gchar*,
                                 const gchar* method_name,
                                 GVariant*,
                                 GDBusMethodInvocation* invocation,
                                 gpointer) {
  const gchar* dart_method = nullptr;
  if (g_strcmp0(method_name, "Play") == 0)
    dart_method = "play";
  else if (g_strcmp0(method_name, "Pause") == 0)
    dart_method = "pause";
  else if (g_strcmp0(method_name, "PlayPause") == 0)
    dart_method = "playPause";
  else if (g_strcmp0(method_name, "Stop") == 0)
    dart_method = "stop";
  else if (g_strcmp0(method_name, "Next") == 0)
    dart_method = "next";
  else if (g_strcmp0(method_name, "Previous") == 0)
    dart_method = "previous";

  if (dart_method != nullptr) {
    fl_method_channel_invoke_method(
        g_state.channel, dart_method, nullptr, nullptr, nullptr, nullptr);
  }

  g_dbus_method_invocation_return_value(invocation, nullptr);
}

static GVariant* handle_player_get_property(GDBusConnection*,
                                            const gchar*,
                                            const gchar*,
                                            const gchar*,
                                            const gchar* property_name,
                                            GError**,
                                            gpointer) {
  if (g_strcmp0(property_name, "PlaybackStatus") == 0)
    return g_variant_new_string(g_state.is_playing ? "Playing" : "Paused");
  if (g_strcmp0(property_name, "Metadata") == 0)
    return build_metadata_variant();
  if (g_strcmp0(property_name, "CanPlay") == 0)
    return g_variant_new_boolean(TRUE);
  if (g_strcmp0(property_name, "CanPause") == 0)
    return g_variant_new_boolean(TRUE);
  if (g_strcmp0(property_name, "CanGoNext") == 0)
    return g_variant_new_boolean(TRUE);
  if (g_strcmp0(property_name, "CanGoPrevious") == 0)
    return g_variant_new_boolean(TRUE);
  return nullptr;
}

// ---------------------------------------------------------------------------
// D-Bus vtables
// ---------------------------------------------------------------------------

static const GDBusInterfaceVTable kRootVTable = {
    handle_root_method,
    handle_root_get_property,
    nullptr,
    {nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr}};

static const GDBusInterfaceVTable kPlayerVTable = {
    handle_player_method,
    handle_player_get_property,
    nullptr,
    {nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr}};

// ---------------------------------------------------------------------------
// Bus acquired callback
// ---------------------------------------------------------------------------

static void on_bus_acquired(GDBusConnection* connection, const gchar*,
                            gpointer) {
  g_state.connection = connection;

  GError* error = nullptr;

  g_state.root_reg_id = g_dbus_connection_register_object(
      connection, "/org/mpris/MediaPlayer2",
      g_state.node_info->interfaces[0], &kRootVTable, nullptr, nullptr, &error);
  if (error) {
    g_warning("MPRIS: failed to register root: %s", error->message);
    g_error_free(error);
  }

  error = nullptr;
  g_state.player_reg_id = g_dbus_connection_register_object(
      connection, "/org/mpris/MediaPlayer2",
      g_state.node_info->interfaces[1], &kPlayerVTable, nullptr, nullptr,
      &error);
  if (error) {
    g_warning("MPRIS: failed to register player: %s", error->message);
    g_error_free(error);
  }
}

static void on_name_acquired(GDBusConnection*, const gchar*, gpointer) {}
static void on_name_lost(GDBusConnection*, const gchar*, gpointer) {}

// ---------------------------------------------------------------------------
// Method channel handler (Dart → native)
// ---------------------------------------------------------------------------

static void method_call_handler(FlMethodChannel* channel,
                                FlMethodCall* method_call,
                                gpointer) {
  const gchar* method = fl_method_call_get_name(method_call);

  if (g_strcmp0(method, "registerMpris") == 0) {
    // Already registered in init; just respond OK
    g_autoptr(FlMethodResponse) response =
        FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null()));
    fl_method_call_respond(method_call, response, nullptr);
  } else if (g_strcmp0(method, "updateMetadata") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* v;
      v = fl_value_lookup_string(args, "title");
      if (v) g_state.title = fl_value_get_string(v);
      v = fl_value_lookup_string(args, "artist");
      if (v) g_state.artist = fl_value_get_string(v);
      v = fl_value_lookup_string(args, "album");
      if (v) g_state.album = fl_value_get_string(v);
      v = fl_value_lookup_string(args, "artUri");
      if (v && fl_value_get_type(v) == FL_VALUE_TYPE_STRING)
        g_state.art_uri = fl_value_get_string(v);
      else
        g_state.art_uri.clear();
      v = fl_value_lookup_string(args, "durationMs");
      if (v) g_state.duration_us = fl_value_get_int(v) * 1000LL;
    }

    // Emit PropertiesChanged for Metadata
    GVariantBuilder changed;
    g_variant_builder_init(&changed, G_VARIANT_TYPE("a{sv}"));
    g_variant_builder_add(&changed, "{sv}", "Metadata",
                          build_metadata_variant());
    emit_properties_changed("org.mpris.MediaPlayer2.Player",
                            g_variant_builder_end(&changed));

    g_autoptr(FlMethodResponse) response =
        FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null()));
    fl_method_call_respond(method_call, response, nullptr);
  } else if (g_strcmp0(method, "updatePlaybackStatus") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* v = fl_value_lookup_string(args, "isPlaying");
      if (v) g_state.is_playing = fl_value_get_bool(v);
    }

    GVariantBuilder changed;
    g_variant_builder_init(&changed, G_VARIANT_TYPE("a{sv}"));
    g_variant_builder_add(&changed, "{sv}", "PlaybackStatus",
                          g_variant_new_string(
                              g_state.is_playing ? "Playing" : "Paused"));
    emit_properties_changed("org.mpris.MediaPlayer2.Player",
                            g_variant_builder_end(&changed));

    g_autoptr(FlMethodResponse) response =
        FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null()));
    fl_method_call_respond(method_call, response, nullptr);
  } else {
    g_autoptr(FlMethodResponse) response =
        FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
    fl_method_call_respond(method_call, response, nullptr);
  }
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

void mpris_handler_init(FlBinaryMessenger* messenger) {
  g_state.node_info =
      g_dbus_node_info_new_for_xml(kMprisIntrospection, nullptr);

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_state.channel = fl_method_channel_new(
      messenger, "com.musicfse.player/mpris",
      FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(g_state.channel,
                                            method_call_handler, nullptr,
                                            nullptr);

  g_state.bus_name_id = g_bus_own_name(
      G_BUS_TYPE_SESSION, "org.mpris.MediaPlayer2.MusicFSE",
      G_BUS_NAME_OWNER_FLAGS_NONE, on_bus_acquired, on_name_acquired,
      on_name_lost, nullptr, nullptr);
}

void mpris_handler_cleanup() {
  if (g_state.bus_name_id > 0) {
    g_bus_unown_name(g_state.bus_name_id);
    g_state.bus_name_id = 0;
  }
  if (g_state.connection) {
    if (g_state.root_reg_id > 0)
      g_dbus_connection_unregister_object(g_state.connection,
                                          g_state.root_reg_id);
    if (g_state.player_reg_id > 0)
      g_dbus_connection_unregister_object(g_state.connection,
                                          g_state.player_reg_id);
  }
  if (g_state.node_info) {
    g_dbus_node_info_unref(g_state.node_info);
    g_state.node_info = nullptr;
  }
  g_clear_object(&g_state.channel);
}
