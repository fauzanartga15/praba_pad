import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controllers/theme_controller.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return Drawer(
          backgroundColor: getCardColor(themeController.isDarkMode),
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: getCardColor(themeController.isDarkMode),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      "assets/images/logo.png",
                      width: 34,
                      height: 34,
                    ),
                    SizedBox(width: 5),
                    Text(
                      "Praba",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              DrawerListTile(
                title: "Dashboard",
                svgSrc: "assets/icons/menu_dashboard.svg",
                press: () {},
              ),
              DrawerListTile(
                title: "Supplier",
                svgSrc: "assets/icons/menu_tran.svg",
                press: () {},
              ),
              DrawerListTile(
                title: "Buat Pembelian",
                svgSrc: "assets/icons/menu_task.svg",
                press: () {},
              ),
              DrawerListTile(
                title: "Lihat Pembelian",
                svgSrc: "assets/icons/menu_doc.svg",
                press: () {},
              ),
              DrawerListTile(
                title: "Notification",
                svgSrc: "assets/icons/menu_notification.svg",
                press: () {},
              ),
              DrawerListTile(
                title: "Settings",
                svgSrc: "assets/icons/menu_setting.svg",
                press: () {},
              ),
              Divider(color: getBorderColor(themeController.isDarkMode)),
              // Theme toggle in drawer for mobile
              DrawerListTile(
                title: themeController.isDarkMode ? "Light Mode" : "Dark Mode",
                svgSrc: themeController.isDarkMode
                    ? "assets/icons/menu_setting.svg"
                    : "assets/icons/menu_setting.svg",
                press: themeController.toggleTheme,
                isThemeToggle: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    required this.svgSrc,
    required this.press,
    this.isThemeToggle = false,
  });

  final String title, svgSrc;
  final VoidCallback press;
  final bool isThemeToggle;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return ListTile(
          onTap: press,
          horizontalTitleGap: 0.0,
          leading: isThemeToggle
              ? Icon(
                  themeController.isDarkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: themeController.isDarkMode
                      ? Colors.white54
                      : Colors.black54,
                  size: 16,
                )
              : SvgPicture.asset(
                  svgSrc,
                  colorFilter: ColorFilter.mode(
                    themeController.isDarkMode
                        ? Colors.white54
                        : Colors.black54,
                    BlendMode.srcIn,
                  ),
                  height: 16,
                ),
          title: Text(
            title,
            style: TextStyle(
              color: themeController.isDarkMode
                  ? Colors.white54
                  : Colors.black54,
            ),
          ),
        );
      },
    );
  }
}
