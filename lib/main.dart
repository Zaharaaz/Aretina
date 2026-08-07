import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme.dart';
import 'core/routes/app_router.dart';
import 'logic/controllers/auth_controller.dart';
import 'logic/controllers/detection_controller.dart';
import 'logic/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final themeProvider = ThemeProvider();
  await themeProvider.loadSavedTheme(); 

  runApp(EyeScanApp(themeProvider: themeProvider));
}

class EyeScanApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  const EyeScanApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => DetectionController()),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
      ],
      child: Builder(
        builder: (context) {
          final router = createRouter(context);
          final themeProvider = context.watch<ThemeProvider>();
          final isDark = themeProvider.isDarkMode;
          AppTheme.activeColors = isDark ? AppColors.dark : AppColors.light;

          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor:
                  isDark ? AppTheme.darkTheme.scaffoldBackgroundColor
                         : AppTheme.lightTheme.scaffoldBackgroundColor,
              systemNavigationBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
            ),
          );

          return MaterialApp.router(
            title: 'EyeScan AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}