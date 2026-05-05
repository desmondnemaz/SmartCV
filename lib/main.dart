import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'core/theme/app_theme.dart';
import 'features/editor/presentation/providers/cv_provider.dart';
import 'features/settings/presentation/providers/theme_provider.dart';
import 'features/dashboard/presentation/screens/home_screen.dart';
import 'core/services/pdf_service.dart';


void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Perform initialization while the splash screen is visible
  try {
    // Warm up the font cache (pre-loads BundledPoppins)
    await PDFService.init();
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  // Add a deliberate delay to ensure the splash screen is seen and 
  // the app feels stable on entry (e.g., 2 seconds total)
  await Future.delayed(const Duration(milliseconds: 2000));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CVProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );

  FlutterNativeSplash.remove();
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'SmartCV ZW',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
      ],
    );
  }
}
