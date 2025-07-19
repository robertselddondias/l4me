import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:look4me/app/data/models/post_model.dart';
import 'package:look4me/app/data/models/user_model.dart'; // Importar UserModel
import 'package:look4me/app/data/models/vote_model.dart';
import 'package:look4me/app/data/repositories/post_repository.dart';
import 'package:look4me/app/data/repositories/vote_repository.dart';
import 'package:look4me/app/data/repositories/user_repository.dart';
import 'package:look4me/app/data/services/firebase_service.dart';

class HomeController extends GetxController {
  final PostRepository _postRepository = PostRepository();
  final VoteRepository _voteRepository = VoteRepository();
  final UserRepository _userRepository = UserRepository();

  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxList<PostModel> filteredPosts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString selectedOccasion = 'Todos'.obs;
  final RxMap<String, VoteModel> userVotes = <String, VoteModel>{}.obs;
  final RxBool hasNotifications = false.obs;

  final RxSet<String> followingUsers = <String>{}.obs;
  final RxSet<String> savedPosts = <String>{}.obs;

  final List<String> occasions = [
    'Todos',
    'Trabalho',
    'Festa',
    'Casual',
    'Encontro',
    'Formatura',
    'Casamento',
    'Academia',
    'Viagem',
    'Balada',
    'Praia',
    'Shopping',
    'Outros'
  ];

  @override
  void onInit() {
    super.onInit();
    loadPosts();
    loadUserVotes();
    loadUserFollowing();
    loadSavedPosts();
  }

