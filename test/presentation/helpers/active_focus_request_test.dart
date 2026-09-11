import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:music_fse/presentation/helpers/active_focus_request.dart';

void main() {
  testWidgets('requests focus for a visible surface', (tester) async {
    final focusNode = FocusNode(debugLabel: 'visible-focus');
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _FocusRequester(focusNode: focusNode),
        ),
      ),
    );
    await tester.pump();

    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('does not request focus for an offstage surface', (tester) async {
    final focusNode = FocusNode(debugLabel: 'offstage-focus');
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Offstage(
            offstage: true,
            child: _FocusRequester(focusNode: focusNode),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(focusNode.hasFocus, isFalse);
  });

  testWidgets('retries focus when a surface becomes active on a later frame',
      (tester) async {
    final focusNode = FocusNode(debugLabel: 'delayed-focus');
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _DelayedFocusRequester(focusNode: focusNode),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(focusNode.hasFocus, isTrue);
  });
}

class _FocusRequester extends StatefulWidget {
  const _FocusRequester({required this.focusNode});

  final FocusNode focusNode;

  @override
  State<_FocusRequester> createState() => _FocusRequesterState();
}

class _FocusRequesterState extends State<_FocusRequester> {
  @override
  void initState() {
    super.initState();
    scheduleActiveFocusRequest(state: this, focusNode: widget.focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      child: const SizedBox(width: 48, height: 48),
    );
  }
}

class _DelayedFocusRequester extends StatefulWidget {
  const _DelayedFocusRequester({required this.focusNode});

  final FocusNode focusNode;

  @override
  State<_DelayedFocusRequester> createState() => _DelayedFocusRequesterState();
}

class _DelayedFocusRequesterState extends State<_DelayedFocusRequester> {
  var _isVisible = false;

  @override
  void initState() {
    super.initState();
    scheduleActiveFocusRequest(state: this, focusNode: widget.focusNode);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _isVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !_isVisible,
      child: Focus(
        focusNode: widget.focusNode,
        child: const SizedBox(width: 48, height: 48),
      ),
    );
  }
}
