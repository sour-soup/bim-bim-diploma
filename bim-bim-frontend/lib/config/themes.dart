import 'package:flutter/material.dart';

const Color primaryColor = Color.fromARGB(255, 3, 173, 162);
const Color secondaryColor = Colors.purple;
const Color accentColorDark = Color(0xFFBB86FC);
const Color accentColorLight = Color(0xFF6200EE);

// --- ТЕМНАЯ ТЕМА ---
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardColor: const Color(0xFF1E1E1E),
  dialogBackgroundColor: const Color(0xFF1E1E1E),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    iconTheme: IconThemeData(color: primaryColor),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    selectedItemColor: primaryColor,
    unselectedItemColor: secondaryColor,
  ),

  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white70),
    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: Colors.white),
  ),

  iconTheme: const IconThemeData(color: primaryColor),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 10,
      side: const BorderSide(color: secondaryColor, width: 2),
    ),
  ),
  
  colorScheme: const ColorScheme.dark(
    primary: primaryColor,
    secondary: secondaryColor,
    surface: Color(0xFF121212),
    background: Color(0xFF121212),
    onPrimary: Colors.black,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onBackground: Colors.white,
    error: Colors.redAccent,
    onError: Colors.white,
  ).copyWith(secondary: accentColorDark),
);


// --- СВЕТЛАЯ ТЕМА ---
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: Colors.grey[100],
  cardColor: Colors.white,
  dialogBackgroundColor: Colors.white,
  
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[100],
    elevation: 0,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    iconTheme: const IconThemeData(color: primaryColor),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: primaryColor,
    unselectedItemColor: secondaryColor,
  ),

  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black87),
    titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: Colors.black),
  ),

  iconTheme: const IconThemeData(color: primaryColor),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 10,
      side: const BorderSide(color: secondaryColor, width: 2),
    ),
  ),

  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: secondaryColor,
    surface: Colors.white,
    background: Colors.grey[100]!,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.black,
    onBackground: Colors.black,
    error: Colors.red,
    onError: Colors.white,
  ).copyWith(secondary: accentColorLight),
);