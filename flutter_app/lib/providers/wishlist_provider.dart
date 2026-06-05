import 'package:flutter/foundation.dart';
import '../models/laptop_model.dart';

class WishlistProvider extends ChangeNotifier {
  final List<LaptopModel> _items = [];

  List<LaptopModel> get items => List.unmodifiable(_items);
  int get count => _items.length;

  bool isWishlisted(int laptopId) => _items.any((l) => l.id == laptopId);

  void toggle(LaptopModel laptop) {
    if (isWishlisted(laptop.id)) {
      _items.removeWhere((l) => l.id == laptop.id);
    } else {
      _items.add(laptop);
    }
    notifyListeners();
  }

  void remove(int laptopId) {
    _items.removeWhere((l) => l.id == laptopId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}