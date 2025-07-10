import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:look4me/app/modules/create_post/controllers/create_post_controller.dart';
import 'package:look4me/app/modules/explore/controllers/explore_controller.dart';
import 'package:look4me/app/modules/home/controllers/home_controller.dart';
import 'package:look4me/app/modules/profile/controllers/profile_controller.dart';
import 'package:look4me/app/modules/search/controllers/search_controller.dart';
import 'package:look4me/app/modules/stories/controllers/stories_controller.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

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
    if (index != currentIndex.value) {
      // Garantir que o controller da página está registrado antes de navegar
      _ensureControllerForPage(index);
      currentIndex.value = index;
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

  // Métodos de conveniência para navegação rápida
  void goToHomeAndRefresh() {
    changePage(0);
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refreshPosts();
    }
  }

  void goToSearchWithQuery(String query) {
    changePage(1);
    if (Get.isRegistered<SearchL4MController>()) {
      final searchController = Get.find<SearchL4MController>();
      searchController.searchController.text = query;
      searchController.searchUsers(query);
    }
  }

  void goToExploreAndRefresh() {
    changePage(3);
    if (Get.isRegistered<ExploreController>()) {
      Get.find<ExploreController>().refreshExploreContent();
    }
  }

  void goToProfileAndRefresh() {
    changePage(4);
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().refreshProfile();
    }
  }

  // Método para obter o título da página atual
  String getCurrentPageTitle() {
    switch (currentIndex.value) {
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

  // Método para verificar se uma página específica está ativa
  bool isPageActive(int index) {
    return currentIndex.value == index;
  }

  // Método para obter o ícone da página atual
  IconData getCurrentPageIcon() {
    switch (currentIndex.value) {
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
}
