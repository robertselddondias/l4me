import 'package:cloud_firestore/cloud_firestore.dart';

class QuickLookModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorProfileImage;
  final String question;
  final String imageOption1;
  final String imageOption2;
  final String occasion;
  final DateTime createdAt;
  final DateTime expiresAt; // 15 minutos após criação
  final int option1Votes;
  final int option2Votes;
  final List<String> tags;
  final bool isActive;

  QuickLookModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorProfileImage,
    required this.question,
    required this.imageOption1,
    required this.imageOption2,
    required this.occasion,
    required this.createdAt,
    required this.expiresAt,
    this.option1Votes = 0,
    this.option2Votes = 0,
    this.tags = const [],
    this.isActive = true,
  });

  int get totalVotes => option1Votes + option2Votes;

  double get option1Percentage {
    if (totalVotes == 0) return 0;
    return (option1Votes / totalVotes) * 100;
  }

  double get option2Percentage {
    if (totalVotes == 0) return 0;
    return (option2Votes / totalVotes) * 100;
  }

  bool get hasExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  Duration get timeRemaining {
    if (hasExpired) return Duration.zero;
    return expiresAt.difference(DateTime.now());
  }

  String get occasionDisplayName {
    switch (occasion) {
      case 'trabalho':
        return 'Trabalho';
      case 'festa':
        return 'Festa';
      case 'casual':
        return 'Casual';
      case 'encontro':
        return 'Encontro';
      case 'formatura':
        return 'Formatura';
      case 'casamento':
        return 'Casamento';
      case 'academia':
        return 'Academia';
      case 'viagem':
        return 'Viagem';
      case 'balada':
        return 'Balada';
      case 'praia':
        return 'Praia';
      case 'shopping':
        return 'Shopping';
      default:
        return 'Outros';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorProfileImage': authorProfileImage,
      'question': question,
      'imageOption1': imageOption1,
      'imageOption2': imageOption2,
      'occasion': occasion,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'option1Votes': option1Votes,
      'option2Votes': option2Votes,
      'tags': tags,
      'isActive': isActive,
    };
  }

  factory QuickLookModel.fromMap(Map<String, dynamic> map) {
    return QuickLookModel(
      id: map['id'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorProfileImage: map['authorProfileImage'],
      question: map['question'] ?? '',
      imageOption1: map['imageOption1'] ?? '',
      imageOption2: map['imageOption2'] ?? '',
      occasion: map['occasion'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
      option1Votes: map['option1Votes'] ?? 0,
      option2Votes: map['option2Votes'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      isActive: map['isActive'] ?? true,
    );
  }

  QuickLookModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorProfileImage,
    String? question,
    String? imageOption1,
    String? imageOption2,
    String? occasion,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? option1Votes,
    int? option2Votes,
    List<String>? tags,
    bool? isActive,
  }) {
    return QuickLookModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorProfileImage: authorProfileImage ?? this.authorProfileImage,
      question: question ?? this.question,
      imageOption1: imageOption1 ?? this.imageOption1,
      imageOption2: imageOption2 ?? this.imageOption2,
      occasion: occasion ?? this.occasion,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      option1Votes: option1Votes ?? this.option1Votes,
      option2Votes: option2Votes ?? this.option2Votes,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
    );
  }
}
