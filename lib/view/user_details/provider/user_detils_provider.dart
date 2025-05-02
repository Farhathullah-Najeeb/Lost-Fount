import 'package:flutter/material.dart';
import 'package:lostandfound/config/api_endpoint.dart';
import 'package:lostandfound/model/profile_view_model.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  final AuthApi _authApi;
  final Dio _dio;

  UserProvider({AuthApi? authApi, Dio? dio})
      : _authApi = authApi ?? AuthApi(),
        _dio = dio ?? Dio() {
    _configureDio();
  }

  // Configure Dio with interceptors and default options
  void _configureDio() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('Request: ${options.method} ${options.uri}');
        debugPrint('Request Headers: ${options.headers}');
        debugPrint('Request Data: ${options.data}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('Response: ${response.statusCode} ${response.data}');
        handler.next(response);
      },
      onError: (DioException e, ErrorInterceptorHandler handler) {
        _error = _handleDioError(e);
        notifyListeners();
        handler.next(e);
      },
    ));
  }

  // Handle Dio errors with specific messages
  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (e.response != null) {
      switch (e.response!.statusCode) {
        case 400:
          return 'Invalid request: ${e.response!.data['message'] ?? 'Bad request'}';
        case 401:
          return 'Unauthorized. Please log in again.';
        case 403:
          return 'Access denied. You don\'t have permission.';
        case 404:
          return 'User profile not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Error: ${e.response!.statusCode} - ${e.response!.statusMessage}';
      }
    }
    return e.message ?? 'An unexpected error occurred';
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load user profile from API
  Future<void> loadUserProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final url = _authApi.userProfileEndpoint(userId);

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data['user'] != null) {
        _user = User.fromJson(response.data['user']);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      _error = e is DioException ? _handleDioError(e) : e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile via API
  Future<void> updateUserProfile(User updatedUser) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final url = _authApi.userProfileEndpoint(userId);
      final payload = updatedUser.toJson()..remove('id');

      final response = await _dio.put(
        url,
        data: payload,
      );

      if (response.statusCode == 200) {
        // Update local user state with the provided updatedUser if response doesn't include user data
        _user = response.data['user'] != null
            ? User.fromJson(response.data['user'])
            : updatedUser;
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      _error = e is DioException ? _handleDioError(e) : e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
