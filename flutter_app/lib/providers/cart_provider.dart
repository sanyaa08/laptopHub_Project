import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<CartItemModel> _cartItems = [];
  double _total = 0;
  bool _isLoading = false;

  List<CartItemModel> get cartItems => _cartItems;
  double get total => _total;
  bool get isLoading => _isLoading;
  int get itemCount => _cartItems.length;

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _api.getCart();
      _cartItems = result['cart'] as List<CartItemModel>;
      _total = double.tryParse(result['total'].toString()) ?? 0;
      notifyListeners();
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> addToCart(int laptopId) async {
    try {
      final result = await _api.addToCart(laptopId);
      if (result['success'] == true) {
        await loadCart();
        return null;
      }
      return result['message'];
    } catch (_) {
      return 'Network error.';
    }
  }

  Future<void> updateQuantity(int cartId, int quantity) async {
    try {
      await _api.updateCartItem(cartId, quantity);
      await loadCart();
    } catch (_) {}
  }

  Future<void> removeItem(int cartId) async {
    try {
      await _api.removeFromCart(cartId);
      _cartItems.removeWhere((c) => c.id == cartId);
      notifyListeners();
      await loadCart();
    } catch (_) {}
  }

  Future<void> clearCart() async {
    try {
      await _api.clearCart();
      _cartItems = [];
      _total = 0;
      notifyListeners();
    } catch (_) {}
  }

  void reset() {
    _cartItems = [];
    _total = 0;
    notifyListeners();
  }
}
