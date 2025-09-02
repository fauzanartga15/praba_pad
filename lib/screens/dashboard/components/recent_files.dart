import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controllers/theme_controller.dart';
import '../../../models/recent_file.dart';

class RecentFiles extends StatelessWidget {
  const RecentFiles({super.key});

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
                "Recent Files",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: getTextColor(themeController.isDarkMode),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: getBorderColor(themeController.isDarkMode),
                    dataTableTheme: DataTableThemeData(
                      headingTextStyle: TextStyle(
                        color: getTextColor(themeController.isDarkMode),
                        fontWeight: FontWeight.w600,
                      ),
                      dataTextStyle: TextStyle(
                        color: getTextColor(themeController.isDarkMode),
                      ),
                    ),
                  ),
                  child: DataTable(
                    columnSpacing: defaultPadding,
                    columns: [
                      DataColumn(
                        label: Text(
                          "File Name",
                          style: TextStyle(
                            color: getTextColor(themeController.isDarkMode),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Date",
                          style: TextStyle(
                            color: getTextColor(themeController.isDarkMode),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Size",
                          style: TextStyle(
                            color: getTextColor(themeController.isDarkMode),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    rows: List.generate(
                      demoRecentFiles.length,
                      (index) => recentFileDataRow(
                        demoRecentFiles[index],
                        themeController.isDarkMode,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

DataRow recentFileDataRow(RecentFile fileInfo, bool isDarkMode) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            SvgPicture.asset(fileInfo.icon!, height: 30, width: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(
                fileInfo.title!,
                style: TextStyle(color: getTextColor(isDarkMode)),
              ),
            ),
          ],
        ),
      ),
      DataCell(
        Text(fileInfo.date!, style: TextStyle(color: getTextColor(isDarkMode))),
      ),
      DataCell(
        Text(fileInfo.size!, style: TextStyle(color: getTextColor(isDarkMode))),
      ),
    ],
  );
}
