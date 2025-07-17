import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:look4me/app/modules/create_post/controllers/create_post_controller.dart';
import 'package:look4me/app/modules/explore/controllers/explore_controller.dart';
import 'package:look4me/app/modules/home/controllers/home_controller.dart';
import 'package:look4me/app/modules/profile/controllers/profile_controller.dart';
import 'package:look4me/app/modules/search/controllers/search_controller.dart';
import 'package:look4me/app/modules/stories/controllers/stories_controller.dart';

class NavigationController extends GetxController {
  // Variável observável para o índice atual
  final RxInt _currentIndex = 0.obs;
  int _previousIndex = 0; // NOVO: Para rastrear página anterior

  // Getter público para acessar o índice atual
  int get currentIndex => _currentIndex.value;
  RxInt get currentIndexRx => _currentIndex;

  @override
  void onInit() {
    super.onInit();
    _ensureControllersAreRegistered();
  }

  void _ensureControllersAreRegistered() {
    // Garantir que todos os controllers estão registrados
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    }
    if (!Get.isRegistered<SearchL4MController>()) {
      Get.lazyPut<SearchL4MController>(() => SearchL4MController(), fenix: true);
    }
    if (!Get.isRegistered<CreatePostController>()) {
      Get.lazyPut<CreatePostController>(() => CreatePostController(), fenix: true);
    }
    if (!Get.isRegistered<ExploreController>()) {
      Get.lazyPut<ExploreController>(() => ExploreController(), fenix: true);
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    }
    if (!Get.isRegistered<StoriesController>()) {
      Get.lazyPut<StoriesController>(() => StoriesController(), fenix: true);
    }
  }

  void changePage(int index) {
    if (index != _currentIndex.value && index >= 0 && index <= 4) {
      // CORREÇÃO: Salvar página anterior
      _previousIndex = _currentIndex.value;

      // Garantir que o controller da página está registrado antes de navegar
      _ensureControllerForPage(index);

      // CORREÇÃO: Se voltando do CreatePost (index 2) para Home (index 0), refresh completo
      if (_previousIndex == 2 && index == 0) {
        _handleReturnFromCreatePost();
      }

      _currentIndex.value = index;
    }
  }

  // NOVO: Método para lidar com retorno do CreatePost
  void _handleReturnFromCreatePost() {
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        // Usar o método de refresh completo
        homeController.refreshPostsComplete();
      }
    } catch (e) {
      print('Erro ao atualizar timeline após criar post: $e');
    }
  }

  void _ensureControllerForPage(int index) {
    switch (index) {
      case 0: // Home
        if (!Get.isRegistered<HomeController>()) {
          Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
        }
        break;
      case 1: // Search Users
        if (!Get.isRegistered<SearchL4MController>()) {
          Get.lazyPut<SearchL4MController>(() => SearchL4MController(), fenix: true);
        }
        break;
      case 2: // Create Post
        if (!Get.isRegistered<CreatePostController>()) {
          Get.lazyPut<CreatePostController>(() => CreatePostController(), fenix: true);
        }
        break;
      case 3: // Explore
        if (!Get.isRegistered<ExploreController>()) {
          Get.lazyPut<ExploreController>(() => ExploreController(), fenix: true);
        }
        break;
      case 4: // Profile
        if (!Get.isRegistered<ProfileController>()) {
          Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
        }
        break;
    }
  }

  // Métodos de navegação rápida
  void goToHome() {
    changePage(0);
  }

  void goToSearch() {
    changePage(1);
  }

  void goToCreatePost() {
    changePage(2);
  }

  void goToExplore() {
    changePage(3);
  }

  void goToProfile() {
    changePage(4);
  }

  // NOVO: Método específico para voltar à Home após criar post
  void goToHomeAfterCreatePost() {
    // Força refresh completo da timeline
    try {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().clearCache();
      }
    } catch (e) {
      print('Erro ao limpar cache: $e');
    }

    changePage(0);

    // Aguarda um frame e recarrega
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().refreshPostsComplete();
        }
      } catch (e) {
        print('Erro ao recarregar posts: $e');
      }
    });
  }

  // Métodos com ações adicionais
  void goToHomeAndRefresh() {
    changePage(0);
    try {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().refreshPostsComplete();
      }
    } catch (e) {
      print('Erro ao atualizar Home: $e');
    }
  }

  void goToSearchWithQuery(String query) {
    changePage(1);
    try {
      if (Get.isRegistered<SearchL4MController>()) {
        final searchController = Get.find<SearchL4MController>();
        searchController.searchController.text = query;
        searchController.searchUsers(query);
      }
    } catch (e) {
      print('Erro ao buscar: $e');
    }
  }

  void goToExploreAndRefresh() {
    changePage(3);
    try {
      if (Get.isRegistered<ExploreController>()) {
        Get.find<ExploreController>().refreshExploreContent();
      }
    } catch (e) {
      print('Erro ao atualizar Explore: $e');
    }
  }

  void goToProfileAndRefresh() {
    changePage(4);
    try {
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().refreshProfile();
      }
    } catch (e) {
      print('Erro ao atualizar Profile: $e');
    }
  }

  // Métodos utilitários
  String getCurrentPageTitle() {
    switch (_currentIndex.value) {
      case 0:
        return 'Início';
      case 1:
        return 'Buscar';
      case 2:
        return 'Criar Look';
      case 3:
        return 'Explorar';
      case 4:
        return 'Perfil';
      default:
        return 'Look4Me';
    }
  }

  bool isPageActive(int index) {
    return _currentIndex.value == index;
  }

  IconData getCurrentPageIcon() {
    switch (_currentIndex.value) {
      case 0:
        return Icons.home_rounded;
      case 1:
        return Icons.search_rounded;
      case 2:
        return Icons.add_rounded;
      case 3:
        return Icons.explore_rounded;
      case 4:
        return Icons.person_rounded;
      default:
        return Icons.home_rounded;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
