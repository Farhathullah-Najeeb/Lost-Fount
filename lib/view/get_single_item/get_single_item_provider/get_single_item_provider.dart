import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lostandfound/config/api_endpoint.dart';
import 'package:lostandfound/model/item_model.dart';

class SingleItemProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));
  final AuthApi _authApi = AuthApi();

  bool _isLoading = false;
  String? _error;
  Item? _item;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Item? get item => _item;
  String get baseUrl => _authApi.baseUrl;

  Future<void> getSingleItem(int id) async {
    _isLoading = true;
    _error = null;
    _item = null;
    notifyListeners();

    try {
      Response response = await _dio.get('${_authApi.itemsEndpoint}/$id');
      if (response.statusCode == 200) {
        _item = Item.fromJson(response.data);
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Failed to fetch item';
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _item = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}