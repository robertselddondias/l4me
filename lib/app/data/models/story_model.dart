import 'package:cloud_firestore/cloud_firestore.dart';

enum StoryType {
  tip,
  outfit,
  accessory,
  trend,
  discount,
  tutorial
}

class StoryModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorProfileImage;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final StoryType type;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewedBy;
  final List<String> tags;
  final bool isActive;
  final String? linkUrl;
  final Map<String, dynamic> metadata;

  StoryModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorProfileImage,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    required this.type,
    required this.createdAt,
    required this.expiresAt,
    this.viewedBy = const [],
    this.tags = const [],
    this.isActive = true,
    this.linkUrl,
    this.metadata = const {},
  });

  bool get hasExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  int get viewsCount {
    return viewedBy.length;
  }

  bool isViewedBy(String userId) {
    return viewedBy.contains(userId);
  }

  String get typeDisplayName {
    switch (type) {
      case StoryType.tip:
        return 'Dica';
      case StoryType.outfit:
        return 'Look';
      case StoryType.accessory:
        return 'Acessório';
      case StoryType.trend:
        return 'Tendência';
      case StoryType.discount:
        return 'Desconto';
      case StoryType.tutorial:
        return 'Tutorial';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorProfileImage': authorProfileImage,
      'content': content,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'type': type.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'viewedBy': viewedBy,
      'tags': tags,
      'isActive': isActive,
      'linkUrl': linkUrl,
      'metadata': metadata,
    };
  }

  factory StoryModel.fromMap(Map<String, dynamic> map) {
    return StoryModel(
      id: map['id'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorProfileImage: map['authorProfileImage'],
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      type: StoryType.values.firstWhere(
            (e) => e.toString().split('.').last == map['type'],
        orElse: () => StoryType.tip,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
      viewedBy: List<String>.from(map['viewedBy'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      isActive: map['isActive'] ?? true,
      linkUrl: map['linkUrl'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  StoryModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorProfileImage,
    String? content,
    String? imageUrl,
    String? videoUrl,
    StoryType? type,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<String>? viewedBy,
    List<String>? tags,
    bool? isActive,
    String? linkUrl,
    Map<String, dynamic>? metadata,
  }) {
    return StoryModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorProfileImage: authorProfileImage ?? this.authorProfileImage,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewedBy: viewedBy ?? this.viewedBy,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      linkUrl: linkUrl ?? this.linkUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}
