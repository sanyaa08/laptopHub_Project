import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final userJson = prefs.getString(AppConstants.userKey);

    if (token != null && userJson != null) {
      await _api.loadToken();
      try {
        _user = UserModel.fromJson(jsonDecode(userJson));
        notifyListeners();
        // Refresh from server
        final fresh = await _api.getProfile();
        if (fresh != null) {
          _user = fresh;
          await _saveUser(fresh);
          notifyListeners();
        }
      } catch (_) {}
    }
  }

  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    _setLoading(true);
    try {
      final result = await _api.signup(name: name, email: email, password: password, role: role);
      if (result['success'] == true) {
        await _api.saveToken(result['token']);
        _user = UserModel.fromJson(result['user']);
        await _saveUser(_user!);
        notifyListeners();
        return null;
      }
      return result['message'] ?? 'Signup failed.';
    } catch (e) {
      return 'Network error. Check your connection.';
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      final result = await _api.login(email: email, password: password);
      if (result['success'] == true) {
        await _api.saveToken(result['token']);
        _user = UserModel.fromJson(result['user']);
        await _saveUser(_user!);
        notifyListeners();
        return null;
      }
      return result['message'] ?? 'Login failed.';
    } catch (e) {
      return 'Network error. Check your connection.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    _user = null;
    notifyListeners();
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
