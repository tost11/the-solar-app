import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:the_solar_app/generated/l10n/app_localizations.dart';
import 'screens/device_list_screen.dart';
import 'services/device_storage_service.dart';
import 'utils/globals.dart';
import 'utils/debug_log.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Globals.initialize();

  // Initialize debug log file if logging is enabled
  if (Globals.logLevel != 'none') {
    await DebugLog.initialize();
  }

  // Configure flutter_blue_plus logging dynamically based on debug settings
  final bluetoothLevel = DebugLog.getEffectiveLogLevel('bluetooth');
  
  if (bluetoothLevel != 'none') {
    final fppLogLevel = switch (bluetoothLevel) {
      'verbose' || 'debug' => fbp.LogLevel.verbose,
      'info' => fbp.LogLevel.info,
      'warning' => fbp.LogLevel.warning,
      'error' => fbp.LogLevel.error,
      _ => fbp.LogLevel.none,
    };
    fbp.FlutterBluePlus.setLogLevel(fppLogLevel, color: false);
  } else {
    fbp.FlutterBluePlus.setLogLevel(fbp.LogLevel.none, color: false);
  }

  // Log app startup
  DebugLog.system('App started', level: LogLevel.info);

  // Initialize device registry from storage
  // This MUST happen once on app startup before any device operations
  await DeviceStorageService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      DebugLog.dispose(); // Flush and close log file only when app is truly terminating
    }
  }

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
