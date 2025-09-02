import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controllers/theme_controller.dart';
import 'chart.dart';
import 'storage_info_card.dart';

class StorageDetails extends StatelessWidget {
  const StorageDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return Container(
          padding: EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: getCardColor(themeController.isDarkMode),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: themeController.isDarkMode
                ? []
                : [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Storage Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: getTextColor(themeController.isDarkMode),
                ),
              ),
              SizedBox(height: defaultPadding),
              Chart(),
              StorageInfoCard(
                svgSrc: "assets/icons/Documents.svg",
                title: "Documents Files",
                amountOfFiles: "1.3GB",
                numOfFiles: 1328,
              ),
              StorageInfoCard(
                svgSrc: "assets/icons/media.svg",
                title: "Media Files",
                amountOfFiles: "15.3GB",
                numOfFiles: 1328,
              ),
              StorageInfoCard(
                svgSrc: "assets/icons/folder.svg",
                title: "Other Files",
                amountOfFiles: "1.3GB",
                numOfFiles: 1328,
              ),
              StorageInfoCard(
                svgSrc: "assets/icons/unknown.svg",
                title: "Unknown",
                amountOfFiles: "1.3GB",
                numOfFiles: 140,
              ),
            ],
          ),
        );
      },
    );
  }
}
