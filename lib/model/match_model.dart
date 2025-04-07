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
