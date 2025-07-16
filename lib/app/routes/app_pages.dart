// lib/app/routes/app_pages.dart
import 'package:get/get.dart';

// Importações de controllers e views necessárias
import 'package:look4me/app/modules/auth/controllers/auth_controller.dart';
import 'package:look4me/app/modules/auth/views/login_view.dart';
import 'package:look4me/app/modules/auth/views/register_view.dart';
import 'package:look4me/app/modules/auth/views/phone_auth_view.dart';

import 'package:look4me/app/modules/home/controllers/home_controller.dart';
import 'package:look4me/app/modules/home/views/home_view.dart';

import 'package:look4me/app/modules/profile/controllers/profile_controller.dart';
import 'package:look4me/app/modules/profile/views/profile_view.dart';
import 'package:look4me/app/modules/profile/views/edit_profile_view.dart';
import 'package:look4me/app/modules/profile/views/settings_view.dart'; // Importe a nova tela de configurações

import 'package:look4me/app/modules/create_post/controllers/create_post_controller.dart';
import 'package:look4me/app/modules/create_post/views/create_post_view.dart';

import 'package:look4me/app/modules/stories/controllers/stories_controller.dart';
import 'package:look4me/app/modules/stories/views/stories_view.dart';
import 'package:look4me/app/modules/stories/views/create_story_view.dart';

import 'package:look4me/app/modules/search/controllers/search_controller.dart'; // Nome do arquivo é search_controller.dart
import 'package:look4me/app/modules/search/views/search_users_view.dart';

import 'package:look4me/app/modules/explore/controllers/explore_controller.dart';
import 'package:look4me/app/modules/explore/views/explore_view.dart';

import 'package:look4me/app/modules/navigation/controllers/navigation_controller.dart';
import 'package:look4me/app/modules/navigation/views/main_navigation.dart';
import 'package:look4me/app/routes/app_routes.dart';

import 'package:look4me/app/shared/views/splash_view.dart';


class AppPages {
  AppPages._();

  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(), // Adicionado const
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(), // Adicionado const
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterView(), // Adicionado const
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.PHONE_AUTH,
      page: () => const PhoneAuthView(), // Adicionado const
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      // Correção: Use AppRoutes.MAIN_NAVIGATION conforme definido em app_routes.dart
      name: AppRoutes.MAIN_NAVIGATION,
      page: () => const MainNavigation(), // Adicionado const
      bindings: [
        BindingsBuilder(() {
          Get.lazyPut<NavigationController>(() => NavigationController());
          Get.lazyPut<HomeController>(() => HomeController());
          Get.lazyPut<ProfileController>(() => ProfileController());
          Get.lazyPut<StoriesController>(() => StoriesController());
          Get.lazyPut<SearchL4MController>(() => SearchL4MController());
          Get.lazyPut<ExploreController>(() => ExploreController());
          // AuthController não precisa ser lazyPut aqui novamente se já está nas telas de auth
        }),
      ],
    ),
    // Para Home e Profile que já estão sendo carregados na MainNavigation,
    // os bindings aqui podem ser removidos para evitar duplicação ou serem mais específicos
    // se essas rotas pudessem ser acessadas diretamente sem a MainNavigation.
    // Para um MVP, manter um lazyPut na MAIN_NAVIGATION já é suficiente para esses.
    // Se precisar de acesso direto, considere manter, mas o lazyPut na main_navigation
    // já garante que o controller estará disponível quando a página for exibida.
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(), // Adicionado const
      // binding: BindingsBuilder(() { Get.lazyPut<HomeController>(() => HomeController()); }), // Removido ou ajustado
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileView(), // Adicionado const
      // binding: BindingsBuilder(() { Get.lazyPut<ProfileController>(() => ProfileController()); }), // Removido ou ajustado
    ),
    GetPage(
      name: AppRoutes.EDIT_PROFILE,
      page: () => const EditProfileView(), // Adicionado const
      // O ProfileController já está no contexto do Getx via MainNavigation, então sem binding aqui
    ),
    GetPage(
      name: AppRoutes.CREATE_POST,
      page: () => const CreatePostView(), // Adicionado const
      binding: BindingsBuilder(() {
        Get.lazyPut<CreatePostController>(() => CreatePostController());
      }),
    ),
    GetPage(
      name: AppRoutes.STORIES,
      page: () => const StoriesView(), // Adicionado const
      binding: BindingsBuilder(() {
        Get.lazyPut<StoriesController>(() => StoriesController());
      }),
    ),
    GetPage(
      name: AppRoutes.CREATE_STORY,
      page: () => const CreateStoryView(), // Adicionado const
      binding: BindingsBuilder(() {
        Get.lazyPut<StoriesController>(() => StoriesController());
      }),
    ),
    // Rotas adicionais para busca e exploração (usando AppRoutes agora)
    GetPage(
      name: AppRoutes.SEARCH_USERS, // Correção: Usando AppRoutes.SEARCH_USERS
      page: () => const SearchUsersView(), // Adicionado const
      binding: BindingsBuilder(() {
        Get.lazyPut<SearchL4MController>(() => SearchL4MController());
      }),
    ),
    GetPage(
      name: AppRoutes.EXPLORE, // Correção: Usando AppRoutes.EXPLORE
      page: () => const ExploreView(), // Adicionado const
      binding: BindingsBuilder(() {
        Get.lazyPut<ExploreController>(() => ExploreController());
      }),
    ),
    GetPage(
      name: AppRoutes.SETTINGS, // Nova rota para a tela de configurações
      page: () => const SettingsView(), // Adicionado const
      // O ProfileController já está no contexto do Getx via MainNavigation, então sem binding aqui
    ),
  ];
}
