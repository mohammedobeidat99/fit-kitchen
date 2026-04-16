class CookingHistoryEntry {
  final String id;
  final String recipeId;
  final String recipeTitle;
  final DateTime timestamp;
  final int calories;

  CookingHistoryEntry({
    required this.id,
    required this.recipeId,
    required this.recipeTitle,
    required this.timestamp,
    required this.calories,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipeId': recipeId,
        'recipeTitle': recipeTitle,
        'timestamp': timestamp.toIso8601String(),
        'calories': calories,
      };

  factory CookingHistoryEntry.fromJson(Map<String, dynamic> json) => CookingHistoryEntry(
        id: json['id'],
        recipeId: json['recipeId'],
        recipeTitle: json['recipeTitle'],
        timestamp: DateTime.parse(json['timestamp']),
        calories: json['calories'],
      );
}
