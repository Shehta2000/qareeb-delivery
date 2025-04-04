import 'package:flutter/material.dart';

ThemeData dark = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: const Color(0xFFee4367),
  secondaryHeaderColor: const Color(0xFF009f67),
  disabledColor: const Color(0xFF6f7275),
  brightness: Brightness.dark,
  hintColor: const Color(0xFFbebebe),
  cardColor: Colors.black,
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: const Color(0xFFee4367)),
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFee4367),
    secondary: Color(0xFFee4367),
  ).copyWith(
    error: const Color(0xFFdd3135),
  ),
);
