import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class FirebaseService extends GetxService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;

  // Getter estático para currentUser
  static User? get currentUser => auth.currentUser;

  // Getter estático para verificar autenticação
  static bool get isAuthenticated => currentUser != null;

  // Stream estático para mudanças de autenticação
  static Stream<User?> get authStateChanges => auth.authStateChanges();

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await _requestNotificationPermissions();
    _configureFirebaseMessaging();
  }

  Future<void> _requestNotificationPermissions() async {
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  void _configureFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensagem recebida: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App aberto através da notificação: ${message.notification?.title}');
    });
  }

  Future<String?> getFCMToken() async {
    try {
      return await messaging.getToken();
    } catch (e) {
      print('Erro ao obter FCM token: $e');
      return null;
    }
  }

  // Métodos de instância para compatibilidade
  Stream<User?> get authStateChangesInstance => authStateChanges;
  User? get currentUserInstance => currentUser;
  bool get isAuthenticatedInstance => isAuthenticated;

  CollectionReference get usersCollection => firestore.collection('users');
  CollectionReference get postsCollection => firestore.collection('posts');
  CollectionReference get votesCollection => firestore.collection('votes');
  CollectionReference get storiesCollection => firestore.collection('stories');
  CollectionReference get notificationsCollection => firestore.collection('notifications');

  Reference storageRef(String path) => storage.ref().child(path);
}
