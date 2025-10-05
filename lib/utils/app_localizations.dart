import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // App
  String get appTitle => _getText('appTitle');
  String get loading => _getText('loading');
  String get retry => _getText('retry');
  String get cancel => _getText('cancel');
  String get save => _getText('save');
  String get delete => _getText('delete');
  String get edit => _getText('edit');
  String get add => _getText('add');
  String get search => _getText('search');
  String get filter => _getText('filter');
  String get refresh => _getText('refresh');
  String get ok => _getText('ok');
  String get yes => _getText('yes');
  String get no => _getText('no');
  String get close => _getText('close');

  // Authentication
  String get login => _getText('login');
  String get logout => _getText('logout');
  String get email => _getText('email');
  String get phone => _getText('phone');
  String get phoneNumber => _getText('phoneNumber');
  String get password => _getText('password');
  String get forgotPassword => _getText('forgotPassword');
  String get loginError => _getText('loginError');
  String get logoutConfirm => _getText('logoutConfirm');
  String get emailRequired => _getText('emailRequired');
  String get passwordRequired => _getText('passwordRequired');
  String get invalidEmail => _getText('invalidEmail');
  String get passwordTooShort => _getText('passwordTooShort');

  // Navigation
  String get home => _getText('home');
  String get warehouse => _getText('warehouse');
  String get orders => _getText('orders');
  String get production => _getText('production');
  String get tasks => _getText('tasks');
  String get profile => _getText('profile');
  String get notifications => _getText('notifications');
  String get analytics => _getText('analytics');
  String get settings => _getText('settings');

  // Common errors
  String get networkError => _getText('networkError');
  String get serverError => _getText('serverError');
  String get unknownError => _getText('unknownError');
  String get unauthorizedError => _getText('unauthorizedError');

  // Language
  String get language => _getText('language');
  String get welcome => _getText('welcome');

  // Home screen
  String get allActivitiesInOnePlace => _getText('allActivitiesInOnePlace');
  String get theHomeScreenGivesUsers => _getText('theHomeScreenGivesUsers');

  String _getText(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']![key]!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Symphony ERP',
      'loading': 'Loading...',
      'retry': 'Retry',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'search': 'Search',
      'filter': 'Filter',
      'refresh': 'Refresh',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'close': 'Close',
      'login': 'Login',
      'logout': 'Logout',
      'email': 'Phone',
      'phone': 'Phone',
      'phoneNumber': 'Phone Number',
      'password': 'Password',
      'forgotPassword': 'Forgot Password?',
      'loginError': 'Login failed. Please check your credentials.',
      'logoutConfirm': 'Are you sure you want to logout?',
      'emailRequired': 'Email is required',
      'passwordRequired': 'Password is required',
      'invalidEmail': 'Please enter a valid email address',
      'passwordTooShort': 'Password must be at least 6 characters long',
      'home': 'Home',
      'warehouse': 'Warehouse',
      'orders': 'Orders',
      'production': 'Production',
      'tasks': 'Tasks',
      'profile': 'Profile',
      'notifications': 'Notifications',
      'analytics': 'Analytics',
      'settings': 'Settings',
      'networkError': 'Network error. Please check your connection.',
      'serverError': 'Server error. Please try again later.',
      'unknownError': 'An unknown error occurred.',
      'unauthorizedError': 'Session expired. Please login again.',
      'language': 'Language',
      'welcome': 'Welcome',
      'allActivitiesInOnePlace': 'All your activities in one place',
      'theHomeScreenGivesUsers': 'The Home Screen gives users a clear, quick overview of their day. It displays high-priority tasks, upcoming deadlines, and recent team',
    },
    'ru': {
      'appTitle': 'Symphony ERP',
      'loading': 'Загрузка...',
      'retry': 'Повторить',
      'cancel': 'Отмена',
      'save': 'Сохранить',
      'delete': 'Удалить',
      'edit': 'Редактировать',
      'add': 'Добавить',
      'search': 'Поиск',
      'filter': 'Фильтр',
      'refresh': 'Обновить',
      'ok': 'ОК',
      'yes': 'Да',
      'no': 'Нет',
      'close': 'Закрыть',
      'login': 'Войти',
      'logout': 'Выйти',
      'email': 'Телефон',
      'phone': 'Телефон',
      'phoneNumber': 'Номер телефона',
      'password': 'Пароль',
      'forgotPassword': 'Забыли пароль?',
      'loginError': 'Ошибка входа. Проверьте ваши данные.',
      'logoutConfirm': 'Вы уверены, что хотите выйти?',
      'emailRequired': 'Электронная почта обязательна',
      'passwordRequired': 'Пароль обязателен',
      'invalidEmail': 'Введите действительный адрес электронной почты',
      'passwordTooShort': 'Пароль должен содержать не менее 6 символов',
      'home': 'Главная',
      'warehouse': 'Склад',
      'orders': 'Заказы',
      'production': 'Производство',
      'tasks': 'Задачи',
      'profile': 'Профиль',
      'notifications': 'Уведомления',
      'analytics': 'Аналитика',
      'settings': 'Настройки',
      'networkError': 'Ошибка сети. Проверьте подключение к интернету.',
      'serverError': 'Ошибка сервера. Попробуйте позже.',
      'unknownError': 'Произошла неизвестная ошибка.',
      'unauthorizedError': 'Сессия истекла. Войдите снова.',
      'language': 'Язык',
      'welcome': 'Добро пожаловать',
      'allActivitiesInOnePlace': 'Все ваши активности в одном месте',
      'theHomeScreenGivesUsers': 'Главный экран дает пользователям четкий, быстрый обзор их дня. Он отображает высокоприоритетные задачи, предстоящие дедлайны и недавнюю активность команды',
    },
    'uz': {
      'appTitle': 'Symphony ERP',
      'loading': 'Yuklanmoqda...',
      'retry': 'Qayta urinish',
      'cancel': 'Bekor qilish',
      'save': 'Saqlash',
      'delete': 'O\'chirish',
      'edit': 'Tahrirlash',
      'add': 'Qo\'shish',
      'search': 'Qidirish',
      'filter': 'Filtr',
      'refresh': 'Yangilash',
      'ok': 'OK',
      'yes': 'Ha',
      'no': 'Yo\'q',
      'close': 'Yopish',
      'login': 'Kirish',
      'logout': 'Chiqish',
      'email': 'Telefon',
      'phone': 'Telefon',
      'phoneNumber': 'Telefon raqami',
      'password': 'Parol',
      'forgotPassword': 'Parolni unutdingizmi?',
      'loginError': 'Kirish xatoligi. Ma\'lumotlaringizni tekshiring.',
      'logoutConfirm': 'Rostdan ham chiqishni istaysizmi?',
      'emailRequired': 'Elektron pochta talab qilinadi',
      'passwordRequired': 'Parol talab qilinadi',
      'invalidEmail': 'To\'g\'ri elektron pochta manzilini kiriting',
      'passwordTooShort': 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak',
      'home': 'Bosh sahifa',
      'warehouse': 'Ombor',
      'orders': 'Buyurtmalar',
      'production': 'Ishlab chiqarish',
      'tasks': 'Vazifalar',
      'profile': 'Profil',
      'notifications': 'Bildirishnomalar',
      'analytics': 'Tahlil',
      'settings': 'Sozlamalar',
      'networkError': 'Tarmoq xatoligi. Internet ulanishini tekshiring.',
      'serverError': 'Server xatoligi. Keyinroq urinib ko\'ring.',
      'unknownError': 'Noma\'lum xatolik yuz berdi.',
      'unauthorizedError': 'Sessiya tugadi. Qayta kiring.',
      'language': 'Til',
      'welcome': 'Xush kelibsiz',
      'allActivitiesInOnePlace': 'Barcha faoliyatingiz bir joyda',
      'theHomeScreenGivesUsers': 'Bosh sahifa foydalanuvchilarga kunning aniq va tezkor ko\'rinishini beradi. U yuqori ustuvorlikdagi vazifalar, yaqinlashayotgan muddatlar va so\'nggi jamoa faoliyatini ko\'rsatadi',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru', 'uz'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}