import 'package:flutter/material.dart';
import 'package:flutter_adaptive_layout/qualifiers/screen_size_qualifier.dart';
import 'package:flutter_adaptive_layout/screen_size/screen_size.dart';

const _defaultSmallBreakpoint = 400;
const _defaultMediumBreakpoint = 600;

class BreakpointsQualifier extends ScreenSizeQualifier {
  /// [ScreenSize.small] to [ScreenSize.medium] breakpoint size. Defaults to `400`
  final num? smallBreakpoint;

  /// [ScreenSize.medium] to [ScreenSize.large] breakpoint size. Defaults to `600`
  final num? mediumBreakpoint;

  /// The default qualifier that will fall back to `400` for [ScreenSize.small] screens and `600` for [ScreenSize.medium], all the rest will be treated as [ScreenSize.large]
  /// Optionally you can override the defaults be wrapping your widget tree with [BreakpointsSetting]
  BreakpointsQualifier({
    this.smallBreakpoint,
    this.mediumBreakpoint,
  });

  @override
  ScreenSize qualify(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final breakpoints = BreakpointsSetting._maybeOf(context);

    final smallBreakpoint = this.smallBreakpoint ??
        breakpoints?.smallScreenBreakpoint ??
        _defaultSmallBreakpoint;
    final mediumBreakpoint = this.mediumBreakpoint ??
        breakpoints?.mediumScreenBreakpoint ??
        _defaultMediumBreakpoint;

    if (shortestSide <= smallBreakpoint) {
      return ScreenSize.small;
    }
    if (shortestSide <= mediumBreakpoint) {
      return ScreenSize.medium;
    }
    return ScreenSize.large;
  }
}

class BreakpointsSetting extends InheritedWidget {
  /// [ScreenSize.small] to [ScreenSize.medium] breakpoint size. Defaults to `400`
  final num smallScreenBreakpoint;

  /// [ScreenSize.medium] to [ScreenSize.large] breakpoint size. Defaults to `600`
  final num mediumScreenBreakpoint;

  /// Wrap your widget tree with [BreakpointsSetting] to override breakpoints for extracted [ScreenSize] qualificators.
  const BreakpointsSetting({
    super.key,
    required super.child,
    required this.smallScreenBreakpoint,
    required this.mediumScreenBreakpoint,
  });

  @override
  bool updateShouldNotify(BreakpointsSetting oldWidget) {
    return oldWidget.smallScreenBreakpoint != smallScreenBreakpoint ||
        oldWidget.mediumScreenBreakpoint != mediumScreenBreakpoint;
  }

  static BreakpointsSetting? _maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BreakpointsSetting>();
  }
}
