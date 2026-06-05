import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/laptop_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/laptop_model.dart';
import 'laptop_detail_screen.dart';
import 'laptop_form_screen.dart';

class LaptopListScreen extends StatefulWidget {
  const LaptopListScreen({super.key});

  @override
  State<LaptopListScreen> createState() => _LaptopListScreenState();
}

class _LaptopListScreenState extends State<LaptopListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final laptops = context.watch<LaptopProvider>();
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: const Text('Laptops'),
        actions: [
          if (auth.isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LaptopFormScreen()),
                  );
                  if (context.mounted) context.read<LaptopProvider>().loadLaptops();
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search + Filter Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                // Search
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => laptops.setSearch(v),
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search laptops...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                            onPressed: () {
                              _searchCtrl.clear();
                              laptops.setSearch('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Brand Filter Chips
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: laptops.brands.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('All'),
                            selected: laptops.selectedBrand == null,
                            onSelected: (_) => laptops.setBrand(null),
                            selectedColor: AppTheme.accent.withOpacity(0.3),
                            checkmarkColor: AppTheme.accent,
                            labelStyle: TextStyle(
                              color: laptops.selectedBrand == null ? AppTheme.accent : AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }
                      final brand = laptops.brands[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(brand),
                          selected: laptops.selectedBrand == brand,
                          onSelected: (_) => laptops.setBrand(
                            laptops.selectedBrand == brand ? null : brand,
                          ),
                          selectedColor: AppTheme.accent.withOpacity(0.3),
                          checkmarkColor: AppTheme.accent,
                          labelStyle: TextStyle(
                            color: laptops.selectedBrand == brand ? AppTheme.accent : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 4),

                // Results count
                Row(
                  children: [
                    Text(
                      '${laptops.laptops.length} results',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: laptops.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                : laptops.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off, color: AppTheme.textMuted, size: 48),
                            const SizedBox(height: 16),
                            Text(laptops.error!, style: const TextStyle(color: AppTheme.textSecondary)),
                            const SizedBox(height: 16),
                            ElevatedButton(onPressed: () => laptops.loadLaptops(), child: const Text('Retry')),
                          ],
                        ),
                      )
                    : laptops.laptops.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.laptop_chromebook, color: AppTheme.textMuted, size: 64),
                                const SizedBox(height: 16),
                                const Text('No laptops found', style: TextStyle(color: AppTheme.textSecondary, fontSize: 18)),
                                if (laptops.selectedBrand != null || laptops.searchQuery.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: laptops.clearFilters,
                                    child: const Text('Clear Filters'),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => laptops.loadLaptops(),
                            color: AppTheme.accent,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: laptops.laptops.length,
                              itemBuilder: (context, index) {
                                final laptop = laptops.laptops[index];
                               return _LaptopListTile(
  laptop: laptop,
  isAdmin: auth.isAdmin,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => LaptopDetailScreen(laptop: laptop)),
  ),
  onAddToCart: () async {
    final msg = await cart.addToCart(laptop.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg ?? 'Added to cart!'),
        backgroundColor: msg == null ? AppTheme.success : AppTheme.error,
      ),
    );
  },
  onEdit: auth.isAdmin ? () async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LaptopFormScreen(laptop: laptop)),
    );
    if (context.mounted) context.read<LaptopProvider>().loadLaptops();
  } : null,
  onDelete: auth.isAdmin ? () async {
    final confirm = await _showDeleteDialog(context, laptop.name);
    if (confirm == true) {
      final err = await context.read<LaptopProvider>().deleteLaptop(laptop.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Laptop deleted!'),
          backgroundColor: err == null ? AppTheme.success : AppTheme.error,
        ),
      );
    }
  } : null,
  // ── ADD THESE TWO ──
  isWishlisted: context.read<WishlistProvider>().isWishlisted(laptop.id),
  onWishlistToggle: () => context.read<WishlistProvider>().toggle(laptop),
).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Laptop', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Are you sure you want to delete "$name"?', style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _LaptopListTile extends StatelessWidget {
  final LaptopModel laptop;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
   final VoidCallback onWishlistToggle;   // ← ADD
  final bool isWishlisted;     

  const _LaptopListTile({
    required this.laptop,
    required this.isAdmin,
    required this.onTap,
    required this.onAddToCart,
    this.onEdit,
    this.onDelete,
      required this.onWishlistToggle,      // ← ADD
    required this.isWishlisted, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: laptop.imageUrl ?? '',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 90,
                    height: 90,
                    color: AppTheme.surfaceLight,
                    child: const Icon(Icons.laptop, color: AppTheme.textMuted, size: 36),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          laptop.brand,
                          style: const TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                        if (laptop.isFeatured) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '★ Featured',
                              style: TextStyle(color: AppTheme.accentGold, fontSize: 9, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      laptop.name,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (laptop.ram != null)
                      Text(
                        '${laptop.ram} · ${laptop.storage ?? ""}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${laptop.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                       Row(
  children: [
    if (isAdmin) ...[
      _ActionButton(
        icon: Icons.edit_outlined,
        color: AppTheme.accent,
        onTap: onEdit!,
      ),
      const SizedBox(width: 6),
      _ActionButton(
        icon: Icons.delete_outlined,
        color: AppTheme.error,
        onTap: onDelete!,
      ),
      const SizedBox(width: 6),
    ],
    // ── Wishlist heart ──
    _ActionButton(
      icon: isWishlisted ? Icons.favorite : Icons.favorite_border,
      color: AppTheme.error,
      onTap: onWishlistToggle,
    ),
    const SizedBox(width: 6),
    _ActionButton(
      icon: Icons.add_shopping_cart,
      color: AppTheme.success,
      onTap: onAddToCart,
    ),
  ],
),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
