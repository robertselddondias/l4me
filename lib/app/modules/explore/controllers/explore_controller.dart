import 'package:get/get.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/story_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/story_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';

class ExploreController extends GetxController {
  final PostRepository _postRepository = PostRepository();
  final StoryRepository _storyRepository = StoryRepository();
  final UserRepository _userRepository = UserRepository();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingStories = false.obs;
  final RxBool isLoadingTrending = false.obs;
  final RxBool isLoadingUsers = false.obs;

  final RxList<StoryModel> trendingStories = <StoryModel>[].obs;
  final RxList<PostModel> trendingPosts = <PostModel>[].obs;
  final RxList<UserModel> popularUsers = <UserModel>[].obs;
  final RxList<String> trendingTags = <String>[].obs;

  final List<String> categories = [
    'Todos',
    'Trabalho',
    'Festa',
    'Casual',
    'Encontro',
    'Academia',
    'Viagem',
    'Outros'
  ];

  @override
  void onInit() {
    super.onInit();
    loadExploreContent();
  }

  Future<void> loadExploreContent() async {
    await Future.wait([
      loadTrendingStories(),
      loadTrendingPosts(),
      loadPopularUsers(),
      loadTrendingTags(),
    ]);
  }

  Future<void> loadTrendingStories() async {
    try {
      isLoadingStories.value = true;
      final stories = await _storyRepository.getActiveStories(limit: 10);

      // Ordenar por número de visualizações (stories mais visualizados primeiro)
      stories.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));

      trendingStories.assignAll(stories.take(5).toList());
    } catch (e) {
      print('Erro ao carregar stories em destaque: $e');
    } finally {
      isLoadingStories.value = false;
    }
  }

  Future<void> loadTrendingPosts() async {
    try {
      isLoadingTrending.value = true;
      final posts = await _postRepository.getTrendingPosts(limit: 20);
      trendingPosts.assignAll(posts);
    } catch (e) {
      print('Erro ao carregar posts em alta: $e');
    } finally {
      isLoadingTrending.value = false;
    }
  }

  Future<void> loadPopularUsers() async {
    try {
      isLoadingUsers.value = true;
      final users = await _userRepository.getTopUsers(limit: 10);
      popularUsers.assignAll(users);
    } catch (e) {
      print('Erro ao carregar usuários populares: $e');
    } finally {
      isLoadingUsers.value = false;
    }
  }

  Future<void> loadTrendingTags() async {
    try {
      // Implementar lógica para buscar tags em alta
      // Por enquanto, usar tags fixas
      final tags = [
        'moda',
        'look',
        'estilo',
        'tendencia',
        'outfit',
        'fashion',
        'casual',
        'elegante',
        'trabalho',
        'festa'
      ];
      trendingTags.assignAll(tags);
    } catch (e) {
      print('Erro ao carregar tags em alta: $e');
    }
  }

  Future<void> refreshExploreContent() async {
    isLoading.value = true;
    await loadExploreContent();
    isLoading.value = false;
  }

  void viewStory(StoryModel story) {
    // Implementar visualização de story individual
    // Por enquanto, navegar para a lista de stories
    Get.toNamed(AppRoutes.STORIES);
  }

  void viewAllStories() {
    Get.toNamed(AppRoutes.STORIES);
  }

  void viewPost(PostModel post) {
    // Implementar visualização de post individual
    // Por enquanto, apenas mostrar snackbar
    Get.snackbar('Info', 'Visualizando post: ${post.description}');
  }

  void viewAllTrendingPosts() {
    // Implementar navegação para posts em alta
    Get.snackbar('Info', 'Visualizar todos os posts em alta');
  }

  void viewUserProfile(String userId) {
    Get.toNamed('/user-profile/$userId');
  }

  void viewAllPopularUsers() {
    // Implementar navegação para usuários populares
    Get.snackbar('Info', 'Visualizar todos os usuários populares');
  }

  void searchByTag(String tag) {
    // Implementar busca por tag
    Get.snackbar('Info', 'Buscar por tag: #$tag');
  }

  void searchByCategory(String category) {
    // Implementar busca por categoria
    Get.snackbar('Info', 'Buscar por categoria: $category');
  }

  void goToCreateStory() {
    Get.toNamed(AppRoutes.CREATE_STORY);
  }

  void goToCreatePost() {
    Get.toNamed(AppRoutes.CREATE_POST);
  }

  // Função para filtrar posts por categoria
  Future<List<PostModel>> getPostsByCategory(String category) async {
    try {
      if (category == 'Todos') {
        return await _postRepository.getAllPosts(limit: 20);
      } else {
        final occasion = _getOccasionFromCategory(category);
        if (occasion != null) {
          return await _postRepository.getPostsByOccasion(occasion, limit: 20);
        }
      }
      return [];
    } catch (e) {
      print('Erro ao buscar posts por categoria: $e');
      return [];
    }
  }

  PostOccasion? _getOccasionFromCategory(String category) {
    switch (category) {
      case 'Trabalho':
        return PostOccasion.trabalho;
      case 'Festa':
        return PostOccasion.festa;
      case 'Casual':
        return PostOccasion.casual;
      case 'Encontro':
        return PostOccasion.encontro;
      case 'Academia':
        return PostOccasion.academia;
      case 'Viagem':
        return PostOccasion.viagem;
      default:
        return null;
    }
  }
}
