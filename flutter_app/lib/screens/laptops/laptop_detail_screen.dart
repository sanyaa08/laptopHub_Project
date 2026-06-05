import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/laptop_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../theme/app_theme.dart';
import 'laptop_form_screen.dart';

class LaptopDetailScreen extends StatelessWidget {
  final LaptopModel laptop;

  const LaptopDetailScreen({super.key, required this.laptop});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: CustomScrollView(
        slivers: [
          // Hero Image App Bar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.primary,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 18),
              ),
            ),
           actions: [
  // ── Wishlist heart ──
  Consumer<WishlistProvider>(
    builder: (context, wishlist, _) {
      final isWishlisted = wishlist.isWishlisted(laptop.id);
      return GestureDetector(
        onTap: () {
          wishlist.toggle(laptop);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isWishlisted
                ? 'Removed from wishlist'
                : '${laptop.name} added to wishlist ♥'),
            backgroundColor: isWishlisted ? AppTheme.textMuted : AppTheme.error,
          ));
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.cardBg.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isWishlisted ? Icons.favorite : Icons.favorite_border,
            color: isWishlisted ? AppTheme.error : AppTheme.textPrimary,
            size: 20,
          ),
        ),
      );
    },
  ),
  if (auth.isAdmin)
    GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LaptopFormScreen(laptop: laptop)),
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.edit_outlined, color: AppTheme.accent, size: 16),
            SizedBox(width: 4),
            Text('Edit', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ),
],
          
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: laptop.imageUrl ?? '',
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: AppTheme.surfaceLight,
                  child: const Icon(Icons.laptop, color: AppTheme.textMuted, size: 80),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand + Featured
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          laptop.brand,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (laptop.isFeatured) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.accentGold.withOpacity(0.4)),
                          ),
                          child: const Text(
                            '★ Featured',
                            style: TextStyle(color: AppTheme.accentGold, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: laptop.inStock ? AppTheme.success.withOpacity(0.15) : AppTheme.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          laptop.inStock ? 'In Stock (${laptop.stock})' : 'Out of Stock',
                          style: TextStyle(
                            color: laptop.inStock ? AppTheme.success : AppTheme.error,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(),
                  const SizedBox(height: 12),

                  // Name
                  Text(
                    laptop.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 12),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${laptop.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.accentGold,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 150.ms),
                  const SizedBox(height: 20),

                  // Specs Grid
                  _SpecsGrid(laptop: laptop).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 20),

                  // Description
                  if (laptop.description != null) ...[
                    Text(
                      'About this laptop',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 8),
                    Text(
                      laptop.description!,
                      style: const TextStyle(color: AppTheme.textSecondary, height: 1.6),
                    ).animate().fadeIn(delay: 350.ms),
                    const SizedBox(height: 100),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: ElevatedButton.icon(
          onPressed: laptop.inStock
              ? () async {
                  final msg = await cart.addToCart(laptop.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg ?? 'Added to cart! 🛒'),
                      backgroundColor: msg == null ? AppTheme.success : AppTheme.error,
                    ),
                  );
                }
              : null,
          icon: const Icon(Icons.shopping_cart_outlined),
          label: Text(laptop.inStock ? 'Add to Cart' : 'Out of Stock'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            backgroundColor: laptop.inStock ? AppTheme.accent : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}

class _SpecsGrid extends StatelessWidget {
  final LaptopModel laptop;
  const _SpecsGrid({required this.laptop});

  @override
  Widget build(BuildContext context) {
    final specs = <Map<String, String?>>[];
    if (laptop.processor != null) specs.add({'icon': '⚡', 'label': 'Processor', 'value': laptop.processor});
    if (laptop.ram != null) specs.add({'icon': '💾', 'label': 'Memory', 'value': laptop.ram});
    if (laptop.storage != null) specs.add({'icon': '💿', 'label': 'Storage', 'value': laptop.storage});
    if (laptop.display != null) specs.add({'icon': '🖥️', 'label': 'Display', 'value': laptop.display});
    if (laptop.graphics != null) specs.add({'icon': '🎮', 'label': 'Graphics', 'value': laptop.graphics});
    if (laptop.battery != null) specs.add({'icon': '🔋', 'label': 'Battery', 'value': laptop.battery});
    if (laptop.os != null) specs.add({'icon': '💻', 'label': 'OS', 'value': laptop.os});
    if (laptop.weight != null) specs.add({'icon': '⚖️', 'label': 'Weight', 'value': laptop.weight});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specifications',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            children: List.generate(specs.length, (index) {
              final spec = specs[index];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Text(spec['icon'] ?? '', style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                spec['label'] ?? '',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                spec['value'] ?? '',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < specs.length - 1) Divider(color: AppTheme.divider, height: 1),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
