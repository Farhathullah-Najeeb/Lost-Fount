// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lostandfound/config/api_endpoint.dart';

class LoginProvider with ChangeNotifier {
  final AuthApi _authApi = AuthApi();
  String _username = '';
  String _password = '';
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  int? _userId;

  String get username => _username;
  String get password => _password;
  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get userId => _userId;

  void setUsername(String value) {
    _username = value.trim();
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value.trim();
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    print('Login Endpoint: ${_authApi.loginEndpoint}');
    print('USERNAME: $_username');
    print('PASSWORD: $_password');

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      var headers = {'Content-Type': 'application/json'};
      var data = json.encode({"username": _username, "password": _password});

      var dio = Dio();
      dio.options
        ..connectTimeout = Duration(seconds: 10) // 10s timeout
        ..receiveTimeout = Duration(seconds: 10);

      var response = await dio.post(
        _authApi.loginEndpoint,
        options: Options(headers: headers),
        data: data,
      );
      

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.data}');

      if (response.statusCode == 200) {
        
        final responseData = response.data as Map<String, dynamic>;
        _userId = responseData['user_id'];
        print('USER ID: $_userId');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', _userId!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _errorMessage = response.data['message'] ?? 'Login failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!)),
        );
      }
    } on DioException catch (e) {
      print('DioException: $e');
      if (e.type == DioExceptionType.connectionTimeout) {
        _errorMessage = 'Connection timed out. Please check your network.';
      } else if (e.type == DioExceptionType.connectionError) {
        _errorMessage =
            'Unable to connect to the server. Check if the server is running.';
      } else {
        _errorMessage = 'Login failed: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    } catch (e) {
      print('Unexpected Error: $e');
      _errorMessage = 'Unexpected error: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id');
    return _userId != null;
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    _userId = null;
    notifyListeners();
  }
}

