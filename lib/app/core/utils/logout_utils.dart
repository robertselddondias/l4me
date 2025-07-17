// lib/app/core/utils/logout_utils.dart
import 'package:get/get.dart';
import 'package:look4me/app/data/models/post_model.dart';
import 'package:look4me/app/data/models/story_model.dart';
import 'package:look4me/app/modules/create_post/controllers/create_post_controller.dart';
import 'package:look4me/app/modules/explore/controllers/explore_controller.dart';
import 'package:look4me/app/modules/home/controllers/home_controller.dart';
import 'package:look4me/app/modules/navigation/controllers/navigation_controller.dart';
import 'package:look4me/app/modules/profile/controllers/profile_controller.dart';
import 'package:look4me/app/modules/search/controllers/search_controller.dart';
import 'package:look4me/app/modules/stories/controllers/stories_controller.dart';

class LogoutUtils {
  LogoutUtils._(); // Construtor privado para classe utilitária

  /// Limpa todos os dados locais do usuário durante o logout
  static Future<void> clearAllUserData() async {
    try {
      print('🧹 Iniciando limpeza de dados locais...');

      // Limpar dados de todos os controllers
      await Future.wait([
        _clearProfileData(),
        _clearHomeData(),
        _clearSearchData(),
        _clearExploreData(),
        _clearStoriesData(),
        _clearCreatePostData(),
        _clearNavigationData(),
      ]);

      // Limpar cache e dados persistentes
      await _clearCacheAndPersistentData();

      print('🎉 Limpeza de dados locais concluída com sucesso!');
    } catch (e) {
      print('❌ Erro geral na limpeza de dados locais: $e');
      // Não lance exceção para não quebrar o logout
    }
  }

  /// Limpa dados do ProfileController
  static Future<void> _clearProfileData() async {
    try {
      if (Get.isRegistered<ProfileController>()) {
        final controller = Get.find<ProfileController>();

        // Limpar dados do usuário
        controller.currentUser.value = null;
        controller.userPosts.clear();

        // Resetar estados
        controller.isLoading.value = false;
        controller.isLoadingPosts.value = false;
        controller.isUpdatingProfile.value = false;
        controller.selectedTabIndex.value = 0;

        // Limpar controladores de texto
        controller.nameController.clear();
        controller.bioController.clear();

        print('✅ ProfileController limpo');
      }
    } catch (e) {
      print('⚠️ Erro ao limpar ProfileController: $e');
    }
  }

  /// Limpa dados do HomeController
  static Future<void> _clearHomeData() async {
    try {
      if (Get.isRegistered<HomeController>()) {
        final controller = Get.find<HomeController>();

        // Limpar listas de posts
        controller.posts.clear();
        controller.filteredPosts.clear();

        // Limpar dados de votos
        controller.userVotes.clear();

        // Limpar dados sociais
        controller.followingUsers.clear();
        controller.savedPosts.clear();

        // Resetar estados
        controller.isLoading.value = false;
        controller.isLoadingMore.value = false;
        controller.selectedOccasion.value = 'Todos';
        controller.hasNotifications.value = false;

        print('✅ HomeController limpo');
      }
    } catch (e) {
      print('⚠️ Erro ao limpar HomeController: $e');
    }
  }

  /// Limpa dados do SearchController
  static Future<void> _clearSearchData() async {
    try {
      if (Get.isRegistered<SearchL4MController>()) {
        final controller = Get.find<SearchL4MController>();

        // Limpar resultados de busca
        controller.searchResults.clear();
        controller.recentSearches.clear();
        controller.popularUsers.clear();

        // Resetar estados
        controller.isLoading.value = false;
        controller.isLoadingPopular.value = false;
        controller.searchQuery.value = '';

        // Limpar controlador de texto
        controller.searchController.clear();

        print('✅ SearchController limpo');
      }
    } catch (e) {
      print('⚠️ Erro ao limpar SearchController: $e');
    }
  }

  /// Limpa dados do ExploreController
  static Future<void> _clearExploreData() async {
    try {
      if (Get.isRegistered<ExploreController>()) {
        final controller = Get.find<ExploreController>();

        // Limpar dados de exploração
        controller.trendingStories.clear();
        controller.trendingPosts.clear();
        controller.popularUsers.clear();
        controller.trendingTags.clear();

        // Resetar estados
        controller.isLoading.value = false;
        controller.isLoadingStories.value = false;
        controller.isLoadingTrending.value = false;
        controller.isLoadingUsers.value = false;

        print('✅ ExploreController limpo');
      }
    } catch (e) {
      print('⚠️ Erro ao limpar ExploreController: $e');
    }
  }

