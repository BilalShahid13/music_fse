import 'package:flutter/material.dart';

bool requestFocusIfActive(FocusNode focusNode) {
  if (!focusNode.canRequestFocus) return false;

  final focusContext = focusNode.context;
  if (focusContext == null) return false;
  if (focusContext is Element && !focusContext.mounted) return false;

  final route = ModalRoute.of(focusContext);
  if (route != null && !route.isCurrent) {
    return false;
  }

  var isOffstage = false;
  focusContext.visitAncestorElements((element) {
    final widget = element.widget;
    if (widget is Offstage && widget.offstage) {
      isOffstage = true;
      return false;
    }
    return true;
  });
  if (isOffstage) return false;

  final renderObject = focusContext.findRenderObject();
  if (renderObject == null || !renderObject.attached) {
    return false;
  }
  if (renderObject is RenderBox && !renderObject.hasSize) {
    return false;
  }

  focusNode.requestFocus();
  return true;
}

bool _primaryFocusIsInSameRoute(FocusNode focusNode) {
  final focusContext = focusNode.context;
  if (focusContext == null) return false;

  final targetRoute = ModalRoute.of(focusContext);
  if (targetRoute == null) return false;

  final primaryFocus = FocusManager.instance.primaryFocus;
  if (primaryFocus == null || identical(primaryFocus, focusNode)) {
    return false;
  }
  if (primaryFocus is FocusScopeNode) {
    return false;
  }

  final primaryContext = primaryFocus.context;
  if (primaryContext == null) return false;

  return ModalRoute.of(primaryContext) == targetRoute;
}

void scheduleActiveFocusRequest({
  required State state,
  required FocusNode focusNode,
  int maxAttempts = 20,
}) {
  void scheduleAttempt(int remainingAttempts) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!state.mounted || focusNode.hasFocus) return;
      if (_primaryFocusIsInSameRoute(focusNode)) return;

      if (requestFocusIfActive(focusNode) || remainingAttempts <= 1) {
        return;
      }

      scheduleAttempt(remainingAttempts - 1);
    });
  }

  scheduleAttempt(maxAttempts);
}