  Future<void> loadPosts() async {
    try {
      isLoading.value = true;

      posts.clear();
      filteredPosts.clear();

      final fetchedPosts = await _postRepository.getAllPosts();
      await _enrichPostsWithAuthorData(fetchedPosts); // Chamada para enriquecer os posts
      posts.assignAll(fetchedPosts);
      _filterPosts();
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao carregar posts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserVotes() async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser != null) {
        userVotes.clear();

        final votes = await _voteRepository.getUserVotes(currentUser.uid);
        for (var vote in votes) {
          userVotes[vote.postId] = vote;
        }
      }
    } catch (e) {
      print('Erro ao carregar votos: $e');
    }
  }

  Future<void> loadUserFollowing() async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser != null) {
        final followingIds = await _userRepository.getUserFollowingIds(currentUser.uid);
        followingUsers.assignAll(followingIds);
      }
    } catch (e) {
      print('Erro ao carregar seguindo: $e');
    }
  }

  Future<void> refreshPostsComplete() async {
    posts.clear();
    filteredPosts.clear();
    userVotes.clear();
    followingUsers.clear();
    savedPosts.clear();

    await Future.wait([
      loadPosts(),
      loadUserVotes(),
      loadUserFollowing(),
      loadSavedPosts(),
    ]);

    update();
  }

  Future<void> refreshPosts() async {
    await Future.wait([
      loadPosts(),
      loadUserVotes(),
      loadUserFollowing(),
      loadSavedPosts(),
    ]);
  }

  Future<void> loadMorePosts() async {
    if (isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      final morePosts = await _postRepository.getMorePosts(posts.length);
      await _enrichPostsWithAuthorData(morePosts); // Chamada para enriquecer os posts
      posts.addAll(morePosts);
      _filterPosts();
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao carregar mais posts: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void filterByOccasion(String occasion) {
    selectedOccasion.value = occasion;
    _filterPosts();
  }

  void _filterPosts() {
    if (selectedOccasion.value == 'Todos') {
      filteredPosts.assignAll(posts);
    } else {
      filteredPosts.assignAll(
        posts.where((post) => post.occasionDisplayName == selectedOccasion.value),
      );
    }
  }

  Future<void> voteOnPost(String postId, int selectedOption) async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) return;

      final existingVote = userVotes[postId];
      if (existingVote != null) {
        Get.snackbar('Aviso', 'Você já votou neste post');
        return;
      }

      final vote = VoteModel(
        id: '',
        postId: postId,
        userId: currentUser.uid,
        selectedOption: selectedOption,
        createdAt: DateTime.now(),
      );

      final voteId = await _voteRepository.createVote(vote);
      await _postRepository.incrementVote(postId, selectedOption);

      userVotes[postId] = vote.copyWith(id: voteId);

      final postIndex = posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final updatedPost = posts[postIndex].copyWith(
          option1Votes: selectedOption == 1
              ? posts[postIndex].option1Votes + 1
              : posts[postIndex].option1Votes,
          option2Votes: selectedOption == 2
              ? posts[postIndex].option2Votes + 1
              : posts[postIndex].option2Votes,
          totalVotes: posts[postIndex].totalVotes + 1,
        );
        posts[postIndex] = updatedPost;
        _filterPosts();
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao votar: $e');
    }
  }

  Future<void> removeVote(String postId) async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) return;

      final existingVote = userVotes[postId];
      if (existingVote == null) {
        Get.snackbar('Aviso', 'Você não votou neste post');
        return;
      }

      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Remover Voto'),
          content: const Text('Tem certeza que deseja remover seu voto?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Remover'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      await _voteRepository.deleteVote(existingVote.id);

      await _postRepository.decrementVote(postId, existingVote.selectedOption);

      userVotes.remove(postId);

      final postIndex = posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final updatedPost = posts[postIndex].copyWith(
          option1Votes: existingVote.selectedOption == 1
              ? posts[postIndex].option1Votes - 1
              : posts[postIndex].option1Votes,
          option2Votes: existingVote.selectedOption == 2
              ? posts[postIndex].option2Votes - 1
              : posts[postIndex].option2Votes,
          totalVotes: posts[postIndex].totalVotes - 1,
        );
        posts[postIndex] = updatedPost;
        _filterPosts();
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao remover voto: $e');
      print('Erro detalhado ao remover voto: $e');
    }
  }

  Future<void> toggleFollowUser(String userId) async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) return;

      print('DEBUG: Antes - followingUsers.contains($userId): ${followingUsers.contains(userId)}');

      // Atualização imediata no RxSet
      if (followingUsers.contains(userId)) {
        followingUsers.remove(userId);
      } else {
        followingUsers.add(userId);
      }

      print('DEBUG: Depois - followingUsers.contains($userId): ${followingUsers.contains(userId)}');

      // Backend (sem bloquear UI)
      _updateFollowBackend(currentUser.uid, userId);

    } catch (e) {
      // Reverter em caso de erro
      if (followingUsers.contains(userId)) {
        followingUsers.remove(userId);
      } else {
        followingUsers.add(userId);
      }
      Get.snackbar('Erro', 'Erro ao seguir usuário: $e');
    }
  }

  void _updateFollowBackend(String currentUserId, String targetUserId) async {
    try {
      final isFollowing = followingUsers.contains(targetUserId);

      if (isFollowing) {
        await _userRepository.followUser(currentUserId, targetUserId);
        Get.snackbar(
          'Sucesso',
          'Você agora segue este usuário!',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        await _userRepository.unfollowUser(currentUserId, targetUserId);
        Get.snackbar(
          'Sucesso',
          'Você deixou de seguir este usuário',
          backgroundColor: const Color(0xFFF59E0B),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Reverter se der erro
      if (followingUsers.contains(targetUserId)) {
        followingUsers.remove(targetUserId);
      } else {
        followingUsers.add(targetUserId);
      }
      print('Erro na operação backend follow: $e');
    }
  }

  void sharePost(String postId) {
    Get.snackbar(
      'Compartilhar',
      'Link copiado para a área de transferência!',
      backgroundColor: const Color(0xFF3B82F6),
      colorText: const Color(0xFFFFFFFF),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  bool hasUserVoted(String postId) {
    return userVotes.containsKey(postId);
  }

  int? getUserVote(String postId) {
    return userVotes[postId]?.selectedOption;
  }

  bool isFollowingUser(String userId) {
    return followingUsers.contains(userId);
  }

  bool isPostSaved(String postId) {
    return savedPosts.contains(postId);
  }

  bool isOwnPost(String authorId) {
    final currentUser = FirebaseService.currentUser;
    return currentUser?.uid == authorId;
  }

  Future<void> toggleSavePost(String postId) async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) return;

      print('DEBUG: Antes - Post $postId está salvo: ${savedPosts.contains(postId)}');

      // CORREÇÃO: Atualização FORÇADA da RxSet
      if (savedPosts.contains(postId)) {
        savedPosts.remove(postId);
        print('DEBUG: Removido do savedPosts');
      } else {
        savedPosts.add(postId);
        print('DEBUG: Adicionado ao savedPosts');
      }

      // CRÍTICO: Forçar atualização da RxSet
      savedPosts.refresh();

      print('DEBUG: Depois - Post $postId está salvo: ${savedPosts.contains(postId)}');

      // Operação no backend
      if (!savedPosts.contains(postId)) {
        // Foi removido
        await FirebaseService.firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('savedPosts')
            .doc(postId)
            .delete();

        Get.snackbar(
          'Removido',
          'Post removido dos salvos',
          backgroundColor: Colors.amber,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          icon: Icon(Icons.bookmark_remove, color: Colors.white),
        );
      } else {
        // Foi adicionado
        await FirebaseService.firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('savedPosts')
            .doc(postId)
            .set({
          'postId': postId,
          'savedAt': FieldValue.serverTimestamp(),
        });
      }

      print('DEBUG: Operação no backend concluída');

    } catch (e) {
      print('ERROR: $e');

      // CORREÇÃO: Rollback em caso de erro
      if (savedPosts.contains(postId)) {
        savedPosts.remove(postId);
      } else {
        savedPosts.add(postId);
      }
      savedPosts.refresh();

      Get.snackbar('Erro', 'Erro ao salvar post: $e');
    }
  }

  Future<void> loadSavedPosts() async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser != null) {
        final snapshot = await FirebaseService.firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('savedPosts')
            .get();

        savedPosts.clear();
        for (var doc in snapshot.docs) {
          savedPosts.add(doc.data()['postId'] as String);
        }
      }
    } catch (e) {
      print('Erro ao carregar posts salvos: $e');
    }
  }

  Future<List<PostModel>> getSavedPostsData() async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) return [];

      final savedPostIds = savedPosts.toList();
      if (savedPostIds.isEmpty) return [];

      List<PostModel> savedPostsData = [];

      for (String postId in savedPostIds) {
        final post = await _postRepository.getPostById(postId);
        if (post != null && post.isActive) {
          savedPostsData.add(post);
        }
      }

      savedPostsData.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      await _enrichPostsWithAuthorData(savedPostsData); // Enriquecer posts salvos

      return savedPostsData;
    } catch (e) {
      print('Erro ao buscar dados dos posts salvos: $e');
      return [];
    }
  }

  Future<void> removeFromSaved(String postId) async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) return;

      savedPosts.remove(postId);

      await FirebaseService.firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('savedPosts')
          .doc(postId)
          .delete();

    } catch (e) {
      Get.snackbar('Erro', 'Erro ao remover post salvo: $e');
    }
  }

  void clearCache() {
    posts.clear();
    filteredPosts.clear();
    userVotes.clear();
    followingUsers.clear();
    savedPosts.clear();
    update();
  }

  /// NOVO: Função auxiliar para enriquecer posts com dados do autor
  Future<void> _enrichPostsWithAuthorData(List<PostModel> postList) async {
    final Map<String, UserModel> authorCache = {};

    for (int i = 0; i < postList.length; i++) {
      final post = postList[i];
      if (!authorCache.containsKey(post.authorId)) {
        final author = await _userRepository.getUserById(post.authorId);
        if (author != null) {
          authorCache[post.authorId] = author;
        }
      }

      final author = authorCache[post.authorId];
      if (author != null) {
        postList[i] = post.copyWith(
          authorName: author.name,
          authorProfileImage: author.profileImage,
        );
      }
    }
  }
}
