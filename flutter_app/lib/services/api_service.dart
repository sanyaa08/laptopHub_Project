import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';
import '../models/laptop_model.dart';
import '../models/cart_item_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  // ─── Token Management ─────────────────────────────────
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ─── AUTH ─────────────────────────────────────────────
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/signup'),
      headers: _headers,
      body: jsonEncode({'name': name, 'email': email, 'password': password, 'role': role}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  Future<UserModel?> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/auth/profile'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return UserModel.fromJson(data['user']);
      }
    } catch (_) {}
    return null;
  }

  // ─── USERS (Admin CRUD) ───────────────────────────────
  Future<List<UserModel>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/auth/users'),
      headers: _headers,
    );
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      return (data['users'] as List).map((u) => UserModel.fromJson(u)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/auth/users/$id'),
      headers: _headers,
      body: jsonEncode(userData),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/auth/users/$id'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  // ─── LAPTOPS ──────────────────────────────────────────
  Future<Map<String, dynamic>> getLaptops({
    String? search,
    String? brand,
    double? minPrice,
    double? maxPrice,
    bool? featured,
  }) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (brand != null && brand.isNotEmpty) params['brand'] = brand;
    if (minPrice != null) params['min_price'] = minPrice.toString();
    if (maxPrice != null) params['max_price'] = maxPrice.toString();
    if (featured == true) params['featured'] = 'true';

    final uri = Uri.parse('${AppConstants.baseUrl}/laptops').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers);
    final data = jsonDecode(response.body);

    if (data['success'] == true) {
      return {
        'laptops': (data['laptops'] as List).map((l) => LaptopModel.fromJson(l)).toList(),
        'total': data['total'],
      };
    }
    return {'laptops': <LaptopModel>[], 'total': 0};
  }

  Future<LaptopModel?> getLaptopById(int id) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/laptops/$id'),
      headers: _headers,
    );
    final data = jsonDecode(response.body);
    if (data['success'] == true) return LaptopModel.fromJson(data['laptop']);
    return null;
  }

  Future<Map<String, dynamic>> createLaptop(Map<String, dynamic> laptopData) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/laptops'),
      headers: _headers,
      body: jsonEncode(laptopData),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateLaptop(int id, Map<String, dynamic> laptopData) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/laptops/$id'),
      headers: _headers,
      body: jsonEncode(laptopData),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteLaptop(int id) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/laptops/$id'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  Future<List<String>> getBrands() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/laptops/brands'),
      headers: _headers,
    );
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      return List<String>.from(data['brands']);
    }
    return [];
  }

  // ─── CART ─────────────────────────────────────────────
  Future<Map<String, dynamic>> getCart() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/cart'),
      headers: _headers,
    );
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      return {
        'cart': (data['cart'] as List).map((c) => CartItemModel.fromJson(c)).toList(),
        'total': data['total'],
        'item_count': data['item_count'],
      };
    }
    return {'cart': <CartItemModel>[], 'total': '0', 'item_count': 0};
  }

  Future<Map<String, dynamic>> addToCart(int laptopId, {int quantity = 1}) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/cart'),
      headers: _headers,
      body: jsonEncode({'laptop_id': laptopId, 'quantity': quantity}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateCartItem(int cartId, int quantity) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/cart/$cartId'),
      headers: _headers,
      body: jsonEncode({'quantity': quantity}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> removeFromCart(int cartId) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/cart/$cartId'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> clearCart() async {
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/cart/clear'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }
}
