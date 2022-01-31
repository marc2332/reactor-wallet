library public;

import 'package:flutter/material.dart';

extension CustomColors on ThemeData {
  Color iconThemeColor() {
    return (this.brightness == Brightness.light) ? Colors.black54 : Colors.white70;
  }

  Color get iconColor => iconThemeColor();
}
