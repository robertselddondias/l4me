import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:look4me/app/data/models/story_model.dart';
import 'package:look4me/app/data/repositories/story_repository.dart';
import 'package:look4me/app/data/repositories/user_repository.dart';
import 'package:look4me/app/data/services/firebase_service.dart';
import 'package:look4me/app/data/services/storage_service.dart';
import 'package:look4me/app/routes/app_routes.dart';

class StoriesController extends GetxController {
  final StoryRepository _storyRepository = StoryRepository();
  final UserRepository _userRepository = UserRepository();
  final StorageService _storageService = StorageService();

  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxList<StoryModel> stories = <StoryModel>[].obs;
  final RxString selectedImagePath = ''.obs;
  final Rx<StoryType> selectedType = StoryType.tip.obs;

  final TextEditingController contentController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final GlobalKey<FormState> createFormKey = GlobalKey<FormState>();

  final ImagePicker _imagePicker = ImagePicker();

  final List<StoryType> storyTypes = StoryType.values;

  @override
  void onInit() {
    super.onInit();
    loadStories();
  }

  @override
  void onClose() {
    contentController.dispose();
    linkController.dispose();
    super.onClose();
  }

  Future<void> loadStories() async {
    try {
      isLoading.value = true;
      final fetchedStories = await _storyRepository.getActiveStories();
      stories.assignAll(fetchedStories);
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao carregar stories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshStories() async {
    await loadStories();
  }

  void goToCreateStory() {
    Get.toNamed(AppRoutes.CREATE_STORY);
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1080,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        selectedImagePath.value = pickedFile.path;
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao selecionar imagem: $e');
    }
  }

  Future<void> takePhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1080,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        selectedImagePath.value = pickedFile.path;
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao tirar foto: $e');
    }
  }

  void removeImage() {
    selectedImagePath.value = '';
  }

  void selectStoryType(StoryType type) {
    selectedType.value = type;
  }

  bool get canCreateStory {
    return contentController.text.trim().isNotEmpty;
  }

  Future<void> createStory() async {
    if (!createFormKey.currentState!.validate()) return;
    if (!canCreateStory) {
      Get.snackbar('Erro', 'Conteúdo é obrigatório');
      return;
    }

    try {
      isCreating.value = true;

      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) {
        Get.snackbar('Erro', 'Usuário não autenticado');
        return;
      }

      final user = await _userRepository.getUserById(currentUser.uid);
      if (user == null) {
        Get.snackbar('Erro', 'Dados do usuário não encontrados');
        return;
      }

      String? imageUrl;
      if (selectedImagePath.value.isNotEmpty) {
        final storyId = DateTime.now().millisecondsSinceEpoch.toString();
        imageUrl = await _storageService.uploadStoryImage(
          userId: currentUser.uid,
          storyId: storyId,
          imagePath: selectedImagePath.value,
        );
      }

      final story = StoryModel(
        id: '',
        authorId: currentUser.uid,
        authorName: user.name,
        authorProfileImage: user.profileImage,
        content: contentController.text.trim(),
        imageUrl: imageUrl,
        type: selectedType.value,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        linkUrl: linkController.text.trim().isNotEmpty
            ? linkController.text.trim()
            : null,
      );

      await _storyRepository.createStory(story);

      _clearCreateForm();

      Get.back();
      Get.snackbar(
        'Sucesso',
        'Story criado com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await loadStories();

    } catch (e) {
      Get.snackbar('Erro', 'Erro ao criar story: $e');
    } finally {
      isCreating.value = false;
    }
  }

  void _clearCreateForm() {
    selectedImagePath.value = '';
    contentController.clear();
    linkController.clear();
    selectedType.value = StoryType.tip;
  }

  Future<void> markAsViewed(String storyId) async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) return;

      await _storyRepository.markAsViewed(storyId, currentUser.uid);

      final storyIndex = stories.indexWhere((s) => s.id == storyId);
      if (storyIndex != -1) {
        final updatedStory = stories[storyIndex].copyWith(
          viewedBy: [...stories[storyIndex].viewedBy, currentUser.uid],
        );
        stories[storyIndex] = updatedStory;
      }
    } catch (e) {
      print('Erro ao marcar story como visualizado: $e');
    }
  }

  void showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Adicionar Imagem',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Get.back();
                pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                Get.back();
                takePhoto();
              },
            ),
            if (selectedImagePath.value.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remover', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.back();
                  removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  String getStoryTypeDisplayName(StoryType type) {
    switch (type) {
      case StoryType.tip:
        return 'Dica';
      case StoryType.outfit:
        return 'Look';
      case StoryType.accessory:
        return 'Acessório';
      case StoryType.trend:
        return 'Tendência';
      case StoryType.discount:
        return 'Desconto';
      case StoryType.tutorial:
        return 'Tutorial';
    }
  }

  IconData getStoryTypeIcon(StoryType type) {
    switch (type) {
      case StoryType.tip:
        return Icons.lightbulb_outline;
      case StoryType.outfit:
        return Icons.checkroom_outlined;
      case StoryType.accessory:
        return Icons.watch_outlined;
      case StoryType.trend:
        return Icons.trending_up_outlined;
      case StoryType.discount:
        return Icons.local_offer_outlined;
      case StoryType.tutorial:
        return Icons.play_circle_outline;
    }
  }
}
