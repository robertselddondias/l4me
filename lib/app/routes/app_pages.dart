import 'package:get/get.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/phone_auth_view.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/home/views/home_view.dart';
import '../modules/profile/controllers/profile_controller.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/edit_profile_view.dart';
import '../modules/create_post/controllers/create_post_controller.dart';
import '../modules/create_post/views/create_post_view.dart';
import '../modules/stories/controllers/stories_controller.dart';
import '../modules/stories/views/stories_view.dart';
import '../modules/stories/views/create_story_view.dart';
import '../modules/navigation/controllers/navigation_controller.dart';
import '../modules/navigation/views/main_navigation.dart';
import '../shared/views/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => SplashView(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => RegisterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.PHONE_AUTH,
      page: () => PhoneAuthView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.MAIN,
      page: () => MainNavigation(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NavigationController>(() => NavigationController());
        Get.lazyPut<HomeController>(() => HomeController());
        Get.lazyPut<ProfileController>(() => ProfileController());
        Get.lazyPut<StoriesController>(() => StoriesController());
      }),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => ProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.EDIT_PROFILE,
      page: () => EditProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.CREATE_POST,
      page: () => CreatePostView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CreatePostController>(() => CreatePostController());
      }),
    ),
    GetPage(
      name: AppRoutes.STORIES,
      page: () => StoriesView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<StoriesController>(() => StoriesController());
      }),
    ),
    GetPage(
      name: AppRoutes.CREATE_STORY,
      page: () => CreateStoryView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<StoriesController>(() => StoriesController());
      }),
    ),
  ];
}
