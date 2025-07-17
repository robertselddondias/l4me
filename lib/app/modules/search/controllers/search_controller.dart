import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:look4me/app/data/models/user_model.dart';
import 'package:look4me/app/data/repositories/user_repository.dart';
import 'package:look4me/app/data/services/firebase_service.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'dart:async';
import 'package:look4me/app/modules/home/controllers/home_controller.dart'; // NEW

class SearchL4MController extends GetxController {
  final UserRepository _userRepository = UserRepository();
  late final HomeController _homeController; // NEW: To access followingUsers

  // Estados reativas
  final RxBool isLoading = false.obs;
  final RxBool isLoadingPopular = false.obs;
  final RxString searchQuery = ''.obs;
  final RxList<UserModel> searchResults = <UserModel>[].obs;
  final RxList<UserModel> recentSearches = <UserModel>[].obs;
  final RxList<UserModel> popularUsers = <UserModel>[].obs;

  // Controlador de texto
  final TextEditingController searchController = TextEditingController();

  // Timer para debounce
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  @override
  void onInit() {
    super.onInit();
    _homeController = Get.find<HomeController>(); // Initialize HomeController
    _initializeData();
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  /// Inicializa dados necessários
  Future<void> _initializeData() async {
    await Future.wait([
      loadRecentSearches(),
      loadPopularUsers(),
    ]);
  }

  /// Busca usuários com debounce
  Future<void> searchUsers(String query) async {
    searchQuery.value = query.trim();

    // Cancelar busca anterior
    _debounceTimer?.cancel();

    // Limpar resultados se query vazia
    if (searchQuery.value.isEmpty) {
      searchResults.clear();
      return;
    }

    // Não buscar com menos de 2 caracteres
    if (searchQuery.value.length < 2) {
      searchResults.clear();
      return;
    }

    // Implementar debounce para evitar muitas requisições
    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch(searchQuery.value);
    });
  }

  /// Executa a busca real
  Future<void> _performSearch(String query) async {
    try {
      isLoading.value = true;

      final users = await _userRepository.searchUsers(query);

      // Filtrar o usuário atual dos resultados
      final currentUser = FirebaseService.currentUser;
      if (currentUser != null) {
        users.removeWhere((user) => user.id == currentUser.uid);
      }

      // Ordenar por relevância (nome que começa com a busca primeiro)
      users.sort((a, b) {
        final aStartsWith = a.name.toLowerCase().startsWith(query.toLowerCase());
        final bStartsWith = b.name.toLowerCase().startsWith(query.toLowerCase());

        if (aStartsWith && !bStartsWith) return -1;
        if (!aStartsWith && bStartsWith) return 1;

        // Se ambos ou nenhum começam com a query, ordenar por seguidores
        return b.followersCount.compareTo(a.followersCount);
      });

      searchResults.assignAll(users);
    } catch (e) {
      _showError('Erro ao buscar usuários', e.toString());
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Visualiza perfil do usuário
  void viewUserProfile(String userId) {
    // Encontrar usuário nas listas
    final user = _findUserById(userId);

    if (user != null) {
      _addToRecentSearches(user);
    }

    // Navegar para o perfil
    Get.toNamed('/user-profile/$userId', arguments: {'userId': userId});
  }

  /// Encontra usuário por ID
  UserModel? _findUserById(String userId) {
    return searchResults.firstWhereOrNull((u) => u.id == userId) ??
        recentSearches.firstWhereOrNull((u) => u.id == userId) ??
        popularUsers.firstWhereOrNull((u) => u.id == userId);
  }

  /// Adiciona usuário às buscas recentes
  void _addToRecentSearches(UserModel user) {
    // Remover se já existe
    recentSearches.removeWhere((u) => u.id == user.id);

    // Adicionar no início
    recentSearches.insert(0, user);

    // Manter apenas os últimos 10
    if (recentSearches.length > 10) {
      recentSearches.removeLast();
    }

    _saveRecentSearches();
  }

  /// Remove usuário das buscas recentes
  void removeFromRecentSearches(String userId) {
    recentSearches.removeWhere((user) => user.id == userId);
    _saveRecentSearches();
  }

  /// Limpa todas as buscas recentes
  void clearRecentSearches() {
    recentSearches.clear();
    _saveRecentSearches();

    _showSuccess('Limpo!', 'Histórico de buscas removido');
  }

  /// Carrega buscas recentes (implementação futura com storage local)
  Future<void> loadRecentSearches() async {
    try {
      // TODO: Implementar carregamento do SharedPreferences
      // Por enquanto, manter lista vazia
      recentSearches.clear();
    } catch (e) {
      print('Erro ao carregar buscas recentes: $e');
    }
  }

  /// Salva buscas recentes (implementação futura com storage local)
  Future<void> _saveRecentSearches() async {
    try {
      // TODO: Implementar salvamento no SharedPreferences
      // Por enquanto, apenas manter em memória
    } catch (e) {
      print('Erro ao salvar buscas recentes: $e');
    }
  }

  /// Limpa busca atual
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
    _debounceTimer?.cancel();
  }

  /// Atualiza busca atual
  Future<void> refreshSearch() async {
    if (searchQuery.value.isNotEmpty) {
      await _performSearch(searchQuery.value);
    }
  }

  /// Carrega usuários populares
  Future<void> loadPopularUsers() async {
    try {
      isLoadingPopular.value = true;

      final users = await _userRepository.getTopUsers(limit: 15);

      // Filtrar usuário atual
      final currentUser = FirebaseService.currentUser;
      if (currentUser != null) {
        users.removeWhere((user) => user.id == currentUser.uid);
      }

      popularUsers.assignAll(users);
    } catch (e) {
      print('Erro ao buscar usuários populares: $e');
    } finally {
      isLoadingPopular.value = false;
    }
  }

  /// Busca usuários em destaque (para compatibilidade)
  Future<List<UserModel>> getPopularUsers({int limit = 10}) async {
    try {
      final users = await _userRepository.getTopUsers(limit: limit);

      final currentUser = FirebaseService.currentUser;
      if (currentUser != null) {
        users.removeWhere((user) => user.id == currentUser.uid);
      }

      return users;
    } catch (e) {
      print('Erro ao buscar usuários populares: $e');
      return [];
    }
  }

  // UPDATED: Seguir/deixar de seguir usuário (using HomeController)
  Future<void> toggleFollowUser(String userId) async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) {
        _showError('Erro', 'Usuário não autenticado');
        return;
      }

      // Use HomeController's toggleFollowUser to centralize logic
      await _homeController.toggleFollowUser(userId);

      // Refresh data in search results to reflect follow status immediately
      // This will ensure the button state updates.
      final userIndexInResults = searchResults.indexWhere((user) => user.id == userId);
      if (userIndexInResults != -1) {
        // Option 1: Re-fetch the user to get updated counts (more reliable)
        final updatedUser = await _userRepository.getUserById(userId);
        if (updatedUser != null) {
          searchResults[userIndexInResults] = updatedUser;
        }
        // Option 2: Manually update followersCount locally if you prefer
        // This is less robust as it won't reflect other changes.
        // searchResults[userIndexInResults] = searchResults[userIndexInResults].copyWith(
        //   followersCount: searchResults[userIndexInResults].followersCount + (_homeController.isFollowingUser(userId) ? 1 : -1),
        // );
      }

      final userIndexInPopular = popularUsers.indexWhere((user) => user.id == userId);
      if (userIndexInPopular != -1) {
        final updatedUser = await _userRepository.getUserById(userId);
        if (updatedUser != null) {
          popularUsers[userIndexInPopular] = updatedUser;
        }
      }

      update(); // Trigger UI update for this controller's observables
    } catch (e) {
      _showError('Erro ao seguir usuário', e.toString());
    }
  }

  // NEW: Check if user is followed by the current user (delegated to HomeController)
  bool isFollowingUser(String userId) {
    return _homeController.isFollowingUser(userId);
  }

  /// Atualiza todos os dados
  Future<void> refreshAllData() async {
    await Future.wait([
      loadPopularUsers(),
      if (searchQuery.value.isNotEmpty) refreshSearch(),
    ]);
  }

  /// Filtra resultados por critério
  void filterResults(String criteria) {
    if (searchResults.isEmpty) return;

    final List<UserModel> filtered = List.from(searchResults);

    switch (criteria.toLowerCase()) {
      case 'seguidores':
        filtered.sort((a, b) => b.followersCount.compareTo(a.followersCount));
        break;
      case 'posts':
        filtered.sort((a, b) => b.postsCount.compareTo(a.postsCount));
        break;
      case 'verificados':
        filtered.retainWhere((user) => user.isVerified);
        break;
      case 'nome':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    searchResults.assignAll(filtered);
  }

  // Getters utilitários
  bool get hasRecentSearches => recentSearches.isNotEmpty;
  bool get hasSearchResults => searchResults.isNotEmpty;
  bool get isSearching => searchQuery.value.isNotEmpty;
  bool get hasPopularUsers => popularUsers.isNotEmpty;
  int get totalResults => searchResults.length;

  /// Exibe mensagem de erro
  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Exibe mensagem de sucesso
  void _showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Exibe mensagem informativa
  void _showInfo(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
    );
  }
}
