#include "flutter_window.h"

#include <optional>
#include <string>
#include <utility>

#include "flutter/generated_plugin_registrant.h"
#include "utils.h"

namespace {

constexpr UINT kFileAssociationPipeMessage = WM_APP + 100;

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project,
               std::string launch_file_path)
  : project_(project), launch_file_path_(std::move(launch_file_path)) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetUpFileAssociationChannels();

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  StopFileAssociationPipeServer();
  file_association_event_sink_.reset();
  file_association_stream_handler_.reset();
  file_association_event_channel_.reset();
  file_association_channel_.reset();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case kFileAssociationPipeMessage:
      DrainPendingFileAssociationEvents();
      return 0;

    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

void FlutterWindow::SetUpFileAssociationChannels() {
  auto* messenger = flutter_controller_->engine()->messenger();

  file_association_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          messenger, "com.musicfse.player/file_association",
          &flutter::StandardMethodCodec::GetInstance());
  file_association_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        if (call.method_name() == "getLaunchFilePath") {
          if (launch_file_path_.empty()) {
            result->Success();
          } else {
            result->Success(flutter::EncodableValue(launch_file_path_));
          }
          return;
        }

        if (call.method_name() == "startPipeServer") {
          const auto* arguments =
              std::get_if<flutter::EncodableMap>(call.arguments());
          if (arguments == nullptr) {
            result->Error("bad-args", "Expected a map with a pipe path.");
            return;
          }

          const auto pipe_name_it =
              arguments->find(flutter::EncodableValue("pipe"));
          if (pipe_name_it == arguments->end()) {
            result->Error("bad-args", "Missing pipe argument.");
            return;
          }

          const auto* pipe_name =
              std::get_if<std::string>(&pipe_name_it->second);
          if (pipe_name == nullptr || pipe_name->empty()) {
            result->Error("bad-args", "Pipe argument must be a string.");
            return;
          }

          StartFileAssociationPipeServer(*pipe_name);
          result->Success();
          return;
        }

        if (call.method_name() == "stopPipeServer") {
          StopFileAssociationPipeServer();
          result->Success();
          return;
        }

        result->NotImplemented();
      });

  file_association_event_channel_ =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          messenger, "com.musicfse.player/file_association_events",
          &flutter::StandardMethodCodec::GetInstance());
  file_association_stream_handler_ = std::make_unique<
      flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
      [this](const flutter::EncodableValue* arguments,
             std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&&
                 events) {
        {
          std::lock_guard<std::mutex> lock(file_association_mutex_);
          file_association_event_sink_ = std::move(events);
        }
        DrainPendingFileAssociationEvents();
        return nullptr;
      },
      [this](const flutter::EncodableValue* arguments) {
        std::lock_guard<std::mutex> lock(file_association_mutex_);
        file_association_event_sink_.reset();
        return nullptr;
      });
  file_association_event_channel_->SetStreamHandler(
      std::move(file_association_stream_handler_));
}

void FlutterWindow::StartFileAssociationPipeServer(
    const std::string& pipe_name) {
  if (pipe_name.empty()) {
    return;
  }

  if (pipe_server_running_) {
    if (pipe_name_ == pipe_name) {
      return;
    }
    StopFileAssociationPipeServer();
  }

  pipe_name_ = pipe_name;
  pipe_server_running_ = true;
  pipe_server_thread_ = std::thread([this]() { RunFileAssociationPipeServer(); });
}

void FlutterWindow::StopFileAssociationPipeServer() {
  if (!pipe_server_running_.exchange(false)) {
    return;
  }

  if (!pipe_name_.empty()) {
    SendNamedPipeMessage(pipe_name_, std::string(), 100);
  }

  if (pipe_server_thread_.joinable()) {
    pipe_server_thread_.join();
  }

  pipe_name_.clear();
}

void FlutterWindow::RunFileAssociationPipeServer() {
  const auto pipe_name_utf16 = Utf16FromUtf8(pipe_name_);
  if (pipe_name_utf16.empty()) {
    pipe_server_running_ = false;
    return;
  }

  while (pipe_server_running_) {
    HANDLE pipe = ::CreateNamedPipeW(
        pipe_name_utf16.c_str(), PIPE_ACCESS_INBOUND,
        PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT, 1, 4096, 4096, 0,
        nullptr);
    if (pipe == INVALID_HANDLE_VALUE) {
      break;
    }

    BOOL connected =
        ::ConnectNamedPipe(pipe, nullptr)
            ? TRUE
            : (::GetLastError() == ERROR_PIPE_CONNECTED);
    if (!connected) {
      ::CloseHandle(pipe);
      continue;
    }

    std::string message;
    char buffer[512];
    DWORD bytes_read = 0;
    while (::ReadFile(pipe, buffer, sizeof(buffer), &bytes_read, nullptr) &&
           bytes_read > 0) {
      message.append(buffer, bytes_read);
    }

    ::DisconnectNamedPipe(pipe);
    ::CloseHandle(pipe);

    if (!pipe_server_running_) {
      break;
    }

    if (!message.empty()) {
      {
        std::lock_guard<std::mutex> lock(file_association_mutex_);
        pending_file_association_paths_.push_back(message);
      }

      HWND hwnd = GetHandle();
      if (hwnd != nullptr) {
        ::PostMessage(hwnd, kFileAssociationPipeMessage, 0, 0);
      }
    }
  }

  pipe_server_running_ = false;
}

void FlutterWindow::DrainPendingFileAssociationEvents() {
  std::vector<std::string> pending_paths;
  flutter::EventSink<flutter::EncodableValue>* sink = nullptr;

  {
    std::lock_guard<std::mutex> lock(file_association_mutex_);
    if (!file_association_event_sink_ ||
        pending_file_association_paths_.empty()) {
      return;
    }

    pending_paths.swap(pending_file_association_paths_);
    sink = file_association_event_sink_.get();
  }

  for (const auto& file_path : pending_paths) {
    sink->Success(flutter::EncodableValue(file_path));
  }
}
