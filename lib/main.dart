import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'screens/device_list_screen.dart';
import 'services/device_storage_service.dart';
import 'utils/globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Globals.initialize();

  // Initialize device registry from storage
  // This MUST happen once on app startup before any device operations
  await DeviceStorageService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: Globals.languageNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          title: 'The Solar App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          // Localization configuration
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('de'), // German
            Locale('en'), // English
          ],
          locale: locale, // Bind to language notifier
          home: const DeviceListScreen(),
        );
      },
    );
  }
}
