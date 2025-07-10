import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/story_model.dart';
import '../services/firebase_service.dart';

class StoryRepository {
  final CollectionReference _storiesCollection = FirebaseService.firestore.collection('stories');

  Future<String> createStory(StoryModel story) async {
    try {
      final docRef = await _storiesCollection.add(story.toMap());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar story: $e');
    }
  }

  Future<List<StoryModel>> getActiveStories({int limit = 50}) async {
    try {
      final now = DateTime.now();
      final snapshot = await _storiesCollection
          .where('isActive', isEqualTo: true)
          .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('expiresAt')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => StoryModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar stories: $e');
    }
  }

  Future<List<StoryModel>> getUserStories(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _storiesCollection
          .where('authorId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => StoryModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar stories do usuário: $e');
    }
  }

  Future<List<StoryModel>> getStoriesByType(StoryType type, {int limit = 20}) async {
    try {
      final now = DateTime.now();
      final snapshot = await _storiesCollection
          .where('isActive', isEqualTo: true)
          .where('type', isEqualTo: type.toString().split('.').last)
          .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('expiresAt')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => StoryModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar stories por tipo: $e');
    }
  }

  Future<StoryModel?> getStoryById(String storyId) async {
    try {
      final doc = await _storiesCollection.doc(storyId).get();

      if (doc.exists) {
        return StoryModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar story: $e');
    }
  }

  Future<void> updateStory(StoryModel story) async {
    try {
      await _storiesCollection.doc(story.id).update(story.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar story: $e');
    }
  }

  Future<void> deleteStory(String storyId) async {
    try {
      await _storiesCollection.doc(storyId).update({
        'isActive': false,
      });
    } catch (e) {
      throw Exception('Erro ao deletar story: $e');
    }
  }

  Future<void> markAsViewed(String storyId, String userId) async {
    try {
      await _storiesCollection.doc(storyId).update({
        'viewedBy': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw Exception('Erro ao marcar como visualizado: $e');
    }
  }

  Stream<List<StoryModel>> watchActiveStories({int limit = 50}) {
    final now = DateTime.now();
    return _storiesCollection
        .where('isActive', isEqualTo: true)
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('expiresAt')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => StoryModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<List<StoryModel>> searchStories(String query, {int limit = 20}) async {
    try {
      final now = DateTime.now();
      final snapshot = await _storiesCollection
          .where('isActive', isEqualTo: true)
          .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
          .where('tags', arrayContains: query.toLowerCase())
          .orderBy('expiresAt')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => StoryModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar stories: $e');
    }
  }

  Future<void> cleanupExpiredStories() async {
    try {
      final now = DateTime.now();
      final snapshot = await _storiesCollection
          .where('expiresAt', isLessThan: Timestamp.fromDate(now))
          .where('isActive', isEqualTo: true)
          .get();

      final batch = FirebaseFirestore.instance.batch();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isActive': false});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao limpar stories expirados: $e');
    }
  }
}
