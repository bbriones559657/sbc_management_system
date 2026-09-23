import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'header_brand_motif.dart';

class AppPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;

  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSubtitle = subtitle ?? _todayLabel();

    return ColoredBox(
      color: AppColors.gray100,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: HeaderBrandMotif(),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppTextStyles.h1),
                            const SizedBox(height: 2),
                            Text(
                              effectiveSubtitle,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.gray500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ?action,
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _todayLabel() {
    const weekdays = [
      'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday',
    ];
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December',
    ];

    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, '
        '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}
