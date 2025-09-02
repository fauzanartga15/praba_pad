import 'package:flutter/material.dart';
import 'dart:ui';

class ExpandableBottomNav extends StatefulWidget {
  final Function(String)? onMenuSelected;

  const ExpandableBottomNav({super.key, this.onMenuSelected});

  @override
  State<ExpandableBottomNav> createState() => _ExpandableBottomNavState();
}

class _ExpandableBottomNavState extends State<ExpandableBottomNav>
    with TickerProviderStateMixin {
  String activeMenu = 'dashboard';
  bool isMenuVisible = true;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  double _dragStartY = 0;
  double _currentDragY = 0;
  bool _isDragging = false;

  final double normalHeight = 90.0;
  final double indicatorHeight = 25.0; // Still needed for reference
  final double swipeThreshold = 50.0;

  // Simplified menu data - no sub-menus
  final Map<String, MenuData> menuData = {
    'dashboard': MenuData(title: 'Dashboard', icon: Icons.dashboard_outlined),
    'supplier': MenuData(title: 'Supplier', icon: Icons.people_outline),
    'buat': MenuData(
      title: 'Buat Pembelian',
      icon: Icons.add_shopping_cart_outlined,
    ),
    'lihat': MenuData(
      title: 'Lihat Pembelian',
      icon: Icons.receipt_long_outlined,
    ),
  };

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, 1), // Slide down
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeInOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _dragStartY = details.localPosition.dy;
    _isDragging = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    setState(() {
      _currentDragY = details.localPosition.dy - _dragStartY;
    });

    // Visual feedback - only allow swipe down when menu is visible
    if (isMenuVisible && _currentDragY > 0) {
      double progress = (_currentDragY / swipeThreshold).clamp(0.0, 1.0);
      _slideController.value = progress;
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;

    _isDragging = false;
    double velocity = details.velocity.pixelsPerSecond.dy;

    // Determine action based on swipe distance and velocity
    bool shouldHide = false;
    bool shouldShow = false;

    if (isMenuVisible) {
      // Currently visible - check if should hide
      shouldHide = _currentDragY > swipeThreshold || velocity > 300;
    } else {
      // Currently hidden - check if should show
      shouldShow = _currentDragY < -swipeThreshold || velocity < -300;
    }

    if (shouldHide) {
      _hideMenu();
    } else if (shouldShow) {
      _showMenu();
    } else {
      // Snap back to current state
      if (isMenuVisible) {
        _slideController.animateTo(0);
      } else {
        _slideController.animateTo(1);
      }
    }

    _currentDragY = 0;
  }

  void _hideMenu() {
    setState(() {
      isMenuVisible = false;
    });
    _slideController.forward();
  }

  void _showMenu() {
    setState(() {
      isMenuVisible = true;
    });
    _slideController.reverse();
  }

  void _selectMenuItem(String menuKey) {
    setState(() {
      activeMenu = menuKey;
    });
    if (widget.onMenuSelected != null) {
      widget.onMenuSelected!(menuKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 30,
      left: 20,
      right: 20,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                _slideAnimation.value.dy * (normalHeight - indicatorHeight),
              ),
              child: Container(
                height: isMenuVisible ? normalHeight : normalHeight,
                constraints: const BoxConstraints(maxWidth: 600),
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 600
                      ? (MediaQuery.of(context).size.width - 600) / 2
                      : 0,
                ),
                child: Stack(
                  children: [
                    // Main menu container
                    Container(
                      height: normalHeight,
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
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: menuData.entries.map((entry) {
                                  return _buildNavItem(
                                    entry.key,
                                    entry.value,
                                    isDarkMode,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Hidden state indicator
                    if (!isMenuVisible)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: indicatorHeight,
                          margin: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.3,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(String key, MenuData menu, bool isDarkMode) {
    final isActive = activeMenu == key;

    return Expanded(
      child: GestureDetector(
        onTap: () => _selectMenuItem(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
              Icon(
                menu.icon,
                color: isDarkMode ? Colors.white : Colors.black87,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                menu.title,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuData {
  final String title;
  final IconData icon;

  MenuData({required this.title, required this.icon});
}
