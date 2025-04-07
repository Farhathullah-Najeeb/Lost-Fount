class UserMatch {
  final int matchId;
  final int lostId;
  final int foundId;
  final String matchDate;
  final String lostItemName;
  final String lostDescription;
  final String lostLocation;
  final String lostDateTime;
  final String foundItemName;
  final String foundDescription;
  final String foundLocation;
  final String foundDateTime;

  UserMatch({
    required this.matchId,
    required this.lostId,
    required this.foundId,
    required this.matchDate,
    required this.lostItemName,
    required this.lostDescription,
    required this.lostLocation,
    required this.lostDateTime,
    required this.foundItemName,
    required this.foundDescription,
    required this.foundLocation,
    required this.foundDateTime,
  });

  factory UserMatch.fromJson(Map<String, dynamic> json) {
    return UserMatch(
      matchId: json['match_id'],
      lostId: json['lost_id'],
      foundId: json['found_id'],
      matchDate: json['match_date'],
      lostItemName: json['lost_item_name'],
      lostDescription: json['lost_description'],
      lostLocation: json['lost_location'],
      lostDateTime: json['lost_date_time'],
      foundItemName: json['found_item_name'],
      foundDescription: json['found_description'],
      foundLocation: json['found_location'],
      foundDateTime: json['found_date_time'],
    );
  }
}