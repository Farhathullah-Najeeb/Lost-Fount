import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lostandfound/config/api_endpoint.dart';

class DeleteItemProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));
  final AuthApi _authApi = AuthApi();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> deleteItem(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Response response = await _dio.delete('${_authApi.itemsEndpoint}/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true; // Success, no list refresh here
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['error'] ?? 'Failed to delete item';
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}