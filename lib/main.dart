import 'package:bikedrop/design_system/tokens/app_theme.dart';
import 'package:bikedrop/features/overview_screen.dart';
import 'package:bikedrop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('de'),
      home: const OverviewScreen(),
    );
  }
}
