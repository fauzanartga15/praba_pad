import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controllers/menu_app_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../responsive.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Text("Dashboard", style: Theme.of(context).textTheme.titleLarge),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        Expanded(child: SearchField()),
        ThemeToggleButton(),
        ProfileCard(),
      ],
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return Container(
          margin: EdgeInsets.only(left: defaultPadding / 2),
          child: IconButton(
            onPressed: themeController.toggleTheme,
            icon: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Icon(
                themeController.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                key: ValueKey(themeController.isDarkMode),
                color: themeController.isDarkMode
                    ? Colors.white70
                    : Colors.black54,
              ),
            ),
            tooltip: themeController.isDarkMode
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
          ),
        );
      },
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return Container(
          margin: EdgeInsets.only(left: defaultPadding),
          padding: EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: defaultPadding / 2,
          ),
          decoration: BoxDecoration(
            color: getCardColor(themeController.isDarkMode),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: getBorderColor(themeController.isDarkMode),
            ),
          ),
          child: Row(
            children: [
              Image.asset("assets/images/profile_pic.png", height: 38),
              if (!Responsive.isMobile(context))
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding / 2,
                  ),
                  child: Text(
                    "Angelina Jolie",
                    style: TextStyle(
                      color: getTextColor(themeController.isDarkMode),
                    ),
                  ),
                ),
              Icon(
                Icons.keyboard_arrow_down,
                color: getTextColor(themeController.isDarkMode),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return TextField(
          style: TextStyle(color: getTextColor(themeController.isDarkMode)),
          decoration: InputDecoration(
            hintText: "Search",
            hintStyle: TextStyle(
              color: themeController.isDarkMode
                  ? Colors.white54
                  : Colors.black54,
            ),
            fillColor: getCardColor(themeController.isDarkMode),
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            suffixIcon: InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(defaultPadding * 0.75),
                margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: SvgPicture.asset(
                  "assets/icons/Search.svg",
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
