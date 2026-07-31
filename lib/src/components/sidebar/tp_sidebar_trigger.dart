import 'package:flutter/material.dart';

import '../icon_button/tp_icon_button.dart';
import 'tp_sidebar_scope.dart';

/// Toolbar control that toggles the sidebar via [TpSidebarScope.toggleSidebar].
class TpSidebarTrigger extends StatelessWidget {
  const TpSidebarTrigger({
    super.key,
    this.icon,
    this.tooltip,
  });

  final Widget? icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return TpIconButton(
      iconWidget: icon ?? const Icon(Icons.menu),
      onTap: TpSidebarScope.of(context).toggleSidebar,
      tooltip: tooltip,
    );
  }
}
