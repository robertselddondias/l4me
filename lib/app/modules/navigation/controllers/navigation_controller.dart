import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../stories/controllers/stories_controller.dart';
import '../../create_post/controllers/create_post_controller.dart';
import '../../search/controllers/search_controller.dart';
import '../../explore/controllers/explore_controller.dart';

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
    if (!Get.isRegistered<SearchController>()) {
      Get.lazyPut<SearchController>(() => SearchController(), fenix: true);
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
        if (!Get.isRegistered<SearchController>()) {
          Get.lazyPut<SearchController>(() => SearchController(), fenix: true);
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
}
