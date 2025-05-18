import 'package:flutter/material.dart';


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
      unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.black54,
      tabs: tabTitles.map((title) => Tab(text: title)).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}
