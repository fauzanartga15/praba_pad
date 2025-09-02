import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controllers/theme_controller.dart';
import '../../../models/my_files.dart';

class FileInfoCard extends StatelessWidget {
  const FileInfoCard({super.key, required this.info});

  final CloudStorageInfo info;

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
                      color: Colors.grey.withValues(alpha: 0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(defaultPadding * 0.75),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: info.color!.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: SvgPicture.asset(
                      info.svgSrc!,
                      colorFilter: ColorFilter.mode(
                        info.color ?? Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Icon(Icons.more_vert, color: Colors.white54),
                ],
              ),
              Text(info.title!, maxLines: 1, overflow: TextOverflow.ellipsis),
              ProgressLine(color: info.color, percentage: info.percentage),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${info.numOfFiles} Files",
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: Colors.white70),
                  ),
                  Text(
                    info.totalStorage!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    super.key,
    this.color = primaryColor,
    required this.percentage,
  });

  final Color? color;
  final int? percentage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 5,
          decoration: BoxDecoration(
            color: color!.withValues(alpha: 0.1),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) => Container(
            width: constraints.maxWidth * (percentage! / 100),
            height: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
