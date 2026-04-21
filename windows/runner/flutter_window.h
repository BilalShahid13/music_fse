#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <atomic>
#include <memory>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  FlutterWindow(const flutter::DartProject& project,
                std::string launch_file_path);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
    void SetUpFileAssociationChannels();
    void StartFileAssociationPipeServer(const std::string& pipe_name);
    void StopFileAssociationPipeServer();
    void RunFileAssociationPipeServer();
    void DrainPendingFileAssociationEvents();

  // The project to run.
  flutter::DartProject project_;
  std::string launch_file_path_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      file_association_channel_;
  std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>>
      file_association_event_channel_;
  std::unique_ptr<flutter::StreamHandlerFunctions<flutter::EncodableValue>>
      file_association_stream_handler_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>
      file_association_event_sink_;
  std::atomic<bool> pipe_server_running_{false};
  std::string pipe_name_;
  std::thread pipe_server_thread_;
  std::mutex file_association_mutex_;
  std::vector<std::string> pending_file_association_paths_;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
