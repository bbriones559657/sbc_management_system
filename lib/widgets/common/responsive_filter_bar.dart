import 'package:flutter/material.dart';

/// Keeps search visible while narrow screens scroll filters in one row.
class ResponsiveFilterBar extends StatelessWidget {
  final Widget primary;
  final List<Widget> filters;
  final List<double> filterWidths;
  final double breakpoint;
  final double gap;

  const ResponsiveFilterBar({
    super.key,
    required this.primary,
    required this.filters,
    required this.filterWidths,
    this.breakpoint = 760,
    this.gap = 12,
  });

  @override
  Widget build(BuildContext context) {
    assert(filters.length == filterWidths.length);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              primary,
              SizedBox(height: gap),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int index = 0; index < filters.length; index++) ...[
                      if (index > 0) SizedBox(width: gap),
                      SizedBox(width: filterWidths[index], child: filters[index]),
                    ],
                  ],
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: primary),
            for (int index = 0; index < filters.length; index++) ...[
              SizedBox(width: gap),
              SizedBox(width: filterWidths[index], child: filters[index]),
            ],
          ],
        );
      },
    );
  }
}
