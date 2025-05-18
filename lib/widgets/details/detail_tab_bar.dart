import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';

class DetailTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final List<String> tabTitles;

  const DetailTabBar({
    super.key,
    required this.tabController,
    required this.tabTitles,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return TabBar(
      controller: tabController,
      indicatorColor: isDarkMode ? Colors.white : theme.primaryColor,
      labelColor: isDarkMode ? Colors.white : theme.primaryColor,
      unselectedLabelColor:
          isDarkMode
              ? Color.fromRGBO(
                Colors.white.r.toInt(),
                Colors.white.g.toInt(),
                Colors.white.b.toInt(),
                0.7,
              )
              : AppColors.textSecondary,
      tabs: tabTitles.map((title) => Tab(text: title)).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}
