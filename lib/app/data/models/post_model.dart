import 'package:cloud_firestore/cloud_firestore.dart';

enum PostOccasion {
  trabalho,
  festa,
  casual,
  encontro,
  formatura,
  casamento,
  academia,
  viagem,
  balada,
  praia,
  shopping,
  outros
}

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorProfileImage;
  final String description;
  final String imageOption1;
  final String imageOption2;
  final PostOccasion occasion;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int option1Votes;
  final int option2Votes;
  final int totalVotes;
  final bool isActive;
  final Map<String, dynamic> metadata;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorProfileImage,
    required this.description,
    required this.imageOption1,
    required this.imageOption2,
    required this.occasion,
    this.tags = const [],
    required this.createdAt,
    this.expiresAt,
    this.option1Votes = 0,
    this.option2Votes = 0,
    this.totalVotes = 0,
    this.isActive = true,
    this.metadata = const {},
  });

  double get option1Percentage {
    if (totalVotes == 0) return 0;
    return (option1Votes / totalVotes) * 100;
  }

  double get option2Percentage {
    if (totalVotes == 0) return 0;
    return (option2Votes / totalVotes) * 100;
  }

  bool get hasExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  String get occasionDisplayName {
    switch (occasion) {
      case PostOccasion.trabalho:
        return 'Trabalho';
      case PostOccasion.festa:
        return 'Festa';
      case PostOccasion.casual:
        return 'Casual';
      case PostOccasion.encontro:
        return 'Encontro';
      case PostOccasion.formatura:
        return 'Formatura';
      case PostOccasion.casamento:
        return 'Casamento';
      case PostOccasion.academia:
        return 'Academia';
      case PostOccasion.viagem:
        return 'Viagem';
      case PostOccasion.balada:
        return 'Balada';
      case PostOccasion.praia:
        return 'Praia';
      case PostOccasion.shopping:
        return 'Shopping';
      case PostOccasion.outros:
        return 'Outros';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorProfileImage': authorProfileImage,
      'description': description,
      'imageOption1': imageOption1,
      'imageOption2': imageOption2,
      'occasion': occasion.toString().split('.').last,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'option1Votes': option1Votes,
      'option2Votes': option2Votes,
      'totalVotes': totalVotes,
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorProfileImage: map['authorProfileImage'],
      description: map['description'] ?? '',
      imageOption1: map['imageOption1'] ?? '',
      imageOption2: map['imageOption2'] ?? '',
      occasion: PostOccasion.values.firstWhere(
            (e) => e.toString().split('.').last == map['occasion'],
        orElse: () => PostOccasion.outros,
      ),
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: map['expiresAt'] != null
          ? (map['expiresAt'] as Timestamp).toDate()
          : null,
      option1Votes: map['option1Votes'] ?? 0,
      option2Votes: map['option2Votes'] ?? 0,
      totalVotes: map['totalVotes'] ?? 0,
      isActive: map['isActive'] ?? true,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  PostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorProfileImage,
    String? description,
    String? imageOption1,
    String? imageOption2,
    PostOccasion? occasion,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? option1Votes,
    int? option2Votes,
    int? totalVotes,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorProfileImage: authorProfileImage ?? this.authorProfileImage,
      description: description ?? this.description,
      imageOption1: imageOption1 ?? this.imageOption1,
      imageOption2: imageOption2 ?? this.imageOption2,
      occasion: occasion ?? this.occasion,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      option1Votes: option1Votes ?? this.option1Votes,
      option2Votes: option2Votes ?? this.option2Votes,
      totalVotes: totalVotes ?? this.totalVotes,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
}
