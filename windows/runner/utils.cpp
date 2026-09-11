#include "utils.h"

#include <flutter_windows.h>
#include <io.h>
#include <propkey.h>
#include <propvarutil.h>
#include <propsys.h>
#include <stdio.h>
#include <shlobj.h>
#include <windows.h>

#include <iostream>

namespace {

constexpr const wchar_t kFlutterWindowClassName[] =
  L"FLUTTER_RUNNER_WIN32_WINDOW";

std::wstring GetExecutablePath() {
  std::wstring executable_path(MAX_PATH, L'\0');
  DWORD path_length = ::GetModuleFileNameW(
      nullptr, executable_path.data(), static_cast<DWORD>(executable_path.size()));
  if (path_length == 0 || path_length == executable_path.size()) {
    return std::wstring();
  }

  executable_path.resize(path_length);
  return executable_path;
}

std::wstring GetExecutableDirectory(const std::wstring& executable_path) {
  const auto separator_index = executable_path.find_last_of(L"\\/");
  if (separator_index == std::wstring::npos) {
    return std::wstring();
  }

  return executable_path.substr(0, separator_index);
}

std::wstring GetStartMenuShortcutPath(const wchar_t* app_name) {
  PWSTR programs_path = nullptr;
  const HRESULT get_folder_result = ::SHGetKnownFolderPath(
      FOLDERID_Programs, KF_FLAG_CREATE, nullptr, &programs_path);
  if (FAILED(get_folder_result) || programs_path == nullptr) {
    return std::wstring();
  }

  std::wstring shortcut_path(programs_path);
  ::CoTaskMemFree(programs_path);
  shortcut_path.append(L"\\");
  shortcut_path.append(app_name);
  shortcut_path.append(L".lnk");
  return shortcut_path;
}

bool SetShellLinkStringProperty(IPropertyStore* property_store,
                                REFPROPERTYKEY key,
                                const std::wstring& value) {
  if (property_store == nullptr || value.empty()) {
    return false;
  }

  PROPVARIANT property_value;
  ::PropVariantInit(&property_value);
  const HRESULT init_result = ::InitPropVariantFromString(
      value.c_str(), &property_value);
  if (FAILED(init_result)) {
    return false;
  }

  const HRESULT set_result = property_store->SetValue(key, property_value);
  ::PropVariantClear(&property_value);
  return SUCCEEDED(set_result);
}

}  // namespace

void CreateAndAttachConsole() {
  if (::AllocConsole()) {
    FILE *unused;
    if (freopen_s(&unused, "CONOUT$", "w", stdout)) {
      _dup2(_fileno(stdout), 1);
    }
    if (freopen_s(&unused, "CONOUT$", "w", stderr)) {
      _dup2(_fileno(stdout), 2);
    }
    std::ios::sync_with_stdio();
    FlutterDesktopResyncOutputStreams();
  }
}

std::vector<std::string> GetCommandLineArguments() {
  // Convert the UTF-16 command line arguments to UTF-8 for the Engine to use.
  int argc;
  wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  if (argv == nullptr) {
    return std::vector<std::string>();
  }

  std::vector<std::string> command_line_arguments;

  // Skip the first argument as it's the binary name.
  for (int i = 1; i < argc; i++) {
    command_line_arguments.push_back(Utf8FromUtf16(argv[i]));
  }

  ::LocalFree(argv);

  return command_line_arguments;
}

std::string Utf8FromUtf16(const wchar_t* utf16_string) {
  if (utf16_string == nullptr) {
    return std::string();
  }
  unsigned int target_length = ::WideCharToMultiByte(
      CP_UTF8, WC_ERR_INVALID_CHARS, utf16_string,
      -1, nullptr, 0, nullptr, nullptr)
    -1; // remove the trailing null character
  int input_length = (int)wcslen(utf16_string);
  std::string utf8_string;
  if (target_length == 0 || target_length > utf8_string.max_size()) {
    return utf8_string;
  }
  utf8_string.resize(target_length);
  int converted_length = ::WideCharToMultiByte(
      CP_UTF8, WC_ERR_INVALID_CHARS, utf16_string,
      input_length, utf8_string.data(), target_length, nullptr, nullptr);
  if (converted_length == 0) {
    return std::string();
  }
  return utf8_string;
}

