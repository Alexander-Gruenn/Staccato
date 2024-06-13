import 'package:flutter/material.dart';

//TODO specify how the themes should look like
//The light theme of the app
final defaultLightTheme = ThemeData.light();

//The dark theme of the app
final defaultDarkTheme = ThemeData.dark();

const primaryOrangeLightThemeColor = Colors.deepOrange;
const secondaryOrangeLightThemeColor = Colors.orange;
const backgroundOrangeLightThemeColor = Colors.orangeAccent;
const iconAndTextOrangeLightThemeColor = Colors.white;

final orangeLightTheme = ThemeData(
    colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryOrangeLightThemeColor,
        onPrimary: iconAndTextOrangeLightThemeColor,
        secondary: secondaryOrangeLightThemeColor,
        onSecondary: iconAndTextOrangeLightThemeColor,
        error: Colors.red,
        onError: iconAndTextOrangeLightThemeColor,
        background: backgroundOrangeLightThemeColor,
        onBackground: iconAndTextOrangeLightThemeColor,
        surface: secondaryOrangeLightThemeColor,
        onSurface: primaryOrangeLightThemeColor),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
          fontSize: 90,
          fontWeight: FontWeight.w700,
          color: primaryOrangeLightThemeColor,
          shadows: [
            Shadow(offset: Offset(2, 2), blurRadius: 8, color: Colors.black54)
          ]
      ),
      bodyMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: primaryOrangeLightThemeColor,
      ),
      bodySmall: TextStyle(
        fontSize: 15,
        color: Colors.grey,
      ),
      titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: iconAndTextOrangeLightThemeColor),
      titleSmall: TextStyle(fontSize: 14, color: Colors.white70),
      displaySmall:
          TextStyle(fontSize: 14, color: iconAndTextOrangeLightThemeColor),
      displayMedium:
          TextStyle(fontSize: 16, color: iconAndTextOrangeLightThemeColor),
      labelMedium: TextStyle(
        fontSize: 18,
        color: Colors.black,
      ),
    ),
    iconTheme: const IconThemeData(color: iconAndTextOrangeLightThemeColor),
    highlightColor: secondaryOrangeLightThemeColor,
    hoverColor: secondaryOrangeLightThemeColor.shade800,
    elevatedButtonTheme: const ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(9)))),
        minimumSize: MaterialStatePropertyAll(Size(155, 38)),
      ),
    ),
    appBarTheme: const AppBarTheme(
        foregroundColor: iconAndTextOrangeLightThemeColor,
        backgroundColor: primaryOrangeLightThemeColor));

const primaryBlueGreyDarkThemeColor = Colors.blueGrey;
const secondaryBlueGreyDarkThemeColor = Colors.grey;
const backgroundBlueGreyDarkThemeColor = Colors.black54;
const iconAndTextBlueGreyDarkThemeColor = Colors.black;

final blueGreyDarkTheme = ThemeData(
    colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: primaryBlueGreyDarkThemeColor,
        onPrimary: iconAndTextBlueGreyDarkThemeColor,
        secondary: secondaryBlueGreyDarkThemeColor,
        onSecondary: iconAndTextBlueGreyDarkThemeColor,
        error: Colors.red,
        onError: iconAndTextBlueGreyDarkThemeColor,
        background: backgroundBlueGreyDarkThemeColor,
        onBackground: iconAndTextBlueGreyDarkThemeColor,
        surface: secondaryBlueGreyDarkThemeColor,
        onSurface: primaryBlueGreyDarkThemeColor),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
          fontSize: 90,
          fontWeight: FontWeight.w700,
          color: primaryBlueGreyDarkThemeColor,
          shadows: [
            Shadow(offset: Offset(2, 2), blurRadius: 8, color: Colors.black87)
          ]
      ),
      bodyMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: primaryBlueGreyDarkThemeColor,
      ),
      bodySmall: TextStyle(
        fontSize: 15,
        color: Colors.white70,
      ),
      titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: iconAndTextBlueGreyDarkThemeColor),
      titleSmall: TextStyle(fontSize: 14, color: Colors.black54),
      displaySmall:
          TextStyle(fontSize: 14, color: iconAndTextBlueGreyDarkThemeColor),
      displayMedium:
          TextStyle(fontSize: 16, color: iconAndTextBlueGreyDarkThemeColor),
      labelMedium: TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
    ),
    iconTheme: const IconThemeData(color: iconAndTextBlueGreyDarkThemeColor),
    highlightColor: secondaryBlueGreyDarkThemeColor,
    hoverColor: secondaryBlueGreyDarkThemeColor,
    elevatedButtonTheme: const ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(9)))),
        minimumSize: MaterialStatePropertyAll(Size(155, 38)),
      ),
    ),
    appBarTheme: const AppBarTheme(
        foregroundColor: iconAndTextBlueGreyDarkThemeColor,
        backgroundColor: primaryBlueGreyDarkThemeColor));
