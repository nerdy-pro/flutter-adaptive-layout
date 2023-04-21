import 'package:flutter/cupertino.dart';
import 'package:flutter_adaptive_layout/screen_size/screen_size.dart';

/// An abstract class that has to be implemented if you would like to have your own logic of qualifying the device.
/// See [BreakpointsQualifier] which is a default implementation
abstract class ScreenSizeQualifier {
  /// The qualification has to be implemented here. Default ([BreakpointsQualifier]) implementation will simply extract the smallest side's size from the [MediaQuery] and apply breakpoints to it
  ScreenSize qualify(BuildContext context);
}
