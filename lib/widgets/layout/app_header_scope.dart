import 'package:flutter/widgets.dart';

/// Widgets every page shows at the right of its header, such as the stock
/// alerts bell. Provided once by the shell and read by [AppPage], so a page
/// does not have to add them itself.
class AppHeaderScope extends InheritedWidget {
  final Widget? trailing;
  final VoidCallback? onRefresh;

  const AppHeaderScope({
    super.key,
    this.trailing,
    this.onRefresh,
    required super.child,
  });

  static Widget? trailingOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppHeaderScope>()?.trailing;

  /// A retry on one page reloads all open modules. Standalone screens can
  /// supply a local fallback when there is no app shell ancestor.
  static void refresh(
    BuildContext context, {
    VoidCallback? fallback,
    bool alsoRefreshLocal = false,
  }) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppHeaderScope>();
    scope?.onRefresh?.call();
    if (scope?.onRefresh == null || alsoRefreshLocal) fallback?.call();
  }

  @override
  bool updateShouldNotify(AppHeaderScope oldWidget) =>
      trailing != oldWidget.trailing || onRefresh != oldWidget.onRefresh;
}
