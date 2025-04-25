// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lostandfound/config/api_endpoint.dart';
import 'package:lostandfound/model/item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserItemsProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
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
    print('Checking SharedPreferences: user_id = $_userId');
    if (_userId == null) {
      print('No user_id found in SharedPreferences');
    } else {
      print('User ID successfully retrieved: $_userId');
    }
    return _userId != null;
  }

  Future<void> getItemsByUserId() async {
    print('Starting getItemsByUserId');

    // Always fetch the latest userId from SharedPreferences
    final isLoggedIn = await isUserLoggedIn();
    if (!isLoggedIn) {
      _error = 'User not logged in. Please log in to view your items.';
      _isLoading = false;
      notifyListeners();
      print('User not logged in, aborting fetch');
      return;
    }

    _isLoading = true;
    _error = null;
    _items = [];
    print('Fetching items for user_id: $_userId');
    notifyListeners();

    try {
      final url = _authApi.userItemsEndpoint(_userId!);
      print('API Request URL: $url');
      Response response = await _dio.get(url);
      print('API Response Status: ${response.statusCode}');
      print('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        dynamic data = response.data;
        if (data is List) {
          if (data.isEmpty) {
            print('Response is an empty list');
            _items = [];
          } else {
            _items = data.map((item) {
              print('Parsing item: $item');
              return Item.fromJson(item);
            }).toList();
            print('Parsed items as List: ${_items.length} items found');
          }
        } else if (data is Map<String, dynamic>) {
          if (data.containsKey('items')) {
            final itemsList = data['items'] as List;
            if (itemsList.isEmpty) {
              print('Response has an empty items list');
              _items = [];
            } else {
              _items = itemsList.map((item) {
                print('Parsing item from map: $item');
                return Item.fromJson(item);
              }).toList();
              print('Parsed items from Map: ${_items.length} items found');
            }
          } else {
            _error = 'Unexpected response format: no "items" key found';
            print('Unexpected Map format: $data');
            _items = [];
          }
        } else {
          _error = 'Unexpected response type: ${data.runtimeType}';
          print('Unexpected response data: $data');
          _items = [];
        }
      } else {
        _error = 'Unexpected status code: ${response.statusCode}';
        print('Non-200 response: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _error = e.response?.data['error'] ??
          'Failed to fetch items: ${e.message} (Check network or server)';
      print('DioException occurred: $_error');
      print('Response data (if any): ${e.response?.data}');
      _items = [];
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
      print('Unexpected error: $_error');
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
      print('Fetch completed. Items count: ${_items.length}, Error: $_error');
    }
  }

  Future<void> setTestUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
    _userId = userId;
    print('Test user_id set to: $userId');
    notifyListeners();
  }
}
