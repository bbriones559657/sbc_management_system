import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

Future<T?> showPrototypeDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  List<Widget> actions = const [],
  double width = 520,
}) {
  return showDialog<T>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title, style: AppTextStyles.h2),
      content: SizedBox(width: width, child: content),
      actions: actions.isEmpty
          ? [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
            ]
          : actions,
    ),
  );
}

Widget dialogField(
  String label, {
  String? value,
  String? hint,
  int maxLines = 1,
  TextEditingController? controller,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? value : null,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    ),
  );
}
