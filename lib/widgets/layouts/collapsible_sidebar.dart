import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/responsive_breakpoints.dart';

/// A collapsible sidebar widget for master-detail layouts
///
/// Features:
/// - Fixed 30% width when expanded
/// - 60px (tablet) / 80px (desktop) when collapsed
/// - Tab switcher at top when expanded (Devices/Systems)
/// - Icon-only display when collapsed
/// - State persisted in SharedPreferences
///
/// Example usage:
/// ```dart
/// CollapsibleSidebar(
///   tabs: [
///     SidebarTab(label: 'Geräte', icon: Icons.devices),
///     SidebarTab(label: 'Systeme', icon: Icons.grid_view),
///   ],
///   tabBuilder: (context, tabIndex, isExpanded) {
///     return tabIndex == 0 ? DeviceList() : SystemList();
///   },
/// )
/// ```
class CollapsibleSidebar extends StatefulWidget {
  /// List of tabs to display
  final List<SidebarTab> tabs;

  /// Builder function for tab content
  /// Receives: context, current tab index, whether sidebar is expanded
  final Widget Function(BuildContext context, int tabIndex, bool isExpanded) tabBuilder;

  /// Optional initial tab index (default: 0)
  final int initialTabIndex;

  /// Optional SharedPreferences key for state persistence
  final String prefsKey;

  const CollapsibleSidebar({
    required this.tabs,
    required this.tabBuilder,
    this.initialTabIndex = 0,
    this.prefsKey = 'sidebar_collapsed',
    super.key,
  });

  @override
  State<CollapsibleSidebar> createState() => _CollapsibleSidebarState();
}

class _CollapsibleSidebarState extends State<CollapsibleSidebar> {
  late bool _isCollapsed;
  late int _currentTabIndex;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTabIndex;
    _isCollapsed = false; // Default to expanded
    _loadCollapseState();
  }

  /// Load collapse state from SharedPreferences
  Future<void> _loadCollapseState() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCollapsed = _prefs?.getBool(widget.prefsKey) ?? false;
    });
  }

  /// Save collapse state to SharedPreferences
  Future<void> _saveCollapseState(bool collapsed) async {
    await _prefs?.setBool(widget.prefsKey, collapsed);
  }

  /// Toggle sidebar collapse state
  void _toggleCollapse() {
    // Schedule state update after current frame to avoid mouse tracking conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isCollapsed = !_isCollapsed;
        });
        _saveCollapseState(_isCollapsed);
      }
    });
  }

  /// Get sidebar width based on screen size and collapse state
  double _getSidebarWidth(BuildContext context) {
    if (_isCollapsed) {
      // Collapsed width (icon only) - always 80px
      return 80.0;
    } else {
      // Expanded width (30% of screen, max 400px)
      final screenWidth = ResponsiveBreakpoints.getScreenWidth(context);
      final calculatedWidth = screenWidth * 0.3;
      return calculatedWidth > 400 ? 400 : calculatedWidth;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = _getSidebarWidth(context);

    return AnimatedContainer(
      key: const ValueKey('collapsible_sidebar'),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: sidebarWidth,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with collapse button
          _buildHeader(),

          // Tab switcher (only when expanded)
          if (!_isCollapsed && widget.tabs.length > 1) _buildTabSwitcher(),

          // Divider
          if (!_isCollapsed)
            Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.3),
            ),

          // Content area
          Expanded(
            child: _isCollapsed ? _buildCollapsedView() : _buildExpandedView(),
          ),
        ],
      ),
    );
  }

  /// Build expanded view with full content
  Widget _buildExpandedView() {
    return widget.tabBuilder(context, _currentTabIndex, true);
  }

  /// Build collapsed view with icon-only navigation
  Widget _buildCollapsedView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Tab icons (when multiple tabs exist)
        if (widget.tabs.length > 1) ...[
          ...widget.tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = index == _currentTabIndex;

            return Tooltip(
              message: tab.label,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    tab.icon,
                    size: 24,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[600],
                  ),
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _currentTabIndex = index;
                        });
                      }
                    });
                  },
                ),
              ),
            );
          }),
          // Divider between tabs and content
          Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.3),
          ),
        ],
        // Content list (icon-only when collapsed)
        Expanded(
          child: widget.tabBuilder(context, _currentTabIndex, false), // isExpanded = false
        ),
      ],
    );
  }

  /// Build sidebar header with collapse button
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: _isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        children: [
          // Title (only when expanded)
          if (!_isCollapsed)
            Expanded(
              child: Text(
                widget.tabs[_currentTabIndex].label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Collapse/Expand button
          IconButton(
            icon: Icon(_isCollapsed ? Icons.chevron_right : Icons.chevron_left),
            onPressed: _toggleCollapse,
            tooltip: _isCollapsed ? 'Erweitern' : 'Einklappen',
          ),
        ],
      ),
    );
  }

  /// Build tab switcher (only when expanded)
  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: widget.tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == _currentTabIndex;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Material(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {
                    // Schedule state update after current frame to avoid mouse tracking conflicts
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _currentTabIndex = index;
                        });
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tab.icon,
                          size: 18,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            tab.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Configuration for a sidebar tab
class SidebarTab {
  /// Tab label text
  final String label;

  /// Tab icon
  final IconData icon;

  const SidebarTab({
    required this.label,
    required this.icon,
  });
}
