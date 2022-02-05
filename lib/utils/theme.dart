library public;

import 'package:flutter/material.dart';

extension CustomColors on ThemeData {
  Color get iconColor {
    return (brightness == Brightness.light) ? Colors.black54 : Colors.white70;
  }

  Color get fadedTextColor {
    return (brightness == Brightness.light) ? Colors.grey : Colors.white54;
  }
}

// Light theme style
ThemeData lighTheme = ThemeData(
  primarySwatch: Colors.blue,
);

// Dark theme style
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  dialogBackgroundColor: Colors.grey[850],
  dialogTheme: const DialogTheme(
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    contentTextStyle: TextStyle(color: Colors.white),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  appBarTheme: AppBarTheme(backgroundColor: Colors.yellow.shade800),
  cardTheme: CardTheme(
    color: Colors.grey[850],
  ),
  listTileTheme: const ListTileThemeData(textColor: Colors.white),
  primarySwatch: Colors.orange,
  dividerColor: Colors.grey[700],
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.grey[900],
    selectedIconTheme: IconThemeData(color: Colors.yellow.shade800),
    selectedItemColor: Colors.yellow.shade800,
    unselectedIconTheme: const IconThemeData(color: Colors.white),
  ),
  scaffoldBackgroundColor: Colors.grey[900],
  floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.yellow.shade800),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.all(Colors.yellow.shade800),
    trackColor: MaterialStateProperty.all(Colors.yellow.shade900),
  ),
  textTheme: const TextTheme(
    bodyText2: TextStyle(
      color: Colors.white,
    ),
    overline: TextStyle(
      color: Colors.white,
    ),
    button: TextStyle(
      color: Colors.white70,
    ),
  ),
);
