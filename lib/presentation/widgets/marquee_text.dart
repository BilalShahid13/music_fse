import 'package:flutter/material.dart';

/// A text widget that auto-scrolls horizontally when the text overflows.
///
/// Behavior (industry standard — Spotify / Apple Music / Windows Media Player):
/// 1. Display text statically.
/// 2. If text overflows, wait [startPause] (default 2s).
/// 3. Scroll left at [velocity] px/s (default 35) until end is visible.
/// 4. Pause [endPause] (default 1.5s) at the end.
/// 5. Jump back to start (no reverse scroll) and repeat from step 2.
///
/// The widget measures overflow once via [LayoutBuilder] + [TextPainter] and
/// only creates an [AnimationController] when scrolling is needed — zero cost
/// for non-overflowing text.
class MarqueeText extends StatefulWidget {
  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
    bool? enabled,
    TextAlign? textAlign,
    this.velocity = 35.0,
    this.startPause = const Duration(seconds: 2),
    this.endPause = const Duration(milliseconds: 1500),
  })  : _enabled = enabled,
        _textAlign = textAlign;

  /// The text to display.
  final String text;

  /// Text style.
  final TextStyle style;

  /// Nullable backing field to remain compatible with pre-hot-reload widget
  /// instances created before this property existed.
  final bool? _enabled;

  /// Whether overflowing text should animate. When false, text stays static.
  bool get enabled => _enabled ?? true;

  /// Nullable backing field to remain compatible with pre-hot-reload widget
  /// instances created before this property existed.
  final TextAlign? _textAlign;

  /// Horizontal alignment for static text rendering.
  TextAlign get textAlign => _textAlign ?? TextAlign.start;

  /// Scroll speed in logical pixels per second.
  final double velocity;

  /// Pause before scrolling begins.
  final Duration startPause;

  /// Pause at the end before resetting.
  final Duration endPause;

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> with TickerProviderStateMixin {
  AnimationController? _controller;
  bool _needsScroll = false;

  @override
  void didUpdateWidget(MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.style != widget.style ||
        oldWidget.enabled != widget.enabled ||
        oldWidget.textAlign != widget.textAlign) {
      _controller?.dispose();
      _controller = null;
      _needsScroll = false;
      _overflow = 0;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _setupAnimation(double overflow) {
    if (_controller != null) return;

    // Total scroll duration based on velocity
    final scrollDuration = Duration(
      milliseconds: (overflow / widget.velocity * 1000).round(),
    );
    final totalDuration = widget.startPause + scrollDuration + widget.endPause;

    _controller = AnimationController(
      vsync: this,
      duration: totalDuration,
    );

    // Fraction of total time for each phase
    final startFrac = widget.startPause.inMilliseconds / totalDuration.inMilliseconds;
    final endFrac = 1.0 - widget.endPause.inMilliseconds / totalDuration.inMilliseconds;

    _controller!.addListener(() {
      setState(() {});
    });

    _controller!.repeat();

    // Store fractions for offset calculation
    _startFrac = startFrac;
    _endFrac = endFrac;
    _overflow = overflow;
  }

  double _startFrac = 0;
  double _endFrac = 1;
  double _overflow = 0;

  double get _currentOffset {
    if (_controller == null) return 0;
    final t = _controller!.value;
    if (t <= _startFrac) return 0;
    if (t >= _endFrac) return _overflow;
    // Linear interpolation between start and end pause
    final scrollT = (t - _startFrac) / (_endFrac - _startFrac);
    return _overflow * scrollT;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Measure text width
        final tp = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();

        final textWidth = tp.width;
        final containerWidth = constraints.maxWidth;
        final overflow = textWidth - containerWidth;

        if (!widget.enabled) {
          _controller?.dispose();
          _controller = null;
          _needsScroll = false;
          _overflow = 0;
          return Text(
            widget.text,
            style: widget.style,
            textAlign: widget.textAlign,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }

        if (overflow <= 0) {
          // No overflow — static text
          _controller?.dispose();
          _controller = null;
          _needsScroll = false;
          _overflow = 0;
          return Text(
            widget.text,
            style: widget.style,
            textAlign: widget.textAlign,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }

        // Overflow detected — set up scrolling
        if (!_needsScroll || _controller == null || (overflow - _overflow).abs() > 1.0) {
          _controller?.dispose();
          _controller = null;
          _needsScroll = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _setupAnimation(overflow);
            }
          });
        }

        return ClipRect(
          child: Transform.translate(
            offset: Offset(-_currentOffset, 0),
            child: SizedBox(
              width: textWidth,
              child: Text(
                widget.text,
                style: widget.style,
                textAlign: widget.textAlign,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A [MarqueeText] wrapper that only animates while [focusNode] has focus.
class FocusedMarqueeText extends StatelessWidget {
  const FocusedMarqueeText({
    super.key,
    required this.focusNode,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.start,
    this.velocity = 35.0,
    this.startPause = const Duration(seconds: 2),
    this.endPause = const Duration(milliseconds: 1500),
  });

  final FocusNode focusNode;
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final double velocity;
  final Duration startPause;
  final Duration endPause;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, _) {
        return MarqueeText(
          text: text,
          style: style,
          enabled: focusNode.hasFocus,
          textAlign: textAlign,
          velocity: velocity,
          startPause: startPause,
          endPause: endPause,
        );
      },
    );
  }
}
