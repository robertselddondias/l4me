import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage({
    required String userId,
    required String imagePath,
  }) async {
    try {
      final file = File(imagePath);
      final fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imagePath)}';
      final ref = _storage.ref().child('profiles/$fileName');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  Future<String> uploadPostImage({
    required String userId,
    required String postId,
    required String imagePath,
    required int optionNumber,
  }) async {
    try {
      final file = File(imagePath);
      final fileName = '${postId}_option${optionNumber}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imagePath)}';
      final ref = _storage.ref().child('posts/$userId/$fileName');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  Future<String> uploadStoryImage({
    required String userId,
    required String storyId,
    required String imagePath,
  }) async {
    try {
      final file = File(imagePath);
      final fileName = '${storyId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imagePath)}';
      final ref = _storage.ref().child('stories/$userId/$fileName');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Erro ao deletar imagem: $e');
    }
  }

  Future<List<String>> uploadMultipleImages({
    required String userId,
    required String folder,
    required List<String> imagePaths,
  }) async {
    try {
      final List<String> downloadUrls = [];

      for (int i = 0; i < imagePaths.length; i++) {
        final file = File(imagePaths[i]);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i${path.extension(imagePaths[i])}';
        final ref = _storage.ref().child('$folder/$userId/$fileName');

        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        downloadUrls.add(downloadUrl);
      }

      return downloadUrls;
    } catch (e) {
      throw Exception('Erro ao fazer upload das imagens: $e');
    }
  }
}
