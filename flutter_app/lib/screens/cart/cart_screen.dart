import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (cart.itemCount > 0)
            TextButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: AppTheme.cardBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Clear Cart', style: TextStyle(color: AppTheme.textPrimary)),
                    content: const Text('Remove all items?', style: TextStyle(color: AppTheme.textSecondary)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await context.read<CartProvider>().clearCart();
                }
              },
              icon: const Icon(Icons.delete_sweep, color: AppTheme.error),
              label: const Text('Clear', style: TextStyle(color: AppTheme.error)),
            ),
        ],
      ),
      body: cart.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : cart.cartItems.isEmpty
              ? _EmptyCart()
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => cart.loadCart(),
                        color: AppTheme.accent,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: cart.cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cart.cartItems[index];
                            return _CartTile(
                              key: ValueKey(item.id),
                              id: item.id,
                              name: item.name,
                              brand: item.brand,
                              price: item.price,
                              imageUrl: item.imageUrl,
                              quantity: item.quantity,
                              subtotal: item.subtotal,
                              onRemove: () => cart.removeItem(item.id),
                              onIncrease: () => cart.updateQuantity(item.id, item.quantity + 1),
                              onDecrease: () {
                                if (item.quantity > 1) {
                                  cart.updateQuantity(item.id, item.quantity - 1);
                                } else {
                                  cart.removeItem(item.id);
                                }
                              },
                            ).animate().fadeIn(delay: (60 * index).ms).slideY(begin: 0.1);
                          },
                        ),
                      ),
                    ),
                    _OrderSummary(total: cart.total, itemCount: cart.itemCount),
                  ],
                ),
    );
  }
}

class _CartTile extends StatelessWidget {
  final int id;
  final String name;
  final String brand;
  final double price;
  final String? imageUrl;
  final int quantity;
  final double subtotal;
  final VoidCallback onRemove;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _CartTile({
    super.key,
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.imageUrl,
    required this.quantity,
    required this.subtotal,
    required this.onRemove,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: imageUrl ?? '',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 80, height: 80,
                color: AppTheme.surfaceLight,
                child: const Icon(Icons.laptop, color: AppTheme.textMuted, size: 32),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(brand, style: const TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.accentGold, fontSize: 15, fontWeight: FontWeight.w800)),
                    Row(
                      children: [
                        _QtyBtn(icon: Icons.remove, onTap: onDecrease, color: AppTheme.error),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('$quantity', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                        _QtyBtn(icon: Icons.add, onTap: onIncrease, color: AppTheme.success),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, color: AppTheme.textMuted, size: 20),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _QtyBtn({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final double total;
  final int itemCount;
  const _OrderSummary({required this.total, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    final tax = total * 0.08;
    final grandTotal = total + tax;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.divider)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Items ($itemCount)', value: '\$${total.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _SummaryRow(label: 'Tax (8%)', value: '\$${tax.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          Divider(color: AppTheme.divider),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Total', value: '\$${grandTotal.toStringAsFixed(2)}', isTotal: true),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Checkout feature coming soon! 🚀'), backgroundColor: AppTheme.accent),
              );
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
            child: const Text('Proceed to Checkout'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  const _SummaryRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? AppTheme.textPrimary : AppTheme.textSecondary, fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400, fontSize: isTotal ? 16 : 14)),
        Text(value, style: TextStyle(color: isTotal ? AppTheme.accentGold : AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: isTotal ? 18 : 14)),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: AppTheme.surfaceLight, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_cart_outlined, color: AppTheme.textMuted, size: 48),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          const Text('Your cart is empty', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Add some laptops to get started!', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
