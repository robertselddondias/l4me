import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vote_model.dart';
import '../services/firebase_service.dart';

class VoteRepository {
  final CollectionReference _votesCollection = FirebaseService.firestore.collection('votes');

  Future<String> createVote(VoteModel vote) async {
    try {
      final docRef = await _votesCollection.add(vote.toMap());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar voto: $e');
    }
  }

  Future<List<VoteModel>> getUserVotes(String userId) async {
    try {
      final snapshot = await _votesCollection
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => VoteModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar votos do usuário: $e');
    }
  }

  Future<List<VoteModel>> getPostVotes(String postId) async {
    try {
      final snapshot = await _votesCollection
          .where('postId', isEqualTo: postId)
          .get();

      return snapshot.docs
          .map((doc) => VoteModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar votos do post: $e');
    }
  }

  Future<VoteModel?> getUserVoteForPost(String userId, String postId) async {
    try {
      final snapshot = await _votesCollection
          .where('userId', isEqualTo: userId)
          .where('postId', isEqualTo: postId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return VoteModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar voto: $e');
    }
  }

  Future<bool> hasUserVoted(String userId, String postId) async {
    try {
      final vote = await getUserVoteForPost(userId, postId);
      return vote != null;
    } catch (e) {
      throw Exception('Erro ao verificar voto: $e');
    }
  }

  Future<Map<int, int>> getVoteCount(String postId) async {
    try {
      final snapshot = await _votesCollection
          .where('postId', isEqualTo: postId)
          .get();

      int option1Count = 0;
      int option2Count = 0;

      for (var doc in snapshot.docs) {
        final vote = VoteModel.fromMap(doc.data() as Map<String, dynamic>);
        if (vote.selectedOption == 1) {
          option1Count++;
        } else if (vote.selectedOption == 2) {
          option2Count++;
        }
      }

      return {
        1: option1Count,
        2: option2Count,
      };
    } catch (e) {
      throw Exception('Erro ao contar votos: $e');
    }
  }

  Future<void> deleteVote(String voteId) async {
    try {
      await _votesCollection.doc(voteId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar voto: $e');
    }
  }

  Stream<List<VoteModel>> watchUserVotes(String userId) {
    return _votesCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => VoteModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Stream<List<VoteModel>> watchPostVotes(String postId) {
    return _votesCollection
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => VoteModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }
}
