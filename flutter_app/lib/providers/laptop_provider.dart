import 'package:flutter/foundation.dart';
import '../models/laptop_model.dart';
import '../services/api_service.dart';

class LaptopProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<LaptopModel> _laptops = [];
  List<LaptopModel> _featuredLaptops = [];
  List<String> _brands = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedBrand;

  List<LaptopModel> get laptops => _laptops;
  List<LaptopModel> get featuredLaptops => _featuredLaptops;
  List<String> get brands => _brands;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedBrand => _selectedBrand;

  Future<void> loadLaptops({String? search, String? brand}) async {
    _setLoading(true);
    _error = null;
    try {
      final result = await _api.getLaptops(search: search, brand: brand);
      _laptops = result['laptops'] as List<LaptopModel>;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load laptops. Check your connection.';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadFeatured() async {
    try {
      final result = await _api.getLaptops(featured: true);
      _featuredLaptops = result['laptops'] as List<LaptopModel>;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadBrands() async {
    try {
      _brands = await _api.getBrands();
      notifyListeners();
    } catch (_) {}
  }

  void setSearch(String query) {
    _searchQuery = query;
    loadLaptops(search: query.isEmpty ? null : query, brand: _selectedBrand);
  }

  void setBrand(String? brand) {
    _selectedBrand = brand;
    loadLaptops(search: _searchQuery.isEmpty ? null : _searchQuery, brand: brand);
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedBrand = null;
    loadLaptops();
  }

  Future<String?> createLaptop(Map<String, dynamic> data) async {
    try {
      final result = await _api.createLaptop(data);
      if (result['success'] == true) {
        await loadLaptops();
        return null;
      }
      return result['message'] ?? 'Failed to create laptop.';
    } catch (_) {
      return 'Network error.';
    }
  }

  Future<String?> updateLaptop(int id, Map<String, dynamic> data) async {
    try {
      final result = await _api.updateLaptop(id, data);
      if (result['success'] == true) {
        await loadLaptops();
        return null;
      }
      return result['message'] ?? 'Failed to update laptop.';
    } catch (_) {
      return 'Network error.';
    }
  }

  Future<String?> deleteLaptop(int id) async {
    try {
      final result = await _api.deleteLaptop(id);
      if (result['success'] == true) {
        _laptops.removeWhere((l) => l.id == id);
        notifyListeners();
        return null;
      }
      return result['message'] ?? 'Failed to delete laptop.';
    } catch (_) {
      return 'Network error.';
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
