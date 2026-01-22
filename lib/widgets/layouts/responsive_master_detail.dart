import 'package:flutter/material.dart';
import '../../utils/localization_extension.dart';
import '../../utils/responsive_breakpoints.dart';
import 'collapsible_sidebar.dart';

/// A responsive master-detail layout widget
///
/// Provides adaptive navigation patterns:
/// - **Mobile**: Traditional stack navigation (master → detail)
/// - **Tablet/Desktop**: Split-screen with collapsible sidebar (master + detail)
///
/// Features:
/// - Collapsible sidebar on tablet/desktop
/// - Tab switcher for multiple master views (e.g., Devices/Systems)
/// - Selected item highlighting in master list
/// - Automatic layout adaptation on window resize
///
/// Example usage:
/// ```dart
/// ResponsiveMasterDetail(
///   tabs: [
///     SidebarTab(label: 'Geräte', icon: Icons.devices),
///     SidebarTab(label: 'Systeme', icon: Icons.grid_view),
///   ],
///   masterBuilder: (context, tabIndex, isExpanded, onItemSelected) {
///     return DeviceList(onDeviceSelected: onItemSelected);
///   },
///   detailBuilder: (context, selectedItem) {
///     return selectedItem != null
///         ? DeviceDetailView(device: selectedItem)
///         : EmptyDetailView();
///   },
/// )
/// ```
class ResponsiveMasterDetail<T> extends StatefulWidget {
  /// Sidebar tabs configuration
  final List<SidebarTab> tabs;

  /// Builder for master view (sidebar content)
  /// Receives: context, tab index, is expanded, item selection callback
  final Widget Function(
    BuildContext context,
    int tabIndex,
    bool isExpanded,
    void Function(T item) onItemSelected,
  ) masterBuilder;

  /// Builder for detail view (main content area)
  /// Receives: context, selected item (null if none selected)
  final Widget Function(BuildContext context, T? selectedItem) detailBuilder;

  /// Optional initial selected item
  final T? initialSelectedItem;

  /// Optional empty state widget shown when no item is selected (tablet/desktop only)
  final Widget? emptyDetailWidget;

  const ResponsiveMasterDetail({
    required this.tabs,
    required this.masterBuilder,
    required this.detailBuilder,
    this.initialSelectedItem,
    this.emptyDetailWidget,
    super.key,
  });

  @override
  State<ResponsiveMasterDetail<T>> createState() => _ResponsiveMasterDetailState<T>();
}

class _ResponsiveMasterDetailState<T> extends State<ResponsiveMasterDetail<T>> {
  T? _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialSelectedItem;
  }

  @override
  void didUpdateWidget(ResponsiveMasterDetail<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync internal state with updated initialSelectedItem
    if (widget.initialSelectedItem != oldWidget.initialSelectedItem) {
      setState(() {
        _selectedItem = widget.initialSelectedItem;
      });
    }
  }

  /// Handle item selection from master view
  void _onItemSelected(T item) {
    // Schedule state update after current frame to avoid mouse tracking conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedItem = item;
        });

        // On mobile, navigate to detail screen
        if (ResponsiveBreakpoints.isMobile(context)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => widget.detailBuilder(context, item),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mobile: Show only master view (detail is pushed as separate screen)
    if (ResponsiveBreakpoints.isMobile(context)) {
      return _buildMobileLayout();
    }

    // Tablet/Desktop: Show master-detail split-screen
    return _buildMasterDetailLayout();
  }

  /// Build mobile layout (master only, detail is pushed)
  Widget _buildMobileLayout() {
    // If only one tab, show it directly without tab switcher
    if (widget.tabs.length == 1) {
      return widget.masterBuilder(context, 0, true, _onItemSelected);
    }

    // Multiple tabs: Use TabBarView
    return DefaultTabController(
      length: widget.tabs.length,
      child: Column(
        children: [
          // Tab bar
          TabBar(
            tabs: widget.tabs.map((tab) {
              return Tab(
                icon: Icon(tab.icon),
                text: tab.label,
              );
            }).toList(),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              children: widget.tabs.asMap().entries.map((entry) {
                return widget.masterBuilder(context, entry.key, true, _onItemSelected);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build master-detail layout (tablet/desktop)
  Widget _buildMasterDetailLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Master view (collapsible sidebar)
            CollapsibleSidebar(
              tabs: widget.tabs,
              tabBuilder: (context, tabIndex, isExpanded) {
                return widget.masterBuilder(context, tabIndex, isExpanded, _onItemSelected);
              },
            ),

            // Detail view (main content area)
            Expanded(
              child: _selectedItem != null
                  ? widget.detailBuilder(context, _selectedItem)
                  : (widget.emptyDetailWidget ?? _buildEmptyDetail()),
            ),
          ],
        );
      },
    );
  }

  /// Build empty detail view (when no item selected)
  Widget _buildEmptyDetail() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noItemSelected,
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.selectItemFromList,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