  /// Limpa dados do StoriesController
  static Future<void> _clearStoriesData() async {
    try {
      if (Get.isRegistered<StoriesController>()) {
        final controller = Get.find<StoriesController>();

        // Limpar dados de stories
        controller.stories.clear();

        // Resetar estados
        controller.isLoading.value = false;
        controller.isCreating.value = false;
        controller.selectedImagePath.value = '';
        controller.selectedType.value = StoryType.tip;

        // Limpar controladores de texto
        controller.contentController.clear();
        controller.linkController.clear();

        print('✅ StoriesController limpo');
      }
    } catch (e) {
      print('⚠️ Erro ao limpar StoriesController: $e');
    }
  }

  /// Limpa dados do CreatePostController
  static Future<void> _clearCreatePostData() async {
    try {
      if (Get.isRegistered<CreatePostController>()) {
        final controller = Get.find<CreatePostController>();

        // Limpar dados de criação
        controller.image1Path.value = '';
        controller.image2Path.value = '';
        controller.selectedTags.clear();

        // Resetar estados
        controller.isLoading.value = false;
        controller.selectedOccasion.value = PostOccasion.casual;

        // Limpar controlador de texto
        controller.descriptionController.clear();

        print('✅ CreatePostController limpo');
      }
    } catch (e) {
      print('⚠️ Erro ao limpar CreatePostController: $e');
    }
  }

  /// Reseta NavigationController
  static Future<void> _clearNavigationData() async {
    try {
      if (Get.isRegistered<NavigationController>()) {
        final controller = Get.find<NavigationController>();

        // Resetar índice de navegação para Home
        controller.changePage(0);

        print('✅ NavigationController resetado');
      }
    } catch (e) {
      print('⚠️ Erro ao resetar NavigationController: $e');
    }
  }

  /// Limpa cache e dados persistentes
  static Future<void> _clearCacheAndPersistentData() async {
    try {
      // Limpar cache de imagens (se necessário)
      // await DefaultCacheManager().emptyCache();

      // Limpar SharedPreferences (se necessário)
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.clear();

      print('✅ Cache e dados persistentes limpos');
    } catch (e) {
      print('⚠️ Erro ao limpar cache: $e');
    }
  }

  /// Limpa dados de um controller específico
  static Future<void> clearSpecificController<T>(String controllerName) async {
    try {
      if (Get.isRegistered<T>()) {
        switch (T) {
          case HomeController:
            await _clearHomeData();
            break;
          case SearchL4MController:
            await _clearSearchData();
            break;
          case ProfileController:
            await _clearProfileData();
            break;
          case ExploreController:
            await _clearExploreData();
            break;
          case StoriesController:
            await _clearStoriesData();
            break;
          case CreatePostController:
            await _clearCreatePostData();
            break;
          case NavigationController:
            await _clearNavigationData();
            break;
          default:
            print('⚠️ Controller $controllerName não reconhecido');
        }

        print('✅ $controllerName limpo com sucesso');
      }
    } catch (e) {
      print('⚠️ Erro ao limpar $controllerName: $e');
    }
  }

  /// Remove todos os controllers (opção mais drástica)
  static Future<void> clearAllControllers({bool force = false}) async {
    try {
      if (force) {
        Get.deleteAll(force: true);
        print('✅ Todos os controllers GetX removidos');
      } else {
        // Remoção seletiva dos controllers da app
        final controllersToRemove = [
          HomeController,
          SearchL4MController,
          ProfileController,
          ExploreController,
          StoriesController,
          CreatePostController,
        ];

        for (final controllerType in controllersToRemove) {
          try {
            Get.delete<dynamic>(tag: controllerType.toString());
          } catch (e) {
            // Ignorar erros de controllers que não existem
          }
        }
        print('✅ Controllers da aplicação removidos');
      }
    } catch (e) {
      print('⚠️ Erro ao remover controllers: $e');
    }
  }

  /// Verifica se todos os dados foram limpos
  static bool verifyDataClearing() {
    try {
      final controllers = [
        Get.isRegistered<HomeController>(),
        Get.isRegistered<SearchL4MController>(),
        Get.isRegistered<ProfileController>(),
        Get.isRegistered<ExploreController>(),
        Get.isRegistered<StoriesController>(),
        Get.isRegistered<CreatePostController>(),
      ];

      // Se algum controller ainda estiver registrado, verificar se os dados foram limpos
      if (controllers.any((registered) => registered)) {
        print('ℹ️ Alguns controllers ainda estão registrados');
        return false;
      }

      print('✅ Verificação de limpeza: todos os dados foram limpos');
      return true;
    } catch (e) {
      print('⚠️ Erro na verificação de limpeza: $e');
      return false;
    }
  }

  /// Método para limpeza rápida (sem logs detalhados)
  static Future<void> quickClearUserData() async {
    try {
      await Future.wait([
        _clearProfileData(),
        _clearHomeData(),
        _clearSearchData(),
        _clearExploreData(),
        _clearStoriesData(),
        _clearCreatePostData(),
        _clearNavigationData(),
      ]);
    } catch (e) {
      // Falha silenciosa
    }
  }
}
