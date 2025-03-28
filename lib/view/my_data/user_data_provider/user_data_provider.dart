import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lostandfound/config/api_endpoint.dart';
import 'package:lostandfound/model/item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserItemsProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));
  final AuthApi _authApi = AuthApi();

  bool _isLoading = false;
  String? _error;
  List<Item> _items = [];
  int? _userId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Item> get items => _items;
  String get baseUrl => _authApi.baseUrl;

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id');
    return _userId != null;
  }

  Future<void> getItemsByUserId() async {
    if (_userId == null) {
      final isLoggedIn = await isUserLoggedIn();
      if (!isLoggedIn) {
        _error = 'User not logged in';
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    _isLoading = true;
    _error = null;
    _items = [];
    notifyListeners();

    try {
      Response response = await _dio.get(_authApi.userItemsEndpoint(_userId!));
      if (response.statusCode == 200) {
        // Handle different response structures
        dynamic data = response.data;
        if (data is List) {
          // If data is a direct list
          _items = data.map((item) => Item.fromJson(item)).toList();
        } else if (data is Map<String, dynamic> && data.containsKey('items')) {
          // If data is an object with an 'items' key
          _items = (data['items'] as List)
              .map((item) => Item.fromJson(item))
              .toList();
        } else {
          // If no items are available or unexpected format, treat as empty
          _items = [];
        }
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Failed to fetch user items';
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
