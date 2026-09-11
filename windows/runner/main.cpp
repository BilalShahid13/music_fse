#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <shobjidl_core.h>
#include <windows.h>

#include <string>
#include <utility>
#include <vector>

#include "flutter_window.h"
#include "utils.h"

namespace {

constexpr wchar_t kWindowsAppUserModelId[] = L"com.musicfse.player";
constexpr wchar_t kWindowsAppName[] = L"Music FSE";

constexpr char kFileAssociationPipeName[] =
  R"(\\.\pipe\MusicFSE_FileOpen)";

std::string GetLaunchFilePath(
    const std::vector<std::string>& command_line_arguments) {
  for (const auto& argument : command_line_arguments) {
    if (!argument.empty() && argument.front() != '-') {
      return argument;
    }
  }

  return std::string();
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  ::SetCurrentProcessExplicitAppUserModelID(kWindowsAppUserModelId);

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
  EnsureAppUserModelShellLink(kWindowsAppUserModelId, kWindowsAppName);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();
  std::string launch_file_path = GetLaunchFilePath(command_line_arguments);

  if (!launch_file_path.empty() &&
      SendNamedPipeMessage(kFileAssociationPipeName, launch_file_path, 3000)) {
    FocusExistingFlutterWindow();
    ::CoUninitialize();
    return EXIT_SUCCESS;
  }

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project, std::move(launch_file_path));
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(kWindowsAppName, origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
