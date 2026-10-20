import 'package:flutter/material.dart';

class Breakpoints {
  Breakpoints._();

  static const double compact = 600.0;
  static const double medium = 1024.0;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isCompact => screenWidth < Breakpoints.compact;
  bool get isMedium => screenWidth >= Breakpoints.compact && screenWidth <= Breakpoints.medium;
  bool get isExpanded => screenWidth > Breakpoints.medium;
}

class ResponsiveLayout extends StatelessWidget {
  final Widget compact;
  final Widget? medium;
  final Widget? expanded;

  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > Breakpoints.medium && expanded != null) {
          return expanded!;
        }
        if (constraints.maxWidth >= Breakpoints.compact && medium != null) {
          return medium!;
        }
        return compact;
      },
    );
  }
}
