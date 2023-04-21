import 'package:flutter/cupertino.dart';
import 'package:flutter_adaptive_layout/screen_size/screen_size.dart';

abstract class ScreenSizeQualifier {
  ScreenSize qualify(BuildContext context);
}
