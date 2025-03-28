import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lostandfound/model/police_model.dart';
import 'package:lostandfound/config/api_endpoint.dart';

class PoliceProvider with ChangeNotifier {
  List<Police> _policeList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Police> get policeList => _policeList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPoliceData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var dio = Dio();
      // Consider adding these configurations
      dio.options = BaseOptions(
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 3),
      );

      var response = await dio.get(
        // Using .get() is more specific than .request()
        AuthApi().policeItemsEndpoint,
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        _policeList = data.map((item) => Police.fromJson(item)).toList();
      } else {
        _errorMessage = response.statusMessage ?? 'Unknown error occurred';
      }
    } on DioException catch (e) {
      // More specific exception handling
      _errorMessage = e.response?.statusMessage ?? 'Network error: $e';
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
