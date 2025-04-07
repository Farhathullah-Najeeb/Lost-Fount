class AuthApi {
  final String baseUrl;

  // Constructor to allow dynamic base URL
  AuthApi({this.baseUrl = 'http://192.168.1.13:5001'});

  // Existing Endpoints
  String get loginEndpoint => '$baseUrl/api/login';
  String get registerEndpoint => '$baseUrl/api/register';
  String get categoriesEndpoint => '$baseUrl/api/categories';
  String get itemsEndpoint => '$baseUrl/api/items';
  String get policeItemsEndpoint => '$baseUrl/api/police';
  String userItemsEndpoint(int userId) => '$baseUrl/api/items/user/$userId';
  String matchesEndpoint(int itemId) => '$baseUrl/api/items/$itemId/matches';
  String get createMatchEndpoint => '$baseUrl/api/matches';
  String userMatchesEndpoint(int userId) =>
      '$baseUrl/api/users/$userId/matches';
}
