import 'package:flutter/cupertino.dart';
import 'package:flutter_adaptive_layout/qualifiers/breakpoints_qualifier.dart';
import 'package:flutter_adaptive_layout/qualifiers/screen_size_qualifier.dart';
import 'package:flutter_adaptive_layout/screen_size/screen_size.dart';

typedef AdaptiveBuilder = Widget Function(BuildContext context, Widget? child);

class AdaptiveLayout extends StatelessWidget {
  final Widget? child;
  final AdaptiveBuilder? largeBuilder;
  final AdaptiveBuilder? mediumBuilder;
  final AdaptiveBuilder? smallBuilder;
  final ScreenSizeQualifier? qualifier;

  const AdaptiveLayout({
    super.key,
    this.largeBuilder,
    this.mediumBuilder,
    required this.smallBuilder,
    this.child,
    this.qualifier,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = (qualifier ?? BreakpointsQualifier()).qualify(context);
    final Widget? result;
    switch (screenSize) {
      case ScreenSize.small:
        result = smallBuilder?.call(context, child) ?? child;
        break;
      case ScreenSize.medium:
        result = mediumBuilder?.call(context, child) ?? child;
        break;
      case ScreenSize.large:
        result = largeBuilder?.call(context, child) ?? child;
        break;
    }
    if (result == null) {
      throw Exception(
          'Either a builder or child for screen size of $screenSize should return a value');
    }
    return result;
  }
}
