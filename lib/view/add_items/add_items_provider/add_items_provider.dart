import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lostandfound/config/api_endpoint.dart';
import 'package:lostandfound/model/item_model.dart';
import 'dart:io';

class ItemProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));
  final AuthApi _authApi = AuthApi();

  bool _isLoading = false;
  String? _error;
  List<Item> _items = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Item> get items => _items;
  String get baseUrl => _authApi.baseUrl;

  Future<void> getAllItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Response response = await _dio.get(_authApi.itemsEndpoint);
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        _items = data.map((item) => Item.fromJson(item)).toList();
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Failed to fetch items';
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createItem({
    required int userId,
    required String itemName,
    required int categoryId,
    required String type,
    String? description,
    String? location,
    String? geotag,
    File? image,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Log the input data for debugging
      print('Creating item with data:');
      print('  user_id: $userId');
      print('  item_name: $itemName');
      print('  category_id: $categoryId');
      print('  type: $type');
      print('  description: $description');
      print('  location: $location');
      print('  geotag: $geotag');
      print('  image: ${image?.path ?? "null"}');

      // Construct FormData
      FormData formData = FormData.fromMap({
        'user_id': userId,
        'item_name': itemName,
        'category_id': categoryId,
        'type': type,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (location != null && location.isNotEmpty) 'location': location,
        if (geotag != null && geotag.isNotEmpty) 'geotag': geotag,
        if (image != null)
          'image': await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
      });

      // Send POST request
      Response response = await _dio.post(
        _authApi.itemsEndpoint, // Ensure this is correct (e.g., '/api/items')
        data: formData,
        options: Options(
          validateStatus: (status) =>
              status != null && status < 500, // Handle 4xx errors gracefully
        ),
      );

      // Log the response for debugging
      print(
          'API Response: Status ${response.statusCode}, Data: ${response.data}');

      if (response.statusCode == 201) {
        await getAllItems(); // Refresh the list
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception(
          'Failed to create item. Status code: ${response.statusCode}, Response: ${response.data}',
        );
      }
    } on DioException catch (e) {
      // Improved error handling with detailed server response
      final responseData = e.response?.data;
      _error = responseData != null
          ? 'Server error: ${responseData['error'] ?? responseData.toString()}'
          : 'Network error: ${e.message}';
      print('DioException: $_error');
      return false;
    } catch (e) {
      _error = 'Unexpected error: $e';
      print('Unexpected error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateItem({
    required int id,
    required int userId,
    required String itemName,
    required int categoryId,
    required String type,
    String? description,
    String? location,
    String? geotag,
    File? image,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      FormData formData = FormData.fromMap({
        'user_id': userId,
        'item_name': itemName,
        'category_id': categoryId,
        'type': type,
        if (description != null) 'description': description,
        if (location != null) 'location': location,
        if (geotag != null) 'geotag': geotag,
        if (image != null)
          'image': await MultipartFile.fromFile(image.path,
              filename: image.path.split('/').last),
      });

      Response response = await _dio.put(
        '${_authApi.itemsEndpoint}/$id',
        data: formData,
      );

      if (response.statusCode == 200) {
        await getAllItems(); // Refresh the list
        return true;
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Failed to update item';
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
