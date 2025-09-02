import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:praba_ipad/constants.dart';
import 'package:provider/provider.dart';

import 'controllers/menu_app_controller.dart';
import 'controllers/theme_controller.dart';
import 'screens/main/main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MenuAppController()),
        ChangeNotifierProvider(create: (context) => ThemeController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Admin Panel',
            theme: themeController.isDarkMode
                ? _buildDarkTheme(context)
                : _buildLightTheme(context),
            home: MainScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildDarkTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bgColor,
      textTheme: GoogleFonts.poppinsTextTheme(
        Theme.of(context).textTheme,
      ).apply(bodyColor: Colors.white),
      canvasColor: secondaryColor,
      cardColor: secondaryColor,
      dividerColor: Colors.white10,
    );
  }

  ThemeData _buildLightTheme(BuildContext context) {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: bgColorLight,
      textTheme: GoogleFonts.poppinsTextTheme(
        Theme.of(context).textTheme,
      ).apply(bodyColor: Colors.black87),
      canvasColor: secondaryColorLight,
      cardColor: Colors.white,
      dividerColor: Colors.grey.shade300,
    );
  }
}
