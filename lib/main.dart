import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/localization/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: AarogyaVaniApp(),
    ),
  );
}

class AarogyaVaniApp extends ConsumerWidget {
  const AarogyaVaniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguageCode = ref.watch(selectedLanguageCodeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      locale: Locale(selectedLanguageCode),
      supportedLocales: const [
        Locale('en', ''),
        Locale('hi', ''),
        Locale('ml', ''),
        Locale('ta', ''),
        Locale('te', ''),
        Locale('kn', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
