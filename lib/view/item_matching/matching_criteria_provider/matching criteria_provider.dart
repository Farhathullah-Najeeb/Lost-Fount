import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lostandfound/config/api_endpoint.dart';
import 'package:lostandfound/model/item_model.dart';

class MatchCriteria {
  final bool categoryMatch;
  final bool descriptionMatch;
  final double descriptionSimilarityScore;
  final bool locationMatch;
  final bool nameSimilarity;

  MatchCriteria({
    required this.categoryMatch,
    required this.descriptionMatch,
    required this.descriptionSimilarityScore,
    required this.locationMatch,
    required this.nameSimilarity,
  });

  factory MatchCriteria.fromJson(Map<String, dynamic> json) {
    return MatchCriteria(
      categoryMatch: json['category_match'] ?? false,
      descriptionMatch: json['description_match'] ?? false,
      descriptionSimilarityScore:
          (json['description_similarity_score'] ?? 0.0).toDouble(),
      locationMatch: json['location_match'] ?? false,
      nameSimilarity: json['name_similarity'] ?? false,
    );
  }
}

class Match {
  final MatchCriteria matchCriteria;
  final Item matchedItem;

  Match({
    required this.matchCriteria,
    required this.matchedItem,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      matchCriteria:
          MatchCriteria.fromJson(json['match_criteria']), // Fixed typo
      matchedItem: Item.fromJson(json['matched_item']),
    );
  }
}

class MatchesProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));
  final AuthApi _authApi = AuthApi();

  bool _isLoading = false;
  String? _error;
  Item? _item;
  List<Match> _matches = [];
  String? _message;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Item? get item => _item;
  List<Match> get matches => _matches;
  String? get message => _message;
  String get baseUrl => _authApi.baseUrl;

  Future<void> getMatches(int itemId) async {
    _isLoading = true;
    _error = null;
    _item = null;
    _matches = [];
    _message = null;
    notifyListeners();

    try {
      Response response = await _dio.get(
          _authApi.matchesEndpoint(itemId)); // Updated to use matchesEndpoint
      if (response.statusCode == 200) {
        final data = response.data;
        _item = Item.fromJson(data['item']);
        _matches = (data['matches'] as List)
            .map((match) => Match.fromJson(match))
            .toList();
        _message = data['message'];
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Failed to fetch matches';
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _isLoading = false;
    _error = null;
    _item = null;
    _matches = [];
    _message = null;
    notifyListeners();
  }
}
