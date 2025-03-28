class Item {
  final int id;
  final int userId;
  final String itemName;
  final int categoryId;
  final String? description;
  final String? imageUrl;
  final String? location;
  final String? geotag;
  final String dateTime;
  final String type;

  Item({
    required this.id,
    required this.userId,
    required this.itemName,
    required this.categoryId,
    this.description,
    this.imageUrl,
    this.location,
    this.geotag,
    required this.dateTime,
    required this.type,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      userId: json['user_id'],
      itemName: json['item_name'],
      categoryId: json['category_id'],
      description: json['description'],
      imageUrl: json['image_url'],
      location: json['location'],
      geotag: json['geotag'],
      dateTime: json['date_time'],
      type: json['type'],
    );
  }
}