import 'package:flutter/material.dart';

import '../../../../core/helper/my_navigator.dart';
import '../../../../core/helper/my_responsive.dart';
import '../../../../core/shared_widgets/svg_wrapper.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_text_styles.dart';

class ProfileRowWidget extends StatelessWidget {
  final String title;
  final String imagePath;

  final Widget goTo;

  const ProfileRowWidget({
    super.key,
    required this.title,
    required this.imagePath,
    required this.goTo,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => MyNavigator.goTo(screen: goTo),
      child: Row(
        children: [
          SvgWrapper(
            path: imagePath,
            width: MyResponsive.width(value: 20),
          ),
          SizedBox(width: MyResponsive.width(value: 20)),
          Text(
            title,
            style: AppTextStyles.medium18,
          ),
          const Spacer(),
          SvgWrapper(
            path: AppAssets.forwardArrow,
          ),
        ],
      ),
    );
  }
}
