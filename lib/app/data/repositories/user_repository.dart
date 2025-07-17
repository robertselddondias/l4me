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
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
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

  /// Adiciona um usuário à lista de 'seguindo' do currentUser
  /// e incrementa o 'followingCount' do currentUser,
  /// e adiciona o currentUser à lista de 'seguidores' do targetUser
  /// e incrementa o 'followersCount' do targetUser.
  Future<void> followUser(String currentUserId, String targetUserId) async {
    try {
      // 1. Adicionar targetUserId à subcoleção 'following' do currentUser
      await _usersCollection.doc(currentUserId).collection('following').doc(targetUserId).set({
        'userId': targetUserId,
        'followedAt': FieldValue.serverTimestamp(),
      });

      // 2. Adicionar currentUserId à subcoleção 'followers' do targetUser
      await _usersCollection.doc(targetUserId).collection('followers').doc(currentUserId).set({
        'userId': currentUserId,
        'followedAt': FieldValue.serverTimestamp(),
      });

      // 3. Incrementar 'followingCount' do currentUser
      await _usersCollection.doc(currentUserId).update({
        'followingCount': FieldValue.increment(1),
        'updatedAt': Timestamp.now(),
      });

      // 4. Incrementar 'followersCount' do targetUser
      await _usersCollection.doc(targetUserId).update({
        'followersCount': FieldValue.increment(1),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erro ao seguir usuário: $e');
    }
  }

  /// Remove um usuário da lista de 'seguindo' do currentUser
  /// e decrementa o 'followingCount' do currentUser,
  /// e remove o currentUser da lista de 'seguidores' do targetUser
  /// e decrementa o 'followersCount' do targetUser.
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    try {
      // 1. Remover targetUserId da subcoleção 'following' do currentUser
      await _usersCollection.doc(currentUserId).collection('following').doc(targetUserId).delete();

      // 2. Remover currentUserId da subcoleção 'followers' do targetUser
      await _usersCollection.doc(targetUserId).collection('followers').doc(currentUserId).delete();

      // 3. Decrementar 'followingCount' do currentUser
      await _usersCollection.doc(currentUserId).update({
        'followingCount': FieldValue.increment(-1),
        'updatedAt': Timestamp.now(),
      });

      // 4. Decrementar 'followersCount' do targetUser
      await _usersCollection.doc(targetUserId).update({
        'followersCount': FieldValue.increment(-1),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erro ao deixar de seguir usuário: $e');
    }
  }

  /// Verifica se o currentUserId está seguindo o targetUserId.
  Future<bool> isUserFollowing(String currentUserId, String targetUserId) async {
    try {
      final doc = await _usersCollection.doc(currentUserId).collection('following').doc(targetUserId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Erro ao verificar se está seguindo: $e');
    }
  }

  /// Retorna os IDs dos usuários que o userId está seguindo.
  Future<List<String>> getUserFollowingIds(String userId) async {
    try {
      final snapshot = await _usersCollection.doc(userId).collection('following').get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('Erro ao obter IDs de quem o usuário segue: $e');
    }
  }

  /// Retorna os IDs dos usuários que seguem o userId.
  Future<List<String>> getUserFollowerIds(String userId) async {
    try {
      final snapshot = await _usersCollection.doc(userId).collection('followers').get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('Erro ao obter IDs dos seguidores do usuário: $e');
    }
  }
}