std::wstring Utf16FromUtf8(const std::string& utf8_string) {
  if (utf8_string.empty()) {
    return std::wstring();
  }

  int target_length = ::MultiByteToWideChar(
      CP_UTF8, MB_ERR_INVALID_CHARS, utf8_string.data(),
      static_cast<int>(utf8_string.size()), nullptr, 0);
  if (target_length <= 0) {
    return std::wstring();
  }

  std::wstring utf16_string;
  utf16_string.resize(target_length);
  int converted_length = ::MultiByteToWideChar(
      CP_UTF8, MB_ERR_INVALID_CHARS, utf8_string.data(),
      static_cast<int>(utf8_string.size()), utf16_string.data(),
      target_length);
  if (converted_length <= 0) {
    return std::wstring();
  }

  return utf16_string;
}

bool SendNamedPipeMessage(const std::string& pipe_name,
                          const std::string& message,
                          unsigned int timeout_ms) {
  const auto pipe_name_utf16 = Utf16FromUtf8(pipe_name);
  if (pipe_name_utf16.empty()) {
    return false;
  }

  if (!::WaitNamedPipeW(pipe_name_utf16.c_str(), timeout_ms)) {
    return false;
  }

  HANDLE pipe = ::CreateFileW(pipe_name_utf16.c_str(), GENERIC_WRITE, 0,
                              nullptr, OPEN_EXISTING, 0, nullptr);
  if (pipe == INVALID_HANDLE_VALUE) {
    return false;
  }

  bool success = true;
  if (!message.empty()) {
    DWORD bytes_written = 0;
    success = ::WriteFile(pipe, message.data(),
                          static_cast<DWORD>(message.size()),
                          &bytes_written, nullptr) != 0 &&
              bytes_written == static_cast<DWORD>(message.size());
  }

  ::FlushFileBuffers(pipe);
  ::CloseHandle(pipe);
  return success;
}

void FocusExistingFlutterWindow() {
  HWND hwnd = ::FindWindowW(kFlutterWindowClassName, nullptr);
  if (hwnd == nullptr) {
    return;
  }

  ::ShowWindow(hwnd, SW_RESTORE);
  ::SetForegroundWindow(hwnd);
}

void EnsureAppUserModelShellLink(const wchar_t* app_id,
                                 const wchar_t* app_name) {
  if (app_id == nullptr || *app_id == L'\0' ||
      app_name == nullptr || *app_name == L'\0') {
    return;
  }

  const std::wstring executable_path = GetExecutablePath();
  const std::wstring shortcut_path = GetStartMenuShortcutPath(app_name);
  if (executable_path.empty() || shortcut_path.empty()) {
    return;
  }

  IShellLinkW* shell_link = nullptr;
  HRESULT result = ::CoCreateInstance(
      CLSID_ShellLink, nullptr, CLSCTX_INPROC_SERVER,
      IID_PPV_ARGS(&shell_link));
  if (FAILED(result) || shell_link == nullptr) {
    return;
  }

  shell_link->SetPath(executable_path.c_str());
  shell_link->SetDescription(app_name);
  shell_link->SetIconLocation(executable_path.c_str(), 0);

  const std::wstring working_directory =
      GetExecutableDirectory(executable_path);
  if (!working_directory.empty()) {
    shell_link->SetWorkingDirectory(working_directory.c_str());
  }

  IPropertyStore* property_store = nullptr;
  result = shell_link->QueryInterface(IID_PPV_ARGS(&property_store));
  if (SUCCEEDED(result) && property_store != nullptr) {
    SetShellLinkStringProperty(property_store, PKEY_AppUserModel_ID, app_id);
    SetShellLinkStringProperty(
        property_store,
        PKEY_AppUserModel_RelaunchDisplayNameResource,
        app_name);
    SetShellLinkStringProperty(
        property_store,
        PKEY_AppUserModel_RelaunchCommand,
        L"\"" + executable_path + L"\"");
    SetShellLinkStringProperty(
        property_store,
        PKEY_AppUserModel_RelaunchIconResource,
        executable_path + L",0");
    property_store->Commit();
    property_store->Release();
  }

  IPersistFile* persist_file = nullptr;
  result = shell_link->QueryInterface(IID_PPV_ARGS(&persist_file));
  if (SUCCEEDED(result) && persist_file != nullptr) {
    persist_file->Save(shortcut_path.c_str(), TRUE);
    persist_file->Release();
  }

  shell_link->Release();
}
