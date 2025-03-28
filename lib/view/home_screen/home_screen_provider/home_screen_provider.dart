// category_provider.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:lostandfound/config/api_endpoint.dart';
import 'package:lostandfound/model/chategory_model.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;
  Category? _selectedCategory; // Moved from HomeScreen
  bool _showSubcategories = false; // Moved from HomeScreen

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Category? get selectedCategory => _selectedCategory;
  bool get showSubcategories => _showSubcategories;

  final AuthApi _authApi = AuthApi();

  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    var headers = {'Content-Type': 'application/json'};
    var dio = Dio();
    try {
      var response = await dio.request(
        _authApi.categoriesEndpoint,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        _categories = data.map((item) => Category.fromJson(item)).toList();
        _isLoading = false;
        notifyListeners();
      } else {
        _isLoading = false;
        _error = 'Failed to load categories: ${response.statusMessage}';
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching categories: $e';
      notifyListeners();
    }
  }
}