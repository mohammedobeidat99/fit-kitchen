import 'package:cloud_firestore/cloud_firestore.dart';

class FeedPost {
  final String id;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final String recipeTitle;
  final String mealImageUrl;
  final double rating;
  final String comment;
  final DateTime timestamp;
  final List<String> likedBy;
  final int commentCount;

  FeedPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.recipeTitle,
    required this.mealImageUrl,
    required this.rating,
    required this.comment,
    required this.timestamp,
    this.likedBy = const [],
    this.commentCount = 0,
  });

  int get likes => likedBy.length;

  factory FeedPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedPost(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'User',
      userImageUrl: data['userImageUrl'],
      recipeTitle: data['recipeTitle'] ?? '',
      mealImageUrl: data['mealImageUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      commentCount: data['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'recipeTitle': recipeTitle,
      'mealImageUrl': mealImageUrl,
      'rating': rating,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
      'likedBy': likedBy,
      'commentCount': commentCount,
    };
  }
}
