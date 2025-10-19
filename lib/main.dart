import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/company_service.dart';
import 'utils/constants.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/analytics/analytics_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await StorageService.init();
  ApiService.init();
  await AuthService.init();
  await CompanyService.init();

  runApp(const CloudShopMgrApp());
}

class CloudShopMgrApp extends StatelessWidget {
  const CloudShopMgrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<AppStateProvider, ThemeProvider>(
        builder: (context, appState, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,            
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ru'),
              Locale('uz'),
            ],
            locale: appState.currentLocale,
            home: AuthService.isLoggedIn ? const HomeScreen() : const LoginScreen(),
            debugShowCheckedModeBanner: false,
            routes: {
              '/analytics': (context) => const AnalyticsDashboardScreen(),
            },
          );
        },
      ),
    );
  }
}

class AppStateProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  bool _isLoading = false;

  Locale get currentLocale => _currentLocale;
  bool get isLoading => _isLoading;

  void setLocale(Locale locale) {
    _currentLocale = locale;
    StorageService.store('locale', locale.languageCode);
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void loadStoredLocale() {
    final storedLocale = StorageService.get('locale');
    if (storedLocale != null) {
      _currentLocale = Locale(storedLocale);
      notifyListeners();
    }
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Lufga',
    colorScheme: ColorScheme.light(
      primary: const Color(AppColors.primaryIndigo),
      secondary: const Color(AppColors.accentCyan),
      tertiary: const Color(AppColors.accentPink),
      surface: const Color(AppColors.surfaceLight),
      surfaceContainerHighest: const Color(AppColors.cardLight),
      error: const Color(AppColors.error),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(AppColors.textPrimary),
      onError: Colors.white,
      outline: const Color(AppColors.borderLight),
    ),
    scaffoldBackgroundColor: const Color(AppColors.backgroundLight),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: const Color(AppColors.textPrimary),
      titleTextStyle: const TextStyle(
        fontFamily: 'Lufga',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(AppColors.textPrimary),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(AppColors.surfaceLight),
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(AppColors.borderLight), width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: const Color(AppColors.primaryIndigo),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Lufga',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: const Color(AppColors.primaryIndigo),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(AppColors.primaryIndigo),
        side: const BorderSide(color: Color(AppColors.primaryIndigo), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(AppColors.primaryIndigo),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(AppColors.surfaceLight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(AppColors.borderLight)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(AppColors.borderLight)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(AppColors.primaryIndigo), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(AppColors.error)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(AppColors.error), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: Color(AppColors.textHint)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(AppColors.primaryLight).withValues(alpha: 0.1),
      labelStyle: const TextStyle(color: Color(AppColors.primaryIndigo)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(AppColors.dividerLight),
      thickness: 1,
      space: 1,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(AppColors.primaryIndigo),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Lufga',
    colorScheme: ColorScheme.dark(
      primary: const Color(AppColors.primaryLight),
      secondary: const Color(AppColors.accentCyan),
      tertiary: const Color(AppColors.accentPink),
      surface: const Color(AppColors.surfaceDark),
      surfaceContainerHighest: const Color(AppColors.cardDark),
      error: const Color(AppColors.errorLight),
      onPrimary: const Color(AppColors.backgroundDark),
      onSecondary: Colors.white,
      onSurface: const Color(AppColors.textOnDark),
      onError: const Color(AppColors.backgroundDark),
      outline: const Color(AppColors.borderDark),
    ),
    scaffoldBackgroundColor: const Color(AppColors.backgroundDark),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: const Color(AppColors.textOnDark),
      titleTextStyle: const TextStyle(
        fontFamily: 'Lufga',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(AppColors.textOnDark),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(AppColors.surfaceDark),
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(AppColors.borderDark), width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: const Color(AppColors.primaryLight),
        foregroundColor: const Color(AppColors.backgroundDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Lufga',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: const Color(AppColors.primaryLight),
        foregroundColor: const Color(AppColors.backgroundDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(AppColors.primaryLight),
        side: const BorderSide(color: Color(AppColors.primaryLight), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(AppColors.primaryLight),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(AppColors.surfaceDark),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(AppColors.borderDark)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(AppColors.borderDark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(AppColors.primaryLight), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(AppColors.errorLight)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(AppColors.errorLight), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: const Color(AppColors.textHint).withValues(alpha: 0.7)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(AppColors.primaryLight).withValues(alpha: 0.2),
      labelStyle: const TextStyle(color: Color(AppColors.primaryLight)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(AppColors.dividerDark),
      thickness: 1,
      space: 1,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(AppColors.primaryLight),
      foregroundColor: Color(AppColors.backgroundDark),
      elevation: 4,
      shape: CircleBorder(),
    ),
  );

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    StorageService.store('theme_mode', mode.index.toString());
    notifyListeners();
  }

  void loadStoredThemeMode() {
    final storedMode = StorageService.get('theme_mode');
    if (storedMode != null) {
      _themeMode = ThemeMode.values[int.parse(storedMode)];
      notifyListeners();
    }
  }
}
