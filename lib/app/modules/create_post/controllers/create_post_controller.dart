import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:look4me/app/modules/navigation/controllers/navigation_controller.dart';
import '../../../data/models/post_model.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/firebase_service.dart';
import '../../../data/services/storage_service.dart';

class CreatePostController extends GetxController {
  final PostRepository _postRepository = PostRepository();
  final UserRepository _userRepository = UserRepository();
  final StorageService _storageService = StorageService();

  final RxBool isLoading = false.obs;
  final RxString image1Path = ''.obs;
  final RxString image2Path = ''.obs;
  final Rx<PostOccasion> selectedOccasion = PostOccasion.casual.obs;
  final RxList<String> selectedTags = <String>[].obs;

  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ImagePicker _imagePicker = ImagePicker();

  final List<PostOccasion> occasions = PostOccasion.values;
  final List<String> availableTags = [
    'verão',
    'inverno',
    'casual',
    'elegante',
    'colorido',
    'neutro',
    'confortável',
    'fashion',
    'vintage',
    'moderno',
    'básico',
    'statement',
  ];

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> pickImage(int option) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        if (option == 1) {
          image1Path.value = pickedFile.path;
        } else {
          image2Path.value = pickedFile.path;
        }
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao selecionar imagem: $e');
    }
  }

  Future<void> takePhoto(int option) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        if (option == 1) {
          image1Path.value = pickedFile.path;
        } else {
          image2Path.value = pickedFile.path;
        }
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao tirar foto: $e');
    }
  }

  void selectOccasion(PostOccasion occasion) {
    selectedOccasion.value = occasion;
  }

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      if (selectedTags.length < 5) {
        selectedTags.add(tag);
      } else {
        Get.snackbar('Aviso', 'Máximo de 5 tags permitidas');
      }
    }
  }

  void removeImage(int option) {
    if (option == 1) {
      image1Path.value = '';
    } else {
      image2Path.value = '';
    }
  }

  bool get canCreatePost {
    return image1Path.value.isNotEmpty &&
        image2Path.value.isNotEmpty &&
        descriptionController.text.trim().isNotEmpty;
  }

  Future<void> createPost() async {
    if (!formKey.currentState!.validate()) return;
    if (!canCreatePost) {
      Get.snackbar('Erro', 'Preencha todos os campos obrigatórios');
      return;
    }

    try {
      isLoading.value = true;

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

      // Criar post temporário para gerar ID
      final tempPost = PostModel(
        id: '',
        authorId: currentUser.uid,
        authorName: user.name,
        authorProfileImage: user.profileImage,
        description: descriptionController.text.trim(),
        imageOption1: '',
        imageOption2: '',
        occasion: selectedOccasion.value,
        tags: selectedTags.toList(),
        createdAt: DateTime.now(),
      );

      // Criar post no Firestore para obter ID
      final postId = await _postRepository.createPost(tempPost);

      // Upload das imagens
      final imageUrl1 = await _storageService.uploadPostImage(
        userId: currentUser.uid,
        postId: postId,
        imagePath: image1Path.value,
        optionNumber: 1,
      );

      final imageUrl2 = await _storageService.uploadPostImage(
        userId: currentUser.uid,
        postId: postId,
        imagePath: image2Path.value,
        optionNumber: 2,
      );

      // Atualizar post com URLs das imagens
      final finalPost = tempPost.copyWith(
        id: postId,
        imageOption1: imageUrl1,
        imageOption2: imageUrl2,
      );

      await _postRepository.updatePost(finalPost);

      // Incrementar contador de posts do usuário
      await _userRepository.incrementPostsCount(currentUser.uid);

      _clearForm();

      Get.back();
      Get.snackbar(
        'Sucesso',
        'Post criado com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navegar para a aba Home
      Get.find<NavigationController>().goToHome();

    } catch (e) {
      Get.snackbar('Erro', 'Erro ao criar post: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _clearForm() {
    image1Path.value = '';
    image2Path.value = '';
    descriptionController.clear();
    selectedOccasion.value = PostOccasion.casual;
    selectedTags.clear();
  }

  void showImageSourceDialog(int option) {
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
              'Selecionar Imagem',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Get.back();
                pickImage(option);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                Get.back();
                takePhoto(option);
              },
            ),
            if ((option == 1 && image1Path.value.isNotEmpty) ||
                (option == 2 && image2Path.value.isNotEmpty))
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remover', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.back();
                  removeImage(option);
                },
              ),
          ],
        ),
      ),
    );
  }
}
