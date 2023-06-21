import 'package:flutter/material.dart';

class EvidencijaTheme {
  static final EvidencijaTheme _singleton = EvidencijaTheme._internal();

  factory EvidencijaTheme() {
    return _singleton;
  }

  EvidencijaTheme._internal();

  static const Color primaryColor = Color(0xff2b2e58);
  static const Color primaryColorAlt = Color(0xFF99BAE0);
  static const Color disabledColor = Color(0xFFD9D9D9);
  static const Color errorColor = Color(0xffc06e6e);
  static const Color textDarkColor = Color(0xff000000);
  static const Color textMediumColor = Color(0xff8e8e8e);
  static const Color textLightColor = Color(0xff9b9b9b);
  static const double defaultBorderRadius = 8.0;

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xff3e4c5e),
      primaryColor,
    ],
  );

  static const MaterialColor palette = MaterialColor(0xFF2B2E58, <int, Color>{
    50: Color(0xFFE6E6EB),
    100: Color(0xFFBFC0CD),
    200: Color(0xFF9597AC),
    300: Color(0xFF6B6D8A),
    400: Color(0xFF4B4D71),
    500: Color(0xFF2B2E58),
    600: Color(0xFF262950),
    700: Color(0xFF202347),
    800: Color(0xFF1A1D3D),
    900: Color(0xFF10122D),
  });

  ThemeData theme = ThemeData(
    primaryColor: primaryColor,
    disabledColor: disabledColor,
    canvasColor: const Color(0xfff2f2f2),
    scaffoldBackgroundColor: primaryColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      iconTheme: IconThemeData(
        size: 32,
        color: Colors.white,
      ),
      actionsIconTheme: IconThemeData(
        size: 32,
        color: Color.fromRGBO(29, 29, 29, 1),
      ),
    ),
    textTheme: const TextTheme(
      labelMedium: TextStyle(
        fontSize: 12,
        height: 2,
        color: Colors.white,
      ),
      labelLarge: TextStyle(
        fontSize: 12,
        height: 2,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        color: Colors.white,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: Colors.white,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.white,
      selectionHandleColor: primaryColorAlt,
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 20,
      ),
      border: OutlineInputBorder(
        borderSide: const BorderSide(
          color: primaryColorAlt,
        ),
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: primaryColorAlt,
        ),
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: errorColor,
        ),
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      outlineBorder: const BorderSide(
        color: primaryColorAlt,
      ),
      focusColor: Colors.white,
      labelStyle: TextStyle(color: primaryColorAlt),
      hintStyle: TextStyle(color: primaryColorAlt.withOpacity(0.6)),
    ),
    buttonTheme: const ButtonThemeData(
      shape: RoundedRectangleBorder(
        side: BorderSide(),
      ),
      disabledColor: disabledColor,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: const MaterialStatePropertyAll(Size.fromHeight(50)),
        backgroundColor: MaterialStateColor.resolveWith(
          (states) {
            return states.contains(MaterialState.disabled)
                ? disabledColor
                : primaryColorAlt;
          },
        ),
        foregroundColor: MaterialStateProperty.all(Colors.black),
        overlayColor: MaterialStatePropertyAll(
          Colors.white.withOpacity(0.2),
        ),
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
        ),
        elevation: const MaterialStatePropertyAll(0),
        shadowColor: MaterialStatePropertyAll(Colors.transparent),
        textStyle: MaterialStatePropertyAll(
          TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        padding: const MaterialStatePropertyAll(
          EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 20,
          ),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
          minimumSize: const MaterialStatePropertyAll(Size.fromHeight(50)),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            return states.contains(MaterialState.disabled)
                ? disabledColor
                : primaryColorAlt;
          }),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            return states.contains(MaterialState.disabled)
                ? disabledColor.withOpacity(0.3)
                : Colors.transparent;
          }),
          overlayColor: MaterialStatePropertyAll(
            palette.shade300.withOpacity(0.5),
          ),
          side: MaterialStateProperty.resolveWith((states) {
            return BorderSide(
                color: states.contains(MaterialState.disabled)
                    ? disabledColor
                    : primaryColorAlt);
          }),
          shape: MaterialStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          )),
          textStyle: MaterialStatePropertyAll(
            TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          )),
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: palette)
        .copyWith(error: errorColor),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryColorAlt.withOpacity(0.7),
      contentTextStyle: const TextStyle(color: Colors.black),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
      elevation: 0,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: Colors.white,
      circularTrackColor: primaryColorAlt.withOpacity(0.6),
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 2, color: primaryColorAlt),
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      backgroundColor: primaryColor,
    ),
    listTileTheme: ListTileThemeData(
      dense: true,
      minVerticalPadding: 0,
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
      horizontalTitleGap: 0,
      selectedTileColor: primaryColorAlt,
      tileColor: primaryColorAlt,
      textColor: Colors.black,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 2,
          color: primaryColorAlt,
        ),
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      childrenPadding: EdgeInsets.all(20),
      collapsedBackgroundColor: primaryColorAlt,
      backgroundColor: primaryColor,
      collapsedTextColor: Colors.black,
      textColor: Colors.white,
      collapsedIconColor: Colors.black,
      iconColor: Colors.white,
      collapsedShape: RoundedRectangleBorder(
        side: BorderSide(
          width: 2,
          color: primaryColorAlt,
        ),
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 2,
          color: primaryColorAlt,
        ),
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
    ),
  );
}
