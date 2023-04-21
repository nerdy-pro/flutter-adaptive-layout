import 'package:flutter/material.dart';
import 'package:flutter_adaptive_layout/qualifiers/screen_size_qualifier.dart';
import 'package:flutter_adaptive_layout/screen_size/screen_size.dart';

const _defaultSmallBreakpoint = 400;
const _defaultMediumBreakpoint = 600;

class BreakpointsQualifier extends ScreenSizeQualifier {
  final num? smallBreakpoint;
  final num? mediumBreakpoint;

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
  final num smallScreenBreakpoint;
  final num mediumScreenBreakpoint;

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
