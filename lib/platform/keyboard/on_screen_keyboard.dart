import 'dart:async';
import 'dart:io';

import '../../core/utils/logger.dart';

abstract final class OnScreenKeyboard {
  static bool get isSupported => Platform.isWindows || Platform.isLinux;

  static const List<String> _windowsKeyboardCommands = <String>[
    r'C:\Program Files\Common Files\microsoft shared\ink\TabTip.exe',
    r'C:\Windows\System32\osk.exe',
  ];

  static const List<String> _linuxKeyboardCommands = <String>[
    'onboard',
    'squeekboard',
    'matchbox-keyboard',
    'florence',
  ];

  static Future<void> show() async {
    if (Platform.isWindows) {
      await _showWindows();
      return;
    }
    if (Platform.isLinux) {
      await _showLinux();
    }
  }

  static Future<void> hide() async {
    if (Platform.isWindows) {
      await _hideWindows();
      return;
    }
    if (Platform.isLinux) {
      await _hideLinux();
    }
  }

  static Future<void> _showWindows() async {
    for (final command in _windowsKeyboardCommands) {
      try {
        if (!await File(command).exists()) {
          continue;
        }
        await _launchWindowsCommand(command);
        return;
      } catch (e, st) {
        AppLogger.warn(
          'OnScreenKeyboard: failed to launch $command',
          tag: 'OnScreenKeyboard',
          error: e,
          stackTrace: st,
        );
      }
    }
  }

  static Future<void> _launchWindowsCommand(String command) async {
    final result = await Process.run('cmd', <String>[
      '/c',
      'start',
      '',
      command,
    ]);

    if (result.exitCode == 0) {
      return;
    }

    throw ProcessException(
      'cmd',
      <String>['/c', 'start', '', command],
      result.stderr.toString(),
      result.exitCode,
    );
  }

  static Future<void> _showLinux() async {
    for (final command in _linuxKeyboardCommands) {
      try {
        await Process.start(command, const <String>[]);
        return;
      } on ProcessException {
        // Command not installed; try the next known keyboard.
      } catch (e, st) {
        AppLogger.warn(
          'OnScreenKeyboard: failed to launch $command',
          tag: 'OnScreenKeyboard',
          error: e,
          stackTrace: st,
        );
      }
    }
  }

  static Future<void> _hideWindows() async {
    const processNames = <String>['TabTip.exe', 'osk.exe'];
    for (final processName in processNames) {
      try {
        await Process.run(
          'taskkill',
          <String>['/IM', processName, '/F'],
          runInShell: true,
        );
      } catch (e, st) {
        AppLogger.warn(
          'OnScreenKeyboard: failed to close $processName',
          tag: 'OnScreenKeyboard',
          error: e,
          stackTrace: st,
        );
      }
    }
  }

  static Future<void> _hideLinux() async {
    for (final command in _linuxKeyboardCommands) {
      try {
        await Process.run('pkill', <String>[command]);
      } on ProcessException {
        // pkill or the keyboard process may not exist.
      } catch (e, st) {
        AppLogger.warn(
          'OnScreenKeyboard: failed to close $command',
          tag: 'OnScreenKeyboard',
          error: e,
          stackTrace: st,
        );
      }
    }
  }
}