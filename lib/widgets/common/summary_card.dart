import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'section_card.dart';

class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color accentColor;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 112,
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.caption),
                    const SizedBox(height: 5),
                    Text(value, style: AppTextStyles.h2.copyWith(fontSize: 23)),
                    const Spacer(),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(color: AppColors.gray500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
