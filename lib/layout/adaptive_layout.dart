import 'package:flutter/cupertino.dart';
import 'package:flutter_adaptive_layout/qualifiers/breakpoints_qualifier.dart';
import 'package:flutter_adaptive_layout/qualifiers/screen_size_qualifier.dart';
import 'package:flutter_adaptive_layout/screen_size/screen_size.dart';

typedef AdaptiveBuilder = Widget Function(BuildContext context, Widget? child);

class AdaptiveLayout extends StatelessWidget {

  /// [Widget] that would be wrapped by any of the builder-functions ([largeBuilder], [mediumBuilder] or [smallBuilder]) if provided.
  final Widget? child;

  /// Function used for building a [ScreenSize.large] layout
  final AdaptiveBuilder? largeBuilder;
  /// Function used for building a [ScreenSize.medium] layout
  final AdaptiveBuilder? mediumBuilder;
  /// Function used for building a [ScreenSize.small] layout
  final AdaptiveBuilder? smallBuilder;
  /// Qualifier class instance that extracts the real [ScreenSize] from the device, defaults to [BreakpointsQualifier]
  final ScreenSizeQualifier? qualifier;

  /// This widget will call the provided [qualifier] or [BreakpointsQualifier] if empty to extract the device's [ScreenSize] and build an appropriate layout for it.
  /// If [child] is provided, it will be built exactly once and than it will be used to call the matched builder function:
  /// [largeBuilder] for [ScreenSize.large], [mediumBuilder] for [ScreenSize.medium] and [smallBuilder] for [ScreenSize.small].
  /// If none of the builders is set, then the [child] would be returned.
  /// If neither any of the builders nor [child] is provided the [UnimplementedError] would be thrown.
  const AdaptiveLayout({
    super.key,
    this.largeBuilder,
    this.mediumBuilder,
    this.smallBuilder,
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
      throw UnimplementedError(
          'Either a builder or child for screen size of $screenSize should return a value');
    }
    return result;
  }
}
