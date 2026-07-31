import 'package:flutter/material.dart';

import 'tp_sidebar_config.dart';
import 'tp_sidebar_scope.dart';

/// Whether chrome should hide for desktop icon-rail collapse.
bool hideInIconCollapse(BuildContext context) {
  final config = TpSidebarConfig.maybeOf(context);
  final scope = TpSidebarScope.maybeOf(context);
  if (config == null || scope == null) return false;
  return config.collapsible == TpSidebarCollapsible.icon &&
      scope.state == TpSidebarDesktopState.collapsed &&
      !scope.isMobile;
}
