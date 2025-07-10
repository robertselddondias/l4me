import 'package:cloud_firestore/cloud_firestore.dart';

class VoteModel {
  final String id;
  final String postId;
  final String userId;
  final int selectedOption;
  final DateTime createdAt;
  final String? reason;

  VoteModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.selectedOption,
    required this.createdAt,
    this.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'selectedOption': selectedOption,
      'createdAt': Timestamp.fromDate(createdAt),
      'reason': reason,
    };
  }

  factory VoteModel.fromMap(Map<String, dynamic> map) {
    return VoteModel(
      id: map['id'] ?? '',
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      selectedOption: map['selectedOption'] ?? 1,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      reason: map['reason'],
    );
  }

  VoteModel copyWith({
    String? id,
    String? postId,
    String? userId,
    int? selectedOption,
    DateTime? createdAt,
    String? reason,
  }) {
    return VoteModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      selectedOption: selectedOption ?? this.selectedOption,
      createdAt: createdAt ?? this.createdAt,
      reason: reason ?? this.reason,
    );
  }
}
