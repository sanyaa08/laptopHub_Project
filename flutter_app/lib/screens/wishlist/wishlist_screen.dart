import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';
import '../laptops/laptop_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: const Text('My Wishlist'),
        actions: [
          if (wishlist.count > 0)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: AppTheme.cardBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Clear Wishlist', style: TextStyle(color: AppTheme.textPrimary)),
                    content: const Text('Remove all items from your wishlist?',
                        style: TextStyle(color: AppTheme.textSecondary)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          wishlist.clear();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Clear All', style: TextStyle(color: AppTheme.error)),
            ),
        ],
      ),
      body: wishlist.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, color: AppTheme.textMuted, size: 80),
                  const SizedBox(height: 20),
                  const Text(
                    'Your wishlist is empty',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the ♥ on any laptop to save it here',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wishlist.items.length,
              itemBuilder: (context, index) {
                final laptop = wishlist.items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LaptopDetailScreen(laptop: laptop)),
                    ),
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
                                Text(laptop.brand,
                                    style: const TextStyle(
                                        color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(laptop.name,
                                    style: const TextStyle(
                                        color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                if (laptop.ram != null)
                                  Text('${laptop.ram} · ${laptop.storage ?? ""}',
                                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$${laptop.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                          color: AppTheme.accentGold, fontSize: 16, fontWeight: FontWeight.w800),
                                    ),
                                    Row(
                                      children: [
                                        // Add to Cart
                                        GestureDetector(
                                          onTap: () async {
                                            final msg = await cart.addToCart(laptop.id);
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(msg ?? '${laptop.name} added to cart!'),
                                              backgroundColor: msg == null ? AppTheme.success : AppTheme.error,
                                            ));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              color: AppTheme.success.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                                            ),
                                            child: const Icon(Icons.add_shopping_cart,
                                                color: AppTheme.success, size: 16),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Remove from Wishlist
                                        GestureDetector(
                                          onTap: () => wishlist.remove(laptop.id),
                                          child: Container(
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              color: AppTheme.error.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                                            ),
                                            child: const Icon(Icons.favorite, color: AppTheme.error, size: 16),
                                          ),
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
              },
            ),
    );
  }
}