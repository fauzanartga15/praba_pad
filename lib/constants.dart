import 'package:flutter/material.dart';

// Dark Theme Colors
const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);

// Light Theme Colors
const primaryColorLight = Color(0xFF2697FF);
const secondaryColorLight = Color(0xFFF5F5F5);
const bgColorLight = Color(0xFFFFFFFF);

const defaultPadding = 16.0;

// Dynamic colors based on theme
Color getPrimaryColor(bool isDark) => isDark ? primaryColor : primaryColorLight;
Color getSecondaryColor(bool isDark) =>
    isDark ? secondaryColor : secondaryColorLight;
Color getBgColor(bool isDark) => isDark ? bgColor : bgColorLight;
Color getTextColor(bool isDark) => isDark ? Colors.white : Colors.black87;
Color getCardColor(bool isDark) => isDark ? secondaryColor : Colors.white;
Color getBorderColor(bool isDark) =>
    isDark ? Colors.white10 : Colors.grey.shade300;
