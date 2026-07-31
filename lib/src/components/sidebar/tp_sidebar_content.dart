import 'package:flutter/material.dart';

/// Scrollable middle slot inside [TpSidebar]. Use inside a [Column] with
/// [TpSidebarHeader] / [TpSidebarFooter].
class TpSidebarContent extends StatelessWidget {
  const TpSidebarContent({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: child,
      ),
    );
  }
}
