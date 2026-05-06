import 'package:cloud_firestore/cloud_firestore.dart';

class FeedComment {
  final String id;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final String text;
  final DateTime timestamp;

  FeedComment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.text,
    required this.timestamp,
  });

  factory FeedComment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedComment(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'User',
      userImageUrl: data['userImageUrl'],
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
