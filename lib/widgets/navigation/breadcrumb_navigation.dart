import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/navigation/breadcrumb_provider.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/ui/ui_utils.dart';
import 'package:eventati_book/utils/ui/navigation_utils.dart';

/// A widget that displays a breadcrumb navigation path
class BreadcrumbNavigation extends StatelessWidget {
  /// Custom separator widget
  final Widget? separator;
  
  /// Custom style for breadcrumb text
  final TextStyle? textStyle;
  
  /// Custom style for the current (last) breadcrumb
  final TextStyle? currentTextStyle;
  
  /// Custom color for the separator
  final Color? separatorColor;
  
  /// Whether to scroll automatically to the end
  final bool autoScroll;
  
  /// Constructor
  const BreadcrumbNavigation({
    super.key,
    this.separator,
    this.textStyle,
    this.currentTextStyle,
    this.separatorColor,
    this.autoScroll = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = UIUtils.isDarkMode(context);
    
    // Default text styles
    final defaultTextStyle = textStyle ?? 
      TextStyles.bodyMedium.copyWith(
        color: isDarkMode ? Colors.white70 : Colors.black54,
      );
    
    final defaultCurrentTextStyle = currentTextStyle ?? 
      TextStyles.bodyMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.primaryColor,
      );
    
    // Default separator
    final defaultSeparator = separator ?? 
      Icon(
        Icons.chevron_right,
        size: 16,
        color: separatorColor ?? 
          (isDarkMode ? Colors.white54 : Colors.black38),
      );
    
    return Consumer<BreadcrumbProvider>(
      builder: (context, provider, _) {
        final breadcrumbs = provider.breadcrumbs;
        
        if (breadcrumbs.isEmpty) {
          return const SizedBox.shrink();
        }
        
        // Create a scroll controller if auto-scrolling is enabled
        final ScrollController? scrollController = 
          autoScroll ? ScrollController() : null;
        
        // Scroll to the end after the widget is built
        if (autoScroll && scrollController != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController.hasClients) {
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
        
        return SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(breadcrumbs.length * 2 - 1, (index) {
              // Even indices are breadcrumbs, odd indices are separators
              if (index.isEven) {
                final breadcrumbIndex = index ~/ 2;
                final breadcrumb = breadcrumbs[breadcrumbIndex];
                final isLast = breadcrumbIndex == breadcrumbs.length - 1;
                
                return InkWell(
                  onTap: isLast
                      ? null
                      : () {
                          // Navigate to this breadcrumb
                          provider.navigateToBreadcrumb(breadcrumbIndex);
                          NavigationUtils.navigateToNamed(
                            context,
                            breadcrumb.routeName,
                            arguments: breadcrumb.arguments,
                          );
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 4.0,
                    ),
                    child: Text(
                      breadcrumb.label,
                      style: isLast ? defaultCurrentTextStyle : defaultTextStyle,
                    ),
                  ),
                );
              } else {
                // Separator
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: defaultSeparator,
                );
              }
            }),
          ),
        );
      },
    );
  }
}
