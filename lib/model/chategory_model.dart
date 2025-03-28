class Category {
  final int id;
  final String categoryName;
  final String categoryDetails;

  Category({
    required this.id,
    required this.categoryName,
    required this.categoryDetails,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      categoryName: json['category_name'],
      categoryDetails: json['category_details'],
    );
  }
}