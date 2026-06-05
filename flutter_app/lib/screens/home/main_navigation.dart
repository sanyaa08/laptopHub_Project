import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/laptop_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../theme/app_theme.dart';
import '../wishlist/wishlist_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../laptops/laptop_list_screen.dart';
import 'home_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // ← declared here, NOT inside build()

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LaptopProvider>().loadLaptops();
      context.read<LaptopProvider>().loadFeatured();
      context.read<LaptopProvider>().loadBrands();
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final isAdmin = auth.isAdmin;

    final screens = [
      HomeScreen(scaffoldKey: _scaffoldKey),
      const WishlistScreen(),
      const CartScreen(),
      if (isAdmin) const AdminDashboardScreen(),
      const ProfileScreen(),
    ];

    final navItems = [
      const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(
        icon: badges.Badge(
          showBadge: wishlist.count > 0,
          badgeContent: Text('${wishlist.count}',
              style: const TextStyle(color: Colors.white, fontSize: 10)),
          badgeStyle: const badges.BadgeStyle(badgeColor: AppTheme.error),
          child: const Icon(Icons.favorite_border),
        ),
        activeIcon: badges.Badge(
          showBadge: wishlist.count > 0,
          badgeContent: Text('${wishlist.count}',
              style: const TextStyle(color: Colors.white, fontSize: 10)),
          badgeStyle: const badges.BadgeStyle(badgeColor: AppTheme.error),
          child: const Icon(Icons.favorite),
        ),
        label: 'Wishlist',
      ),
      BottomNavigationBarItem(
        icon: badges.Badge(
          showBadge: cart.itemCount > 0,
          badgeContent: Text('${cart.itemCount}',
              style: const TextStyle(color: Colors.white, fontSize: 10)),
          badgeStyle: const badges.BadgeStyle(badgeColor: AppTheme.accent),
          child: const Icon(Icons.shopping_cart_outlined),
        ),
        activeIcon: badges.Badge(
          showBadge: cart.itemCount > 0,
          badgeContent: Text('${cart.itemCount}',
              style: const TextStyle(color: Colors.white, fontSize: 10)),
          badgeStyle: const badges.BadgeStyle(badgeColor: AppTheme.accent),
          child: const Icon(Icons.shopping_cart),
        ),
        label: 'Cart',
      ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
    ];

    return Scaffold(
      key: _scaffoldKey, // ← key on the outer Scaffold
      drawer: _AppDrawer(
        isAdmin: isAdmin,
        currentIndex: _currentIndex,
        onNavigate: (index) {
          setState(() => _currentIndex = index);
          Navigator.pop(context);
        },
        onNavigateLaptops: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LaptopListScreen()),
          );
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.divider, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: navItems,
        ),
      ),
    );
  }
}

// ─── Drawer Widget ────────────────────────────────────────────────────────────
class _AppDrawer extends StatelessWidget {
  final bool isAdmin;
  final int currentIndex;
  final void Function(int) onNavigate;
  final VoidCallback onNavigateLaptops;

  const _AppDrawer({
    required this.isAdmin,
    required this.currentIndex,
    required this.onNavigate,
    required this.onNavigateLaptops,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Drawer(
      backgroundColor: AppTheme.secondary,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.laptop_mac, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text('Laptop Hub',
                      style: TextStyle(
                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    auth.user?.email ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Admin',
                          style: TextStyle(
                              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            _DrawerTile(
              icon: Icons.home_outlined,
              label: 'Home',
              selected: currentIndex == 0,
              onTap: () => onNavigate(0),
            ),
            _DrawerTile(
              icon: Icons.laptop_outlined,
              label: 'All Laptops',
              selected: false,
              onTap: onNavigateLaptops,
            ),
            _DrawerTile(
              icon: Icons.favorite_border,
              label: 'Wishlist',
              selected: currentIndex == 1,
              onTap: () => onNavigate(1),
            ),
            _DrawerTile(
              icon: Icons.shopping_cart_outlined,
              label: 'Cart',
              selected: currentIndex == 2,
              onTap: () => onNavigate(2),
            ),
            if (isAdmin)
              _DrawerTile(
                icon: Icons.admin_panel_settings_outlined,
                label: 'Admin Dashboard',
                selected: currentIndex == 3,
                onTap: () => onNavigate(3),
              ),
            _DrawerTile(
              icon: Icons.person_outline,
              label: 'Profile',
              selected: currentIndex == (isAdmin ? 4 : 3),
              onTap: () => onNavigate(isAdmin ? 4 : 3),
            ),

            const Spacer(),
            const Divider(color: AppTheme.divider),

            _DrawerTile(
              icon: Icons.logout,
              label: 'Logout',
              selected: false,
              iconColor: AppTheme.error,
              onTap: () {
                Navigator.pop(context);
                context.read<AuthProvider>().logout();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? iconColor;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? (selected ? AppTheme.accent : AppTheme.textSecondary);
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? AppTheme.accent : AppTheme.textPrimary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 15,
        ),
      ),
      tileColor: selected ? AppTheme.accent.withOpacity(0.08) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: onTap,
    );
  }
}