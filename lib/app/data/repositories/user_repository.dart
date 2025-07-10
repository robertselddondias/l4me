import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class UserRepository {
  final CollectionReference _usersCollection = FirebaseService.firestore.collection('users');

  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Erro ao criar usuário: $e');
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).update(
        user.copyWith(updatedAt: DateTime.now()).toMap(),
      );
    } catch (e) {
      throw Exception('Erro ao atualizar usuário: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar usuário: $e');
    }
  }

  Future<bool> userExists(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Erro ao verificar usuário: $e');
    }
  }

  Stream<UserModel?> watchUser(String userId) {
    return _usersCollection
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final snapshot = await _usersCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar usuários: $e');
    }
  }

  Future<void> incrementPostsCount(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'postsCount': FieldValue.increment(1),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erro ao incrementar posts: $e');
    }
  }

  Future<void> decrementPostsCount(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'postsCount': FieldValue.increment(-1),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erro ao decrementar posts: $e');
    }
  }

  Future<void> updateProfileImage(String userId, String imageUrl) async {
    try {
      await _usersCollection.doc(userId).update({
        'profileImage': imageUrl,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar foto: $e');
    }
  }

  Future<void> updateUserSettings(String userId, Map<String, dynamic> settings) async {
    try {
      await _usersCollection.doc(userId).update({
        'settings': settings,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar configurações: $e');
    }
  }

  Future<void> updateInterests(String userId, List<String> interests) async {
    try {
      await _usersCollection.doc(userId).update({
        'interests': interests,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar interesses: $e');
    }
  }

  Future<List<UserModel>> getTopUsers({int limit = 10}) async {
    try {
      final snapshot = await _usersCollection
          .orderBy('postsCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar top usuários: $e');
    }
  }
}
