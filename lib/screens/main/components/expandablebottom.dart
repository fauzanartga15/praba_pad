import 'package:flutter/material.dart';
import 'dart:ui';

class ExpandableBottomNav extends StatefulWidget {
  final Function(String)? onMenuSelected;
  final Function(String)? onSubMenuSelected;

  const ExpandableBottomNav({
    super.key,
    this.onMenuSelected,
    this.onSubMenuSelected,
  });

  @override
  State<ExpandableBottomNav> createState() => _ExpandableBottomNavState();
}

class _ExpandableBottomNavState extends State<ExpandableBottomNav>
    with TickerProviderStateMixin {
  String? expandedMenu;
  String activeMenu = 'dashboard';
  late AnimationController _heightController;
  late AnimationController _fadeController;
  late Animation<double> _heightAnimation;
  late Animation<double> _fadeAnimation;

  final double collapsedHeight = 85.0;
  final double expandedHeight = 285.0;

  final Map<String, MenuData> menuData = {
    'supplier': MenuData(
      title: 'Supplier',
      icon: Icons.people_outline,
      subMenus: [
        SubMenuItem(
          icon: Icons.add_circle_outline,
          title: 'Data Supplier',
          subtitle: 'Kelola data supplier',
        ),
        SubMenuItem(
          icon: Icons.edit_outlined,
          title: 'Kelola Data Supplier',
          subtitle: 'Edit informasi supplier',
        ),
        SubMenuItem(
          icon: Icons.analytics_outlined,
          title: 'Laporan Supplier',
          subtitle: 'Analisis performa supplier',
        ),
      ],
    ),
    'buat': MenuData(
      title: 'Buat Pembelian',
      icon: Icons.add_shopping_cart_outlined,
      subMenus: [
        SubMenuItem(
          icon: Icons.note_add_outlined,
          title: 'Order Baru',
          subtitle: 'Buat pembelian baru',
        ),
        SubMenuItem(
          icon: Icons.store_mall_directory_outlined,
          title: 'Template Order',
          subtitle: 'Gunakan template tersimpan',
        ),
        SubMenuItem(
          icon: Icons.drafts_outlined,
          title: 'Draft Tersimpan',
          subtitle: 'Lanjutkan draft order',
        ),
      ],
    ),
    'lihat': MenuData(
      title: 'Lihat Pembelian',
      icon: Icons.receipt_long_outlined,
      subMenus: [
        SubMenuItem(
          icon: Icons.list_alt_outlined,
          title: 'Semua Order',
          subtitle: 'Lihat seluruh pembelian',
        ),
        SubMenuItem(
          icon: Icons.pending_outlined,
          title: 'Order Pending',
          subtitle: 'Menunggu konfirmasi',
        ),
        SubMenuItem(
          icon: Icons.check_circle_outline,
          title: 'Order Selesai',
          subtitle: 'Pembelian completed',
        ),
      ],
    ),
    'dashboard': MenuData(
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      subMenus: [],
    ),
  };

  @override
  void initState() {
    super.initState();
    _heightController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightAnimation =
        Tween<double>(begin: collapsedHeight, end: expandedHeight).animate(
          CurvedAnimation(
            parent: _heightController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleExpand(String menuKey) {
    setState(() {
      if (expandedMenu == menuKey) {
        // Collapse
        expandedMenu = null;
        _heightController.reverse();
        _fadeController.reverse();
      } else {
        // Expand
        expandedMenu = menuKey;
        activeMenu = menuKey;
        _heightController.forward();
        _fadeController.forward();
      }
    });

    if (widget.onMenuSelected != null) {
      widget.onMenuSelected!(menuKey);
    }
  }

  void _selectSubMenu(String subMenuTitle) {
    if (widget.onSubMenuSelected != null) {
      widget.onSubMenuSelected!(subMenuTitle);
    }
    // Auto collapse after selection
    _toggleExpand(expandedMenu!);
  }

  @override
  Widget build(BuildContext context) {
    // Get theme info for dynamic styling
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      bottom:
          MediaQuery.of(context).padding.bottom +
          20, // Fix overflow with safe area
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _heightAnimation,
        builder: (context, child) {
          return Container(
            height: expandedMenu != null ? 285.0 : 90.0,
            constraints: const BoxConstraints(maxWidth: 600),
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 600
                  ? (MediaQuery.of(context).size.width - 600) / 2
                  : 0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.15),
                  blurRadius: isDarkMode ? 20 : 25,
                  spreadRadius: isDarkMode ? 0 : 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    // Dynamic background based on theme
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.8),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Fix overflow
                    children: [
                      // Main Navigation Bar
                      SizedBox(
                        height: 85,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: menuData.entries.map((entry) {
                              return _buildNavItem(entry.key, entry.value);
                            }).toList(),
                          ),
                        ),
                      ),
                      // Expanded Content
                      if (expandedMenu != null)
                        Flexible(
                          // Changed from Expanded to Flexible
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildExpandedContent(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(String key, MenuData menu) {
    final isActive = activeMenu == key;
    final isExpanded = expandedMenu == key;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => menu.subMenus.isNotEmpty
            ? _toggleExpand(key)
            : _selectMenuItem(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(
                    0xFF2697FF,
                  ).withValues(alpha: isDarkMode ? 0.2 : 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(
                        0xFF2697FF,
                      ).withValues(alpha: isDarkMode ? 0.3 : 0.4),
                      blurRadius: isDarkMode ? 8 : 12,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  menu.icon,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                menu.title,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (menu.subMenus.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  child: AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    if (expandedMenu == null) return const SizedBox.shrink();

    final menu = menuData[expandedMenu]!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height:
          expandedHeight - collapsedHeight, // Fixed height for expanded content
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(
                    menu.icon,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    menu.title,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Sub Menu Items - Fixed height container
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                itemCount: menu.subMenus.length,
                itemBuilder: (context, index) {
                  final subMenu = menu.subMenus[index];
                  return _buildSubMenuItem(subMenu, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubMenuItem(SubMenuItem subMenu, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200 + (index * 50)),
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectSubMenu(subMenu.title),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF2697FF,
                    ).withValues(alpha: isDarkMode ? 0.2 : 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    subMenu.icon,
                    color: isDarkMode ? Colors.white : const Color(0xFF2697FF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subMenu.title,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subMenu.subtitle != null)
                        Text(
                          subMenu.subtitle!,
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.7)
                                : Colors.black.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.4),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectMenuItem(String menuKey) {
    setState(() {
      activeMenu = menuKey;
    });
    if (widget.onMenuSelected != null) {
      widget.onMenuSelected!(menuKey);
    }
  }
}

class MenuData {
  final String title;
  final IconData icon;
  final List<SubMenuItem> subMenus;

  MenuData({required this.title, required this.icon, required this.subMenus});
}

class SubMenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;

  SubMenuItem({required this.icon, required this.title, this.subtitle});
}
