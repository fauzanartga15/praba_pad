import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controllers/theme_controller.dart';

class StorageInfoCard extends StatelessWidget {
  const StorageInfoCard({
    super.key,
    required this.title,
    required this.svgSrc,
    required this.amountOfFiles,
    required this.numOfFiles,
  });

  final String title, svgSrc, amountOfFiles;
  final int numOfFiles;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return Container(
          margin: EdgeInsets.only(top: defaultPadding),
          padding: EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: themeController.isDarkMode
                  ? primaryColor.withValues(alpha: 0.15)
                  : primaryColor.withValues(alpha: 0.1),
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(defaultPadding),
            ),
            color: themeController.isDarkMode
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.8),
          ),
          child: Row(
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: SvgPicture.asset(
                  svgSrc,
                  colorFilter: ColorFilter.mode(
                    themeController.isDarkMode
                        ? Colors.white70
                        : Colors.black87,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: getTextColor(themeController.isDarkMode),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "$numOfFiles Files",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: themeController.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                amountOfFiles,
                style: TextStyle(
                  color: getTextColor(themeController.isDarkMode),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
