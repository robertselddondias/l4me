// lib/app/routes/app_routes.dart
abstract class AppRoutes {
  AppRoutes._();
  static const SPLASH = _Paths.SPLASH;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const PHONE_AUTH = _Paths.PHONE_AUTH;
  static const HOME = _Paths.HOME;
  static const EXPLORE = _Paths.EXPLORE;
  static const CREATE_POST = _Paths.CREATE_POST;
  static const PROFILE = _Paths.PROFILE;
  static const EDIT_PROFILE = _Paths.EDIT_PROFILE;
  static const STORIES = _Paths.STORIES;
  static const SEARCH_USERS = _Paths.SEARCH_USERS;
  static const MAIN_NAVIGATION = _Paths.MAIN_NAVIGATION;
  static const CREATE_STORY = _Paths.CREATE_STORY;
  static const SETTINGS = _Paths.SETTINGS; // Adicione esta linha
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const PHONE_AUTH = '/phone-auth';
  static const HOME = '/home';
  static const EXPLORE = '/explore';
  static const CREATE_POST = '/create-post';
  static const PROFILE = '/profile';
  static const EDIT_PROFILE = '/edit-profile';
  static const STORIES = '/stories';
  static const SEARCH_USERS = '/search-users';
  static const MAIN_NAVIGATION = '/main-navigation';
  static const CREATE_STORY = '/create-story';
  static const SETTINGS = '/settings'; // Adicione esta linha
}
