import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lostandfound/config/api_endpoint.dart';
import 'package:lostandfound/model/user_match_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserMatchesProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));
  final AuthApi _authApi = AuthApi();

  bool _isLoading = false;
  String? _error;
  List<UserMatch> _matches = [];
  String? _message;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserMatch> get matches => _matches;
  String? get message => _message;

  // Fetch confirmed matches for a user
  Future<void> getUserMatches(int userId) async {
    _isLoading = true;
    _error = null;
    _matches = [];
    _message = null;
    notifyListeners();

    try {
      Response response = await _dio.get(_authApi.userMatchesEndpoint(userId));
      if (response.statusCode == 200) {
        final data = response.data;
        _matches = (data['matches'] as List)
            .map((match) => UserMatch.fromJson(match))
            .toList();
        _message = data['message'];
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Failed to fetch user matches';
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a match between lost and found items
  Future<bool> createMatch(int lostId, int foundId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Response response = await _dio.post(
        _authApi.createMatchEndpoint,
        data: {'lost_id': lostId, 'found_id': foundId},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _message = response.data['message'];
        return true;
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Failed to create match';
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _isLoading = false;
    _error = null;
    _matches = [];
    _message = null;
    notifyListeners();
  }
}
