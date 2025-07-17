import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../services/firebase_service.dart';

class PostRepository {
  final CollectionReference _postsCollection = FirebaseService.firestore.collection('posts');

  Future<String> createPost(PostModel post) async {
    try {
      final docRef = await _postsCollection.add(post.toMap());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar post: $e');
    }
  }

  Future<List<PostModel>> getAllPosts({int limit = 20}) async {
    try {
      final snapshot = await _postsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar posts: $e');
    }
  }

  Future<List<PostModel>> getMorePosts(int offset, {int limit = 20}) async {
    try {
      final snapshot = await _postsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      if (snapshot.docs.length <= offset) return [];

      final remainingDocs = snapshot.docs.skip(offset).toList();

      return remainingDocs
          .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar mais posts: $e');
    }
  }

  Future<List<PostModel>> getPostsByOccasion(PostOccasion occasion, {int limit = 20}) async {
    try {
      final snapshot = await _postsCollection
          .where('isActive', isEqualTo: true)
          .where('occasion', isEqualTo: occasion.toString().split('.').last)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar posts por ocasião: $e');
    }
  }

  Future<List<PostModel>> getUserPosts(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _postsCollection
          .where('authorId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar posts do usuário: $e');
    }
  }

  Future<PostModel?> getPostById(String postId) async {
    try {
      final doc = await _postsCollection.doc(postId).get();

      if (doc.exists) {
        return PostModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar post: $e');
    }
  }

  Future<void> updatePost(PostModel post) async {
    try {
      await _postsCollection.doc(post.id).update(post.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar post: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _postsCollection.doc(postId).update({
        'isActive': false,
      });
    } catch (e) {
      throw Exception('Erro ao deletar post: $e');
    }
  }

  Future<void> incrementVote(String postId, int option) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final postRef = _postsCollection.doc(postId);

      if (option == 1) {
        batch.update(postRef, {
          'option1Votes': FieldValue.increment(1),
          'totalVotes': FieldValue.increment(1),
        });
      } else if (option == 2) {
        batch.update(postRef, {
          'option2Votes': FieldValue.increment(1),
          'totalVotes': FieldValue.increment(1),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao incrementar voto: $e');
    }
  }

  Stream<List<PostModel>> watchPosts({int limit = 20}) {
    return _postsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<List<PostModel>> searchPosts(String query, {int limit = 20}) async {
    try {
      final snapshot = await _postsCollection
          .where('isActive', isEqualTo: true)
          .where('tags', arrayContains: query.toLowerCase())
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar posts: $e');
    }
  }

  Future<List<PostModel>> getTrendingPosts({int limit = 10}) async {
    try {
      final snapshot = await _postsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('totalVotes', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar posts em alta: $e');
    }
  }

  Future<void> decrementVote(String postId, int option) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final postRef = _postsCollection.doc(postId);

      if (option == 1) {
        batch.update(postRef, {
          'option1Votes': FieldValue.increment(-1),
          'totalVotes': FieldValue.increment(-1),
        });
      } else if (option == 2) {
        batch.update(postRef, {
          'option2Votes': FieldValue.increment(-1),
          'totalVotes': FieldValue.increment(-1),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao decrementar voto: $e');
    }
  }
}
