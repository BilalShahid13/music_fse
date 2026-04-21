# Gamepad Emulation & Focus Navigation Fix Plan

## Status: PLANNED

---

## Problem Statement

Three interrelated issues prevent keyboard-based gamepad testing on macOS:

1. **Keyboard gamepad emulator keys (A/B/X/Y/Q/E/P) don't fire** — only native arrow keys work.
2. **No visible focus indicator** when navigating with the keyboard — the accent border + scale effect from `FocusHighlight` never appears.
3. **D-pad left from content doesn't reach the nav rail** — the two `FocusTraversalGroup`s in `shell_page.dart` create an impassable boundary.

---

## Root Cause Analysis

### Issue 1: Emulator re-entrancy problem

**File**: `lib/platform/keyboard/keyboard_gamepad_emulator.dart`

The current emulator registers via `HardwareKeyboard.instance.addHandler()` and injects synthetic events via `HardwareKeyboard.instance.handleKeyEvent()`. This is a re-entrancy problem: `handleKeyEvent()` dispatches synchronously to all handlers, so calling it from inside a handler means the synthetic event is dispatched while the original dispatch is still on the call stack. Flutter's `HardwareKeyboard` can swallow or mishandle these nested dispatches.

Arrow keys work because they are **not** intercepted by the emulator — they pass through natively.

**Evidence**: The emulator returns `true` (consumed) for A/B/X/Y/Q/E/P, then injects a new event. But the injected event either:
- Gets swallowed by the re-entrant guard in `HardwareKeyboard`
- Arrives after the focus tree has already finished processing the current frame's events

### Issue 2: Input mode stuck on `mouse`

**File**: `lib/presentation/app.dart` (lines 118-133)

The root `Focus.onKeyEvent` in `app.dart` only switches to `InputMode.keyboard` for these keys:
```dart
arrowUp, arrowDown, arrowLeft, arrowRight, tab, enter, space, escape
```

The emulated gamepad keys (`gameButtonX`, `gameButtonY`, `gameButtonLeft1`, `gameButtonRight1`, `gameButtonStart`) are **not** in this list. So even if the emulator successfully injected them, the input mode would stay on `mouse` (set by any mouse movement) and `FocusHighlight` would hide the focus ring because it checks:
```dart
final showFocus = ref.watch(
  inputModeProvider.select((mode) => mode != InputMode.mouse),
);
```

Additionally, the emulated letter keys (A, B, X, Y, Q, E, P) themselves aren't in the detection list either, so pressing them doesn't switch away from mouse mode.

### Issue 3: Isolated focus traversal groups

**File**: `lib/presentation/pages/shell_page.dart` (lines 124-138)

```dart
Row(
  children: [
    FocusTraversalGroup(          // ← Group A: nav rail
      policy: OrderedTraversalPolicy(),
      child: const SideNavRail(),
    ),
    Expanded(
      child: FocusTraversalGroup(  // ← Group B: content
        policy: OrderedTraversalPolicy(),
        child: widget.navigationShell,
      ),
    ),
  ],
)
```

`FocusTraversalGroup` creates a boundary. When `focusInDirection(TraversalDirection.left)` is called from inside Group B, it only searches for focusable nodes within Group B. The nav rail (Group A) is invisible to this search.

This is by design in Flutter — traversal groups are meant to contain focus. But the mockup shows that D-pad left from the content area's left edge should move focus to the nav rail (like a console UI where left goes to the sidebar).

---

## Implementation Plan

### Change 1: Rewrite keyboard gamepad emulator

**File**: `lib/platform/keyboard/keyboard_gamepad_emulator.dart`

**Approach**: Replace `HardwareKeyboard.addHandler` with a root-level `Focus` widget using `onKeyEvent`. Instead of injecting synthetic hardware events (which causes re-entrancy), use `ServicesBinding.instance.keyboard.handleKeyEvent()` scheduled on the next microtask — this avoids the re-entrant dispatch.

**Mapping** (unchanged):

