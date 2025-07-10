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
  }

  Future<void> loadPosts() async {
    try {
      isLoading.value = true;
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
        final votes = await _voteRepository.getUserVotes(currentUser.uid);
        for (var vote in votes) {
          userVotes[vote.postId] = vote;
        }
      }
    } catch (e) {
      print('Erro ao carregar votos: $e');
    }
  }

  Future<void> refreshPosts() async {
    await loadPosts();
    await loadUserVotes();
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

      await _voteRepository.createVote(vote);
      await _postRepository.incrementVote(postId, selectedOption);

      userVotes[postId] = vote;

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

      Get.snackbar('Sucesso', 'Voto registrado!');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao votar: $e');
    }
  }

  bool hasUserVoted(String postId) {
    return userVotes.containsKey(postId);
  }

  int? getUserVote(String postId) {
    return userVotes[postId]?.selectedOption;
  }
}
