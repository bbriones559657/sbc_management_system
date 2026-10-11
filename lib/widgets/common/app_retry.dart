import 'package:flutter/material.dart';

import '../../core/error_text.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../layout/app_header_scope.dart';

/// Retries the whole open app when the shell is present, so a recovered
/// connection refreshes other modules as well as this one.
class AppRetryButton extends StatelessWidget {
  final VoidCallback? fallback;
  final bool alsoRefreshLocal;

  const AppRetryButton({
    super.key,
    this.fallback,
    this.alsoRefreshLocal = false,
  });

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: () => AppHeaderScope.refresh(
      context,
      fallback: fallback,
      alsoRefreshLocal: alsoRefreshLocal,
    ),
    child: const Text('Try again'),
  );
}

class AppRetryPanel extends StatelessWidget {
  final String message;
  final Object? error;
  final VoidCallback? fallback;

  const AppRetryPanel({
    super.key,
    required this.message,
    this.error,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            error == null ? message : '$message\n${errorText(error)}',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          AppRetryButton(fallback: fallback),
        ],
      ),
    ),
  );
}
