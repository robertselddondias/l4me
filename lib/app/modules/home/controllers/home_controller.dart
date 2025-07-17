import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:look4me/app/data/models/post_model.dart';
import 'package:look4me/app/data/models/vote_model.dart';
import 'package:look4me/app/data/repositories/post_repository.dart';
import 'package:look4me/app/data/repositories/vote_repository.dart';
import 'package:look4me/app/data/services/firebase_service.dart';

class HomeController extends GetxController {
  final PostRepository _postRepository = PostRepository();
  final VoteRepository _voteRepository = VoteRepository();

  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxList<PostModel> filteredPosts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString selectedOccasion = 'Todos'.obs;
  final RxMap<String, VoteModel> userVotes = <String, VoteModel>{}.obs;
  final RxBool hasNotifications = false.obs;

  // NOVOS: Estados para seguir usuários e posts salvos
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

  // NOVA: Carregar usuários que o usuário atual segue
  Future<void> loadUserFollowing() async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser != null) {
        // TODO: Implementar busca real no Firestore
        // Por enquanto, usar lista vazia
        followingUsers.clear();
      }
    } catch (e) {
      print('Erro ao carregar seguindo: $e');
    }
  }

  // NOVA: Carregar posts salvos
  Future<void> loadSavedPosts() async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser != null) {
        // TODO: Implementar busca real no Firestore
        // Por enquanto, usar lista vazia
        savedPosts.clear();
      }
    } catch (e) {
      print('Erro ao carregar posts salvos: $e');
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

      // Atualizar voto local com ID do Firestore
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

      Get.snackbar(
        'Sucesso',
        'Voto registrado!',
        backgroundColor: const Color(0xFF10B981),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.BOTTOM,
      );
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

      // Confirmar remoção
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

      // Remover voto do Firestore
      await _voteRepository.deleteVote(existingVote.id);

      // Decrementar contador no post
      await _postRepository.decrementVote(postId, existingVote.selectedOption);

      // Remover voto local
      userVotes.remove(postId);

      // Atualizar post local
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

      Get.snackbar(
        'Sucesso',
        'Voto removido!',
        backgroundColor: const Color(0xFFF59E0B),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao remover voto: $e');
    }
  }

  // NOVA: Seguir/deixar de seguir usuário
  Future<void> toggleFollowUser(String userId) async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) return;

      if (followingUsers.contains(userId)) {
        // Deixar de seguir
        followingUsers.remove(userId);
        // TODO: Implementar no Firestore

        Get.snackbar(
          'Sucesso',
          'Você deixou de seguir este usuário',
          backgroundColor: const Color(0xFFF59E0B),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Seguir
        followingUsers.add(userId);
        // TODO: Implementar no Firestore

        Get.snackbar(
          'Sucesso',
          'Você agora segue este usuário!',
          backgroundColor: const Color(0xFF10B981),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao seguir usuário: $e');
    }
  }

  // NOVA: Salvar/dessalvar post
  Future<void> toggleSavePost(String postId) async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) return;

      if (savedPosts.contains(postId)) {
        // Remover dos salvos
        savedPosts.remove(postId);
        // TODO: Implementar no Firestore

        Get.snackbar(
          'Removido',
          'Post removido dos salvos',
          backgroundColor: const Color(0xFFF59E0B),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Salvar
        savedPosts.add(postId);
        // TODO: Implementar no Firestore

        Get.snackbar(
          'Salvo',
          'Post salvo com sucesso!',
          backgroundColor: const Color(0xFF10B981),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao salvar post: $e');
    }
  }

  // NOVA: Compartilhar post
  void sharePost(String postId) {
    // TODO: Implementar compartilhamento real
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

  // NOVA: Verificar se está seguindo usuário
  bool isFollowingUser(String userId) {
    return followingUsers.contains(userId);
  }

  // NOVA: Verificar se post está salvo
  bool isPostSaved(String postId) {
    return savedPosts.contains(postId);
  }

  // NOVA: Verificar se é próprio post
  bool isOwnPost(String authorId) {
    final currentUser = FirebaseService.currentUser;
    return currentUser?.uid == authorId;
  }

  void clearCache() {
    posts.clear();
    filteredPosts.clear();
    userVotes.clear();
    followingUsers.clear();
    savedPosts.clear();
    update();
  }
}