| Keyboard Key | Emulated As | Logical Key Injected |
|-------------|-------------|---------------------|
| A | Gamepad A (confirm) | `LogicalKeyboardKey.enter` |
| B | Gamepad B (back) | `LogicalKeyboardKey.escape` |
| X | Gamepad X (context menu) | `LogicalKeyboardKey.gameButtonX` |
| Y | Gamepad Y (favourite) | `LogicalKeyboardKey.gameButtonY` |
| Q | LB (prev tab/track) | `LogicalKeyboardKey.gameButtonLeft1` |
| E | RB (next tab/track) | `LogicalKeyboardKey.gameButtonRight1` |
| P | Start (play/pause) | `LogicalKeyboardKey.gameButtonStart` |

**Key design decisions**:
- The `Focus` widget wraps the child at the root level with `canRequestFocus: false` so it doesn't interfere with normal focus traversal
- The `onKeyEvent` handler returns `KeyEventResult.handled` for mapped keys to prevent them from reaching text fields or being processed as literal letters
- For A (Enter) and B (Escape): these are already handled by existing widgets (`FocusHighlight` handles Enter/Space, Flutter's navigator handles Escape), so we just need to schedule a synthetic key event on the next microtask
- For X/Y/Q/E/P: these map to `gameButton*` logical keys. Widgets like `SongListTile` and `ShellPage` already listen for these in their `onKeyEvent` handlers. We schedule synthetic key events on the next microtask
- Text field detection: if the focused widget is an `EditableText`, skip all mappings so the user can type normally
- Modifier bypass: if Ctrl/Cmd/Alt is held, skip mappings so shortcuts like Cmd+A still work

**Pseudocode**:
```dart
class KeyboardGamepadEmulator extends StatelessWidget {
  const KeyboardGamepadEmulator({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: false,
      canRequestFocus: false,
      onKeyEvent: (node, event) {
        if (_isTextFieldFocused()) return KeyEventResult.ignored;
        if (_modifierHeld()) return KeyEventResult.ignored;
        
        final mapped = _keyMap[event.logicalKey];
        if (mapped == null) return KeyEventResult.ignored;
        
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          // Schedule on next microtask to avoid re-entrancy
          Future.microtask(() {
            HardwareKeyboard.instance.handleKeyEvent(
              KeyDownEvent(
                logicalKey: mapped.logical,
                physicalKey: mapped.physical,
                timeStamp: ...,
                synthesized: true,
              ),
            );
          });
        }
        if (event is KeyUpEvent) {
          Future.microtask(() {
            HardwareKeyboard.instance.handleKeyEvent(
              KeyUpEvent(...),
            );
          });
        }
        
        return KeyEventResult.handled; // Consume the letter key
      },
      child: child,
    );
  }
}
```

### Change 2: Fix input mode detection

**File**: `lib/presentation/app.dart`

**What**: Expand the key detection list in the root `Focus.onKeyEvent` handler to include all gamepad button logical keys.

**Current** (lines 122-130):
```dart
if (key == LogicalKeyboardKey.arrowUp ||
    key == LogicalKeyboardKey.arrowDown ||
    key == LogicalKeyboardKey.arrowLeft ||
    key == LogicalKeyboardKey.arrowRight ||
    key == LogicalKeyboardKey.tab ||
    key == LogicalKeyboardKey.enter ||
    key == LogicalKeyboardKey.space ||
    key == LogicalKeyboardKey.escape) {
  ref.read(inputModeProvider.notifier).onKeyboardInput();
}
```

**After**: Add the gamepad button keys AND the raw letter keys (A/B/X/Y/Q/E/P) so that input mode switches away from `mouse` the moment the user presses any of these:
```dart
if (key == LogicalKeyboardKey.arrowUp ||
    key == LogicalKeyboardKey.arrowDown ||
    key == LogicalKeyboardKey.arrowLeft ||
    key == LogicalKeyboardKey.arrowRight ||
    key == LogicalKeyboardKey.tab ||
    key == LogicalKeyboardKey.enter ||
    key == LogicalKeyboardKey.space ||
    key == LogicalKeyboardKey.escape ||
    // Gamepad button keys (from XInput handler or keyboard emulator)
    key == LogicalKeyboardKey.gameButtonA ||
    key == LogicalKeyboardKey.gameButtonX ||
    key == LogicalKeyboardKey.gameButtonY ||
    key == LogicalKeyboardKey.gameButtonLeft1 ||
    key == LogicalKeyboardKey.gameButtonRight1 ||
    key == LogicalKeyboardKey.gameButtonStart) {
  ref.read(inputModeProvider.notifier).onKeyboardInput();
}
```

Note: We don't need to add the raw letter keys (A/B/X/Y/Q/E/P) because the emulator consumes them before they reach this handler, and the emulated keys (enter, escape, gameButton*) will trigger the detection instead.

### Change 3: Add cross-group focus navigation in shell

**File**: `lib/presentation/pages/shell_page.dart`

**What**: Intercept D-pad left/right at the shell level to move focus between the nav rail and content groups.

**Approach**: Replace the `KeyboardListener` with a `Focus` widget that has `onKeyEvent`. When left arrow is pressed:
1. Check if the currently focused node is inside the content area group
2. Try `focusInDirection(left)` — if it returns false (no more nodes to the left within the group), move focus to the nav rail
3. The nav rail should focus the currently active (highlighted) nav item

When right arrow is pressed from the nav rail:
1. Check if the currently focused node is inside the nav rail group
2. Move focus to the content area's first focusable child (or the previously focused child)

When B (Escape) is pressed from the nav rail:
1. Move focus back to the content area (don't navigate back)

**Implementation detail**: Use the `_navRailFocus` and `_contentFocus` FocusNodes that already exist in `_ShellPageState` as the scope nodes for each group. Check `_navRailFocus.hasFocus` (which is true if any descendant has focus) to determine which group currently has focus.

**Pseudocode**:
```dart
KeyEventResult _handleShellKey(FocusNode node, KeyEvent event) {
  if (event is! KeyDownEvent) return KeyEventResult.ignored;
  
  final key = event.logicalKey;
  
  // LB/RB global prev/next track (existing)
  if (key == LogicalKeyboardKey.gameButtonLeft1) { ... }
  if (key == LogicalKeyboardKey.gameButtonRight1) { ... }
  
  // D-pad left from content → nav rail
  if (key == LogicalKeyboardKey.arrowLeft) {
    if (_contentFocus.hasFocus) {
      // Try normal focus traversal first
      final moved = FocusManager.instance.primaryFocus?.focusInDirection(TraversalDirection.left) ?? false;
      if (!moved) {
        // Crossed the boundary — move to nav rail
        _focusActiveNavItem();
        return KeyEventResult.handled;
      }
    }
  }
  
  // D-pad right from nav rail → content
  if (key == LogicalKeyboardKey.arrowRight) {
    if (_navRailFocus.hasFocus) {
      _contentFocus.requestFocus(); // or first focusable descendant
      return KeyEventResult.handled;
    }
  }
  
  // Escape from nav rail → back to content (not navigate back)
  if (key == LogicalKeyboardKey.escape) {
    if (_navRailFocus.hasFocus) {
      _contentFocus.requestFocus();
      return KeyEventResult.handled;
    }
  }
  
  return KeyEventResult.ignored;
}
```

**Wiring the scope focus nodes**: The existing `_navRailFocus` and `_contentFocus` nodes need to become the `focusNode` of their respective `FocusTraversalGroup` parents (or a wrapping `Focus` widget), so that `_navRailFocus.hasFocus` correctly reports whether any descendant within the nav rail group has focus:

```dart
Focus(
  focusNode: _navRailFocus,
  canRequestFocus: false,
  skipTraversal: true,
  child: FocusTraversalGroup(
    policy: OrderedTraversalPolicy(),
    child: const SideNavRail(),
  ),
),
```

### Change 4: Ensure default focus on startup

**File**: `lib/presentation/pages/shell_page.dart`

**What**: After the first frame, if nothing has focus, request focus on the first content area item.

**Approach**: In `initState`, schedule a post-frame callback:
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (FocusManager.instance.primaryFocus == null ||
      FocusManager.instance.primaryFocus == FocusManager.instance.rootScope) {
    // Nothing focused — request focus on content area so focus traversal
    // has a starting point
    _contentFocus.nextFocus(); // or requestFocus on a known default
  }
});
```

This ensures the user sees a focus ring immediately when the app starts, matching the console-like experience shown in the mockup.

### Change 5: Add mini player bar to shell focus navigation

**File**: `lib/presentation/pages/shell_page.dart`

**What**: Add the mini player bar as a third focus region in the shell. D-pad down from the bottom of the content area should move focus to the mini player bar. D-pad up from the mini player bar should return focus to content.

**Layout context**: The shell layout is:
```
Column [
  CustomTitleBar,
  Expanded [
    Row [
      NavRail (Group A),
      Content (Group B),
    ]
  ],
  MiniPlayerBar (Group C — NEW),
  GamepadButtonHints,
]
```

**Approach**: Add a third focus scope node `_miniPlayerFocus` and wrap the MiniPlayerBar in a `Focus` + `FocusTraversalGroup`. In `_handleShellKey`:

- **D-pad down from content**: If `_contentFocus.hasFocus` and `focusInDirection(down)` returns false → move focus to mini player bar
- **D-pad up from mini player**: If `_miniPlayerFocus.hasFocus` → move focus back to content area
- **D-pad left from mini player**: If `_miniPlayerFocus.hasFocus` → move to nav rail
- **D-pad down from nav rail**: If at bottom nav item and `focusInDirection(down)` fails → move to mini player

**The mini player bar already has focusable controls** (play/pause, shuffle, repeat, prev/next, album art, volume). These are wrapped in `FocusHighlight`. The issue is only that there's no way to reach them via D-pad from the content/nav rail.

### Change 6: Per-screen focus fixes (Phase 2 — separate from core emulator fix)

> These are pre-existing focus issues independent of the keyboard emulator. They should be fixed **after** Changes 1-5 are working so we can test each fix with gamepad input.

#### Priority: CRITICAL (blocks basic gamepad testing)

| Screen | Issue | Fix |
|--------|-------|-----|
| **home_page.dart** | No `KeyboardListener` at all — no gamepad keys work | Add key handler for B (back), wrap horizontal scroll rows in FocusTraversalGroup, make action chips focusable |
| **library_page.dart** | No B button handler — users trapped on page; tab bar has no visible focus | Add B handler; wrap TabBar items in FocusHighlight or add visible focus indicator |
| **favorites_page.dart** | No B handler; action chips (Play All, Shuffle) not focusable | Add B handler; wrap action chips in FocusHighlight |
| **genre_detail_page.dart** | Play/Shuffle buttons not wrapped in FocusHighlight | Wrap `_PlayButton` in FocusHighlight |
| **equalizer_page.dart** | Save/Reset `_TextBtn` not focusable | Wrap `_TextBtn` in FocusHighlight |

#### Priority: MODERATE (poor UX but not blocking)

| Screen | Issue | Fix |
|--------|-------|-----|
| **search_page.dart** | Search results (songs/albums/artists) not focusable via D-pad | Ensure result list items use `SongListTile` (which has FocusHighlight) and horizontal album/artist lists have focusable cards |
| **now_playing_page.dart** | `_RepeatBtn` not focusable; seek bar not gamepad-accessible | Wrap RepeatBtn in FocusHighlight; add left/right D-pad seek on focused seek bar |
| **settings_page.dart** | Slider widgets use Flutter default focus, not app's FocusHighlight style | Override slider focus with custom theme or wrap in FocusHighlight |

#### Priority: LOW (nice to have)

| Screen | Issue | Fix |
|--------|-------|-----|
| **All screens** | No `FocusTraversalGroup` — focus order unpredictable | Add FocusTraversalGroup with OrderedTraversalPolicy to each screen's main layout |
| **home_page.dart** | Horizontal scroll rows not D-pad navigable | Wrap horizontal lists in FocusTraversalGroup, make cards focusable |
| **album/artist detail** | Minimal gamepad support (only B button) | Add Y (favorite), X (context menu) handlers |
| **All screens** | No focus memory when navigating back | Implement FocusRestorationScope or custom focus restoration per screen |

---

## Files Changed Summary

### Phase 1: Core emulator + shell navigation (Changes 1-5)

| File | Change Type | Lines Changed (est.) |
|------|-------------|---------------------|
| `lib/platform/keyboard/keyboard_gamepad_emulator.dart` | Rewrite | ~120 |
| `lib/presentation/app.dart` | Edit | ~8 |
| `lib/presentation/pages/shell_page.dart` | Edit | ~70 |

### Phase 2: Per-screen fixes (Change 6 — CRITICAL only)

| File | Change Type | Lines Changed (est.) |
|------|-------------|---------------------|
| `lib/presentation/pages/home/home_page.dart` | Edit | ~30 |
| `lib/presentation/pages/library/library_page.dart` | Edit | ~15 |
| `lib/presentation/pages/favorites/favorites_page.dart` | Edit | ~20 |
| `lib/presentation/pages/genre_detail/genre_detail_page.dart` | Edit | ~10 |
| `lib/presentation/pages/equalizer/equalizer_page.dart` | Edit | ~10 |

---

## Testing Checklist

After implementation, verify on macOS (keyboard only):

### Core Emulator (Phase 1)
- [ ] Press arrow keys → focus ring (accent border + scale) appears and moves between items
- [ ] Press A → activates the focused item (navigates, plays song, etc.)
- [ ] Press B → goes back / dismisses overlay
- [ ] Press X → opens context menu on focused item
- [ ] Press Y → toggles favourite on focused song tile
- [ ] Press Q → previous track (when playing)
- [ ] Press E → next track (when playing)
- [ ] Press P → toggles play/pause
- [ ] Arrow left from content left edge → focus moves to nav rail
- [ ] Arrow right from nav rail → focus moves back to content
- [ ] B from nav rail → focus returns to content (doesn't navigate back)
- [ ] Arrow up/down in nav rail → focus moves between nav items
- [ ] A on nav item → navigates to that route
- [ ] Moving mouse hides focus ring, pressing any emulated key shows it again
- [ ] Typing in search field works normally (A/B/X/Y type literal letters)
- [ ] Cmd+A, Ctrl+C etc. still work (modifiers bypass emulation)
- [ ] App starts with visible focus on a default element

### Mini Player Navigation (Phase 1)
- [ ] Arrow down from bottom of content → focus moves to mini player bar
- [ ] Arrow up from mini player bar → focus returns to content
- [ ] Arrow left from mini player → focus moves to nav rail
- [ ] D-pad left/right within mini player → navigates between controls (prev, play, next, shuffle, repeat)
- [ ] A on play/pause in mini player → toggles playback
- [ ] Mini player shows accent focus ring on focused control

### Per-Screen Fixes (Phase 2)
- [ ] Home page: B goes back, horizontal rows scrollable with D-pad
- [ ] Library page: B goes back, LB/RB switches tabs, tab bar shows focus
- [ ] Favorites page: B goes back, Play All / Shuffle focusable with A
- [ ] Genre detail: Play All / Shuffle buttons focusable and activatable
- [ ] Equalizer: Save/Reset buttons focusable and activatable

---

## Non-Goals

- No UI/visual changes to `FocusHighlight` — it already has the correct accent border + glow + scale
- No changes to `SideNavRail` widget styling
- No changes to theme or card/tile designs
- No changes to the Windows XInput pipeline — this is macOS keyboard emulation only
- No LT/RT (trigger) emulation — volume is already handled by Ctrl+Up/Down keyboard shortcut
- No right stick (seek) emulation — not practical on keyboard
