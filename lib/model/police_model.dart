

class Police {
  final String badgeNo;
  final String email;
  final int id;
  final String name;
  final String phone;
  final String station;

  Police({
    required this.badgeNo,
    required this.email,
    required this.id,
    required this.name,
    required this.phone,
    required this.station,
  });

  factory Police.fromJson(Map<String, dynamic> json) {
    return Police(
      badgeNo: json['badge_no'] as String,
      email: json['email'] as String,
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      station: json['station'] as String,
    );
  }

  static List<Police> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Police.fromJson(json)).toList();
  }
}