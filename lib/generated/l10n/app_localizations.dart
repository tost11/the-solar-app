import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// Application title
  ///
  /// In de, this message translates to:
  /// **'The Solar App'**
  String get appTitle;

  /// OK button label
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get ok;

  /// Cancel button label
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// Save button label
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// Delete button label
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// Edit button label
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get edit;

  /// Select button label
  ///
  /// In de, this message translates to:
  /// **'Auswählen'**
  String get select;

  /// Confirm button label
  ///
  /// In de, this message translates to:
  /// **'Bestätigen'**
  String get confirm;

  /// Close button label
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get close;

  /// Update button label
  ///
  /// In de, this message translates to:
  /// **'Aktualisieren'**
  String get update;

  /// Install button label
  ///
  /// In de, this message translates to:
  /// **'Installieren'**
  String get install;

  /// Preview button label
  ///
  /// In de, this message translates to:
  /// **'Vorschau'**
  String get preview;

  /// Connection status - connected
  ///
  /// In de, this message translates to:
  /// **'Verbunden'**
  String get connected;

  /// Connection status - not connected
  ///
  /// In de, this message translates to:
  /// **'Nicht verbunden'**
  String get notConnected;

  /// Connection status - connecting
  ///
  /// In de, this message translates to:
  /// **'Verbinde...'**
  String get connecting;

  /// Loading message while fetching device data
  ///
  /// In de, this message translates to:
  /// **'Lade Gerätedaten...'**
  String get loadingDeviceData;

  /// Connection failed message
  ///
  /// In de, this message translates to:
  /// **'Verbindung fehlgeschlagen'**
  String get connectionFailed;

  /// Disconnecting message
  ///
  /// In de, this message translates to:
  /// **'Trenne Verbindung...'**
  String get disconnecting;

  /// Error dialog default title
  ///
  /// In de, this message translates to:
  /// **'Fehler'**
  String get error;

  /// Error message when device is not connected
  ///
  /// In de, this message translates to:
  /// **'Gerät nicht verbunden'**
  String get deviceNotConnected;

  /// Error when device doesn't respond
  ///
  /// In de, this message translates to:
  /// **'Keine Antwort vom Gerät'**
  String get noResponseFromDevice;

  /// Error when data retrieval fails
  ///
  /// In de, this message translates to:
  /// **'Daten konnten nicht abgerufen werden'**
  String get couldNotRetrieveData;

  /// Generic operation failed message
  ///
  /// In de, this message translates to:
  /// **'Vorgang fehlgeschlagen'**
  String get operationFailed;

  /// Settings screen title
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// Expert mode setting label
  ///
  /// In de, this message translates to:
  /// **'Expertenmodus'**
  String get expertMode;

  /// Expert mode description
  ///
  /// In de, this message translates to:
  /// **'Erweiterte Optionen anzeigen'**
  String get expertModeDescription;

  /// Permissions setting label
  ///
  /// In de, this message translates to:
  /// **'Berechtigungen'**
  String get permissions;

  /// Permissions description
  ///
  /// In de, this message translates to:
  /// **'App-Berechtigungen prüfen'**
  String get permissionsDescription;

  /// Language setting label
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get language;

  /// Language setting description
  ///
  /// In de, this message translates to:
  /// **'Sprache der Benutzeroberfläche'**
  String get languageDescription;

  /// German language name
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// English language name
  ///
  /// In de, this message translates to:
  /// **'English'**
  String get english;

  /// Exit application label
  ///
  /// In de, this message translates to:
  /// **'App beenden'**
  String get exitApp;

  /// Version label
  ///
  /// In de, this message translates to:
  /// **'Version'**
  String get version;

  /// Tap for details hint
  ///
  /// In de, this message translates to:
  /// **'Tippen für Details'**
  String get tapForDetails;

  /// Devices label
  ///
  /// In de, this message translates to:
  /// **'Geräte'**
  String get devices;

  /// Known devices title
  ///
  /// In de, this message translates to:
  /// **'Bekannte Geräte'**
  String get knownDevices;

  /// Add device button
  ///
  /// In de, this message translates to:
  /// **'Gerät hinzufügen'**
  String get addDevice;

  /// Scan for devices button
  ///
  /// In de, this message translates to:
  /// **'Nach Geräten suchen'**
  String get scanForDevices;

  /// Device name label
  ///
  /// In de, this message translates to:
  /// **'Gerätename'**
  String get deviceName;

  /// Device type label
  ///
  /// In de, this message translates to:
  /// **'Gerätetyp'**
  String get deviceType;

  /// Device information label
  ///
  /// In de, this message translates to:
  /// **'Geräteinformationen'**
  String get deviceInfo;

  /// Device settings label
  ///
  /// In de, this message translates to:
  /// **'Geräteeinstellungen'**
  String get deviceSettings;

  /// Delete device label
  ///
  /// In de, this message translates to:
  /// **'Gerät löschen'**
  String get deleteDevice;

  /// Device role label
  ///
  /// In de, this message translates to:
  /// **'Geräterolle'**
  String get deviceRole;

  /// Select device role prompt
  ///
  /// In de, this message translates to:
  /// **'Geräterolle auswählen'**
  String get selectDeviceRole;

  /// Confirmation dialog title
  ///
  /// In de, this message translates to:
  /// **'Bestätigung'**
  String get confirmation;

  /// Are you sure confirmation
  ///
  /// In de, this message translates to:
  /// **'Sind Sie sicher?'**
  String get areYouSure;

  /// Delete device confirmation message
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie dieses Gerät wirklich löschen?'**
  String get deleteDeviceConfirm;

  /// Action cannot be undone warning
  ///
  /// In de, this message translates to:
  /// **'Diese Aktion kann nicht rückgängig gemacht werden.'**
  String get cannotBeUndone;

  /// Device list screen title
  ///
  /// In de, this message translates to:
  /// **'Geräteliste'**
  String get deviceList;

  /// Device detail screen title
  ///
  /// In de, this message translates to:
  /// **'Gerätedetails'**
  String get deviceDetail;

  /// Scan screen title
  ///
  /// In de, this message translates to:
  /// **'Geräte suchen'**
  String get scanScreen;

  /// Manual add screen title
  ///
  /// In de, this message translates to:
  /// **'Manuell hinzufügen'**
  String get manualAdd;

  /// Scanning status
  ///
  /// In de, this message translates to:
  /// **'Suche...'**
  String get scanning;

  /// Bluetooth devices label
  ///
  /// In de, this message translates to:
  /// **'Bluetooth-Geräte'**
  String get bluetoothDevices;

  /// Network devices label
  ///
  /// In de, this message translates to:
  /// **'Netzwerkgeräte'**
  String get networkDevices;

  /// No devices found message
  ///
  /// In de, this message translates to:
  /// **'Keine Geräte gefunden'**
  String get noDevicesFound;

  /// Number of devices found
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Keine Geräte gefunden} =1{1 Gerät gefunden} other{{count} Geräte gefunden}}'**
  String devicesFound(int count);

  /// Connect button
  ///
  /// In de, this message translates to:
  /// **'Verbinden'**
  String get connect;

  /// Disconnect button
  ///
  /// In de, this message translates to:
  /// **'Trennen'**
  String get disconnect;

  /// Reconnect button
  ///
  /// In de, this message translates to:
  /// **'Erneut verbinden'**
  String get reconnect;

  /// Auto reconnect label
  ///
  /// In de, this message translates to:
  /// **'Automatisch neu verbinden'**
  String get autoReconnect;

  /// Power label
  ///
  /// In de, this message translates to:
  /// **'Leistung'**
  String get power;

  /// Voltage label
  ///
  /// In de, this message translates to:
  /// **'Spannung'**
  String get voltage;

  /// Current label
  ///
  /// In de, this message translates to:
  /// **'Strom'**
  String get current;

  /// Battery label
  ///
  /// In de, this message translates to:
  /// **'Batterie'**
  String get battery;

  /// Battery level label
  ///
  /// In de, this message translates to:
  /// **'Batteriestand'**
  String get batteryLevel;

  /// Output limit label
  ///
  /// In de, this message translates to:
  /// **'Ausgangsgrenze'**
  String get outputLimit;

  /// Status label
  ///
  /// In de, this message translates to:
  /// **'Status'**
  String get status;

  /// Temperature label
  ///
  /// In de, this message translates to:
  /// **'Temperatur'**
  String get temperature;

  /// Energy label
  ///
  /// In de, this message translates to:
  /// **'Energie'**
  String get energy;

  /// Parameters label
  ///
  /// In de, this message translates to:
  /// **'Parameter'**
  String get parameters;

  /// Configure parameters label
  ///
  /// In de, this message translates to:
  /// **'Parameter konfigurieren'**
  String get configureParameters;

  /// New parameters available message
  ///
  /// In de, this message translates to:
  /// **'Neue Parameter verfügbar'**
  String get newParametersAvailable;

  /// Update to new version prompt
  ///
  /// In de, this message translates to:
  /// **'Auf neue Version aktualisieren?'**
  String get updateToNewVersion;

  /// Update parameters label
  ///
  /// In de, this message translates to:
  /// **'Parameter aktualisieren'**
  String get updateParameters;

  /// Direct install label
  ///
  /// In de, this message translates to:
  /// **'Direkt installieren'**
  String get directInstall;

  /// Install on device label
  ///
  /// In de, this message translates to:
  /// **'Auf Gerät installieren'**
  String get installOnDevice;

  /// Create from template label
  ///
  /// In de, this message translates to:
  /// **'Aus Vorlage erstellen'**
  String get createFromTemplate;

  /// Scripts label
  ///
  /// In de, this message translates to:
  /// **'Scripte'**
  String get scripts;

  /// Delete script confirmation
  ///
  /// In de, this message translates to:
  /// **'Script löschen?'**
  String get deleteScript;

  /// Install script confirmation
  ///
  /// In de, this message translates to:
  /// **'Script installieren?'**
  String get installScript;

  /// Autostart enabled label
  ///
  /// In de, this message translates to:
  /// **'Autostart aktiviert'**
  String get autostartEnabled;

  /// Show all scripts label
  ///
  /// In de, this message translates to:
  /// **'Alle Scripte anzeigen'**
  String get showAllScripts;

  /// Compatibility information label
  ///
  /// In de, this message translates to:
  /// **'Kompatibilitäts-Information'**
  String get compatibilityInfo;

  /// Loading message
  ///
  /// In de, this message translates to:
  /// **'Lädt...'**
  String get loading;

  /// Refresh label
  ///
  /// In de, this message translates to:
  /// **'Aktualisieren'**
  String get refresh;

  /// Retry label
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get retry;

  /// All label
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get all;

  /// None label
  ///
  /// In de, this message translates to:
  /// **'Keine'**
  String get none;

  /// Enabled label
  ///
  /// In de, this message translates to:
  /// **'Aktiviert'**
  String get enabled;

  /// Disabled label
  ///
  /// In de, this message translates to:
  /// **'Deaktiviert'**
  String get disabled;

  /// Name label
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get name;

  /// Value label
  ///
  /// In de, this message translates to:
  /// **'Wert'**
  String get value;

  /// Description label
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get description;

  /// Saved successfully message
  ///
  /// In de, this message translates to:
  /// **'Erfolgreich gespeichert'**
  String get savedSuccessfully;

  /// Deleted successfully message
  ///
  /// In de, this message translates to:
  /// **'Erfolgreich gelöscht'**
  String get deletedSuccessfully;

  /// Updated successfully message
  ///
  /// In de, this message translates to:
  /// **'Erfolgreich aktualisiert'**
  String get updatedSuccessfully;

  /// Installed successfully message
  ///
  /// In de, this message translates to:
  /// **'Erfolgreich installiert'**
  String get installedSuccessfully;

  /// Connected successfully message
  ///
  /// In de, this message translates to:
  /// **'Erfolgreich verbunden'**
  String get connectedSuccessfully;

  /// Disconnected successfully message
  ///
  /// In de, this message translates to:
  /// **'Erfolgreich getrennt'**
  String get disconnectedSuccessfully;

  /// No item selected message in master-detail view
  ///
  /// In de, this message translates to:
  /// **'Kein Element ausgewählt'**
  String get noItemSelected;

  /// Select item from list instruction in master-detail view
  ///
  /// In de, this message translates to:
  /// **'Wählen Sie ein Element aus der Liste'**
  String get selectItemFromList;

  /// Error message when saving fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Speichern: {error}'**
  String errorWhileSaving(String error);

  /// Error message when loading fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden: {error}'**
  String errorWhileLoading(String error);

  /// Error message when toggling fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Umschalten: {error}'**
  String errorWhileToggling(String error);

  /// Error message when execution fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Ausführen: {error}'**
  String errorWhileExecuting(String error);

  /// Error message when adjusting fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Anpassen: {error}'**
  String errorWhileAdjusting(String error);

  /// Error message when restarting device fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Neustarten des Geräts: {error}'**
  String errorWhileRestarting(String error);

  /// Error message when disconnecting fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Trennen: {error}'**
  String errorWhileDisconnecting(String error);

  /// Error message when uploading code fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Hochladen des Codes'**
  String get errorWhileUploading;

  /// Error message when loading configuration fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Konfiguration: {error}'**
  String errorWhileLoadingConfig(String error);

  /// Error message when retrieving scripts fails
  ///
  /// In de, this message translates to:
  /// **'Konnte Scripts nicht laden: {error}'**
  String errorCouldNotRetrieveScripts(String error);

  /// Error message when retrieving script code fails
  ///
  /// In de, this message translates to:
  /// **'Konnte Script-Code nicht abrufen'**
  String get errorCouldNotRetrieveScriptCode;

  /// Error message when loading latest version fails
  ///
  /// In de, this message translates to:
  /// **'Konnte neueste Version nicht laden'**
  String get errorCouldNotLoadLatestVersion;

  /// Validation error for empty field
  ///
  /// In de, this message translates to:
  /// **'Feld darf nicht leer sein'**
  String get validationFieldCannotBeEmpty;

  /// Validation error for empty device name
  ///
  /// In de, this message translates to:
  /// **'Gerätename darf nicht leer sein'**
  String get validationDeviceNameCannotBeEmpty;

  /// Validation error for empty username
  ///
  /// In de, this message translates to:
  /// **'Benutzername darf nicht leer sein'**
  String get validationUsernameCannotBeEmpty;

  /// Validation error for empty MQTT server
  ///
  /// In de, this message translates to:
  /// **'MQTT-Server darf nicht leer sein'**
  String get validationMqttServerCannotBeEmpty;

  /// Validation prompt for IP or hostname
  ///
  /// In de, this message translates to:
  /// **'Bitte IP-Adresse oder Hostname eingeben'**
  String get validationEnterIpOrHostname;

  /// Validation prompt for secure password
  ///
  /// In de, this message translates to:
  /// **'Geben Sie ein sicheres Passwort ein'**
  String get validationEnterSecurePassword;

  /// Form label for username
  ///
  /// In de, this message translates to:
  /// **'Benutzername'**
  String get formUsername;

  /// Form label for password
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get formPassword;

  /// Form label for SSID
  ///
  /// In de, this message translates to:
  /// **'SSID'**
  String get formSsid;

  /// Form label for port
  ///
  /// In de, this message translates to:
  /// **'Port'**
  String get formPort;

  /// Form label for hostname
  ///
  /// In de, this message translates to:
  /// **'Hostname'**
  String get formHostname;

  /// Form label for IP address
  ///
  /// In de, this message translates to:
  /// **'IP-Adresse'**
  String get formIpAddress;

  /// Form label for manufacturer
  ///
  /// In de, this message translates to:
  /// **'Hersteller'**
  String get formManufacturer;

  /// Form hint for entering username
  ///
  /// In de, this message translates to:
  /// **'Benutzername eingeben'**
  String get formEnterUsername;

  /// Form hint for entering password
  ///
  /// In de, this message translates to:
  /// **'Passwort eingeben'**
  String get formEnterPassword;

  /// Form hint for entering port number
  ///
  /// In de, this message translates to:
  /// **'Geben Sie die Port-Nummer ein'**
  String get formEnterPort;

  /// Form hint for entering SSID
  ///
  /// In de, this message translates to:
  /// **'Geben Sie den SSID ein'**
  String get formEnterSsid;

  /// Form hint for entering WiFi password
  ///
  /// In de, this message translates to:
  /// **'WiFi-Passwort'**
  String get formEnterWifiPassword;

  /// Form hint for selecting or entering WiFi network
  ///
  /// In de, this message translates to:
  /// **'WiFi-Netzwerkname eingeben oder auswählen'**
  String get formSelectOrEnterWifiNetwork;

  /// Form label for protocol port
  ///
  /// In de, this message translates to:
  /// **'Protokoll-Port (z.B. Modbus)'**
  String get formProtocolPort;

  /// Form helper text for additional port
  ///
  /// In de, this message translates to:
  /// **'Zusätzlicher Port für Protokollkommunikation'**
  String get formAdditionalPortHelper;

  /// Success message when device name is saved
  ///
  /// In de, this message translates to:
  /// **'Gerätename gespeichert'**
  String get messageDeviceNameSaved;

  /// Success message when device is saved
  ///
  /// In de, this message translates to:
  /// **'Gerät gespeichert'**
  String get messageDeviceSaved;

  /// Info message when device is restarting
  ///
  /// In de, this message translates to:
  /// **'Gerät wird neu gestartet'**
  String get messageDeviceRestarting;

  /// Success message when power limit is set
  ///
  /// In de, this message translates to:
  /// **'Leistungslimit erfolgreich gesetzt'**
  String get messagePowerLimitSet;

  /// Success message when MQTT is enabled
  ///
  /// In de, this message translates to:
  /// **'MQTT-Verbindung wurde aktiviert'**
  String get messageMqttEnabled;

  /// Success message when MQTT is disabled
  ///
  /// In de, this message translates to:
  /// **'MQTT-Verbindung wurde deaktiviert'**
  String get messageMqttDisabled;

  /// Success message when authentication is saved
  ///
  /// In de, this message translates to:
  /// **'Authentifizierung gespeichert'**
  String get messageAuthSaved;

  /// Success message when network is saved
  ///
  /// In de, this message translates to:
  /// **'Netzwerk gespeichert'**
  String get messageNetworkSaved;

  /// Success message when interval is saved
  ///
  /// In de, this message translates to:
  /// **'Intervall gespeichert'**
  String get messageIntervalSaved;

  /// Loading message while saving
  ///
  /// In de, this message translates to:
  /// **'Wird gespeichert...'**
  String get messageSaving;

  /// Status message when device is not found
  ///
  /// In de, this message translates to:
  /// **'Gerät nicht gefunden'**
  String get statusDeviceNotFound;

  /// Status message for connection error
  ///
  /// In de, this message translates to:
  /// **'Verbindungsfehler'**
  String get statusConnectionError;

  /// Status message when no inverters are found
  ///
  /// In de, this message translates to:
  /// **'Keine Wechselrichter gefunden'**
  String get statusNoInvertersFound;

  /// Status message when no scripts are found
  ///
  /// In de, this message translates to:
  /// **'Keine Scripts gefunden'**
  String get statusNoScriptsFound;

  /// Status message when device is already in system
  ///
  /// In de, this message translates to:
  /// **'Gerät bereits im System'**
  String get statusDeviceAlreadyInSystem;

  /// Status message when device is removed
  ///
  /// In de, this message translates to:
  /// **'Gerät entfernt'**
  String get statusDeviceRemoved;

  /// Status message when device has no role configuration
  ///
  /// In de, this message translates to:
  /// **'Gerät hat keine Rollen-Konfiguration'**
  String get statusDeviceHasNoRoleConfig;

  /// Status message when device has no configurable roles
  ///
  /// In de, this message translates to:
  /// **'Gerät hat keine konfigurierbaren Rollen'**
  String get statusDeviceHasNoConfigurableRoles;

  /// Title for device settings screen
  ///
  /// In de, this message translates to:
  /// **'Geräteeinstellungen'**
  String get screenDeviceSettings;

  /// Title for authentication screen
  ///
  /// In de, this message translates to:
  /// **'Authentifizierung'**
  String get screenAuthentication;

  /// Title for MQTT configuration screen
  ///
  /// In de, this message translates to:
  /// **'MQTT Konfiguration'**
  String get screenMqttConfig;

  /// Title for WiFi configuration screen
  ///
  /// In de, this message translates to:
  /// **'WiFi konfigurieren'**
  String get screenWifiConfig;

  /// Title for general settings screen
  ///
  /// In de, this message translates to:
  /// **'Allgemeine Einstellungen'**
  String get screenGeneralSettings;

  /// Title for manual device add screen
  ///
  /// In de, this message translates to:
  /// **'Gerät manuell hinzufügen'**
  String get screenManualDeviceAdd;

  /// Title for network configuration screen
  ///
  /// In de, this message translates to:
  /// **'Netzwerkverbindung'**
  String get screenNetworkConfig;

  /// Title for access point configuration screen
  ///
  /// In de, this message translates to:
  /// **'Access Point Konfiguration'**
  String get screenAccessPointConfig;

  /// Title for update parameters screen
  ///
  /// In de, this message translates to:
  /// **'Parameter aktualisieren'**
  String get screenUpdateParameters;

  /// Title for automation screen
  ///
  /// In de, this message translates to:
  /// **'Automatisierung'**
  String get screenAutomation;

  /// Action label for saving network
  ///
  /// In de, this message translates to:
  /// **'Netzwerk speichern'**
  String get actionSaveNetwork;

  /// Action label for saving authentication
  ///
  /// In de, this message translates to:
  /// **'Authentifizierung speichern'**
  String get actionSaveAuth;

  /// Action label for saving interval
  ///
  /// In de, this message translates to:
  /// **'Intervall speichern'**
  String get actionSaveInterval;

  /// Action label for setting up network
  ///
  /// In de, this message translates to:
  /// **'Netzwerkverbindung einrichten'**
  String get actionSetupNetwork;

  /// Action label for setting up access point
  ///
  /// In de, this message translates to:
  /// **'WiFi Access Point einrichten'**
  String get actionSetupAccessPoint;

  /// Action label for setting up authentication
  ///
  /// In de, this message translates to:
  /// **'Benutzername und Passwort einrichten'**
  String get actionSetupAuth;

  /// Action label for limiting output power
  ///
  /// In de, this message translates to:
  /// **'Ausgangsleistung begrenzen'**
  String get actionLimitOutput;

  /// Action label for toggling inverters
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter ein-/ausschalten'**
  String get actionToggleInverters;

  /// Action description for toggling all inverters
  ///
  /// In de, this message translates to:
  /// **'Schaltet alle Wechselrichter'**
  String get actionTogglesAllInverters;

  /// Action label for restarting device
  ///
  /// In de, this message translates to:
  /// **'Neu starten'**
  String get actionRestart;

  /// Help text for device settings screen
  ///
  /// In de, this message translates to:
  /// **'Konfigurieren Sie den Namen und die Authentifizierung für dieses Gerät.'**
  String get helpDeviceSettingsDescription;

  /// Help text for MQTT configuration
  ///
  /// In de, this message translates to:
  /// **'Verbinden Sie Ihr Gerät mit einem MQTT-Broker für Home Automation Integration.'**
  String get helpMqttDescription;

  /// Help text for MQTT enable/disable
  ///
  /// In de, this message translates to:
  /// **'Aktiviert oder deaktiviert die MQTT-Verbindung'**
  String get helpEnableOrDisableMqtt;

  /// Help text for access point enable/disable
  ///
  /// In de, this message translates to:
  /// **'Aktiviert oder deaktiviert den Access Point'**
  String get helpEnableOrDisableAp;

  /// Warning text for access point disable
  ///
  /// In de, this message translates to:
  /// **'Warnung: Wenn deaktiviert, ist möglicherweise keine Interaktion mit dem Gerät mehr möglich. Vorsichtig verwenden!'**
  String get helpApWarning;

  /// Help text for open network option
  ///
  /// In de, this message translates to:
  /// **'Netzwerk ohne Passwort (nicht empfohlen)'**
  String get helpOpenNetwork;

  /// Help text for update interval
  ///
  /// In de, this message translates to:
  /// **'Zeitintervall zwischen Datenabrufen vom Gerät'**
  String get helpUpdateIntervalDescription;

  /// Help text for interval default value
  ///
  /// In de, this message translates to:
  /// **'Standard: 30 Sekunden (Bereich: 1-300)'**
  String get helpIntervalDefault;

  /// Help text for authentication
  ///
  /// In de, this message translates to:
  /// **'Benutzername und Passwort für die Geräteauthentifizierung'**
  String get helpAuthDescription;

  /// Label for enabling access point
  ///
  /// In de, this message translates to:
  /// **'Access Point aktivieren'**
  String get wifiEnableAccessPoint;

  /// Label for open network
  ///
  /// In de, this message translates to:
  /// **'Offenes Netzwerk'**
  String get wifiOpenNetwork;

  /// Label for configuring WiFi
  ///
  /// In de, this message translates to:
  /// **'WiFi konfigurieren'**
  String get wifiConfigureWifi;

  /// Label for WiFi SSID
  ///
  /// In de, this message translates to:
  /// **'SSID'**
  String get wifiSsidLabel;

  /// Label for WiFi password
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get wifiPasswordLabel;

  /// Label for selecting WiFi network
  ///
  /// In de, this message translates to:
  /// **'Netzwerk auswählen'**
  String get wifiSelectNetwork;

  /// Label for entering network name
  ///
  /// In de, this message translates to:
  /// **'Netzwerkname eingeben'**
  String get wifiEnterNetworkName;

  /// Label for access point mode
  ///
  /// In de, this message translates to:
  /// **'Access Point Modus'**
  String get wifiApMode;

  /// Label for station mode
  ///
  /// In de, this message translates to:
  /// **'Station Modus'**
  String get wifiStationMode;

  /// Label for scanning networks
  ///
  /// In de, this message translates to:
  /// **'Netzwerke scannen'**
  String get wifiScanNetworks;

  /// Message when no WiFi networks are found
  ///
  /// In de, this message translates to:
  /// **'Keine Netzwerke gefunden'**
  String get wifiNoNetworksFound;

  /// Label for connection strength
  ///
  /// In de, this message translates to:
  /// **'Verbindungsstärke'**
  String get wifiConnectionStrength;

  /// Label for MQTT configuration
  ///
  /// In de, this message translates to:
  /// **'MQTT Konfiguration'**
  String get mqttConfiguration;

  /// Label for enabling MQTT
  ///
  /// In de, this message translates to:
  /// **'MQTT aktivieren'**
  String get mqttEnable;

  /// Label for MQTT server
  ///
  /// In de, this message translates to:
  /// **'MQTT Server'**
  String get mqttServer;

  /// Label for MQTT port
  ///
  /// In de, this message translates to:
  /// **'MQTT Port'**
  String get mqttPort;

  /// Label for MQTT topic
  ///
  /// In de, this message translates to:
  /// **'MQTT Topic'**
  String get mqttTopic;

  /// Label for MQTT username
  ///
  /// In de, this message translates to:
  /// **'MQTT Benutzername'**
  String get mqttUsername;

  /// Label for MQTT password
  ///
  /// In de, this message translates to:
  /// **'MQTT Passwort'**
  String get mqttPassword;

  /// Label for MQTT QoS level
  ///
  /// In de, this message translates to:
  /// **'QoS Level'**
  String get mqttQos;

  /// Title for authentication section
  ///
  /// In de, this message translates to:
  /// **'Authentifizierung'**
  String get authTitle;

  /// Label for authentication username
  ///
  /// In de, this message translates to:
  /// **'Benutzername'**
  String get authUsername;

  /// Label for authentication password
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get authPassword;

  /// Message when username cannot be changed
  ///
  /// In de, this message translates to:
  /// **'Benutzername kann nicht geändert werden'**
  String get authUsernameCannotBeChanged;

  /// Message when authentication is required
  ///
  /// In de, this message translates to:
  /// **'Authentifizierung erforderlich'**
  String get authRequired;

  /// Label for network IP address
  ///
  /// In de, this message translates to:
  /// **'IP-Adresse'**
  String get networkIpAddress;

  /// Label for network hostname
  ///
  /// In de, this message translates to:
  /// **'Hostname'**
  String get networkHostname;

  /// Label for network port
  ///
  /// In de, this message translates to:
  /// **'Port'**
  String get networkPort;

  /// Label for network subnet
  ///
  /// In de, this message translates to:
  /// **'Subnetz'**
  String get networkSubnet;

  /// Label for network gateway
  ///
  /// In de, this message translates to:
  /// **'Gateway'**
  String get networkGateway;

  /// Label for network DNS server
  ///
  /// In de, this message translates to:
  /// **'DNS Server'**
  String get networkDns;

  /// Menu subtitle for setting up network
  ///
  /// In de, this message translates to:
  /// **'Netzwerkverbindung einrichten'**
  String get menuSetupNetwork;

  /// Menu subtitle for setting up access point
  ///
  /// In de, this message translates to:
  /// **'WiFi Access Point einrichten'**
  String get menuSetupAccessPoint;

  /// Menu subtitle for setting up authentication
  ///
  /// In de, this message translates to:
  /// **'Benutzername und Passwort einrichten'**
  String get menuSetupAuth;

  /// Menu subtitle for limiting power
  ///
  /// In de, this message translates to:
  /// **'Ausgangsleistung begrenzen'**
  String get menuLimitPower;

  /// Menu subtitle for lamp and emergency outlet
  ///
  /// In de, this message translates to:
  /// **'Lampe und Notstromsteckdose'**
  String get menuLampAndEmergency;

  /// Menu subtitle for toggling inverters
  ///
  /// In de, this message translates to:
  /// **'Schaltet alle Wechselrichter'**
  String get menuToggleInverters;

  /// Menu subtitle for configuring device
  ///
  /// In de, this message translates to:
  /// **'Gerät konfigurieren'**
  String get menuConfigureDevice;

  /// Label for update interval
  ///
  /// In de, this message translates to:
  /// **'Aktualisierungsintervall'**
  String get intervalUpdateInterval;

  /// Label for seconds
  ///
  /// In de, this message translates to:
  /// **'Sekunden'**
  String get intervalSeconds;

  /// Hint for entering interval in seconds
  ///
  /// In de, this message translates to:
  /// **'Intervall (Sekunden)'**
  String get intervalEnterInterval;

  /// Help text for interval default and range
  ///
  /// In de, this message translates to:
  /// **'Standard: {defaultValue} Sekunden (Bereich: {min}-{max})'**
  String intervalDefaultRange(int defaultValue, int min, int max);

  /// Description for interval setting
  ///
  /// In de, this message translates to:
  /// **'Zeitintervall zwischen Datenabrufen vom Gerät'**
  String get intervalDescription;

  /// System metric: Grid
  ///
  /// In de, this message translates to:
  /// **'Netz'**
  String get systemGrid;

  /// System metric: Consumer
  ///
  /// In de, this message translates to:
  /// **'Verbraucher'**
  String get systemConsumer;

  /// System metric: Additional load
  ///
  /// In de, this message translates to:
  /// **'Zusätzliche Last'**
  String get systemAdditionalLoad;

  /// Label for inverter in system view
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter'**
  String get systemInverter;

  /// System metric: Battery
  ///
  /// In de, this message translates to:
  /// **'Batterie'**
  String get systemBattery;

  /// Label for solar panels in system view
  ///
  /// In de, this message translates to:
  /// **'Solarmodule'**
  String get systemSolarPanels;

  /// Label for device off state
  ///
  /// In de, this message translates to:
  /// **'Aus'**
  String get deviceOff;

  /// Label for device on state
  ///
  /// In de, this message translates to:
  /// **'Ein'**
  String get deviceOn;

  /// Label for device auto mode
  ///
  /// In de, this message translates to:
  /// **'Automatisch'**
  String get deviceAuto;

  /// Label for device manual mode
  ///
  /// In de, this message translates to:
  /// **'Manuell'**
  String get deviceManual;

  /// Label for resetting to defaults
  ///
  /// In de, this message translates to:
  /// **'Auf Standardwerte zurücksetzen'**
  String get deviceResetToDefaults;

  /// Label for factory reset
  ///
  /// In de, this message translates to:
  /// **'Werkseinstellungen'**
  String get deviceFactoryReset;

  /// Label for power range
  ///
  /// In de, this message translates to:
  /// **'Bereich: {min} - {max} W'**
  String powerRange(int min, int max);

  /// Label for power limit
  ///
  /// In de, this message translates to:
  /// **'Leistungsgrenze'**
  String get powerLimit;

  /// Label for power output
  ///
  /// In de, this message translates to:
  /// **'Ausgangsleistung'**
  String get powerOutput;

  /// Label for power input
  ///
  /// In de, this message translates to:
  /// **'Eingangsleistung'**
  String get powerInput;

  /// Label for power consumption
  ///
  /// In de, this message translates to:
  /// **'Verbrauch'**
  String get powerConsumption;

  /// Label for devices tab
  ///
  /// In de, this message translates to:
  /// **'Geräte'**
  String get tabDevices;

  /// Label for network tab
  ///
  /// In de, this message translates to:
  /// **'Netzwerk'**
  String get tabNetwork;

  /// Label for bluetooth tab
  ///
  /// In de, this message translates to:
  /// **'Bluetooth'**
  String get tabBluetooth;

  /// Label for systems tab
  ///
  /// In de, this message translates to:
  /// **'Systeme'**
  String get tabSystems;

  /// Label for settings tab
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get tabSettings;

  /// Label for range
  ///
  /// In de, this message translates to:
  /// **'Bereich'**
  String get miscRange;

  /// Label for default
  ///
  /// In de, this message translates to:
  /// **'Standard'**
  String get miscDefault;

  /// Label for optional
  ///
  /// In de, this message translates to:
  /// **'Optional'**
  String get miscOptional;

  /// Label for required
  ///
  /// In de, this message translates to:
  /// **'Erforderlich'**
  String get miscRequired;

  /// Action to remove a device
  ///
  /// In de, this message translates to:
  /// **'Gerät entfernen'**
  String get actionRemoveDevice;

  /// Confirmation message for removing a device
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie \"{deviceName}\" wirklich entfernen?'**
  String confirmRemoveDevice(String deviceName);

  /// Remove action button
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get actionRemove;

  /// Error message when removing fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Entfernen: {error}'**
  String errorWhileRemoving(String error);

  /// Action to create a new system
  ///
  /// In de, this message translates to:
  /// **'Neues System erstellen'**
  String get actionCreateNewSystem;

  /// Form label for system name
  ///
  /// In de, this message translates to:
  /// **'System-Name'**
  String get formSystemName;

  /// Create action button
  ///
  /// In de, this message translates to:
  /// **'Erstellen'**
  String get actionCreate;

  /// Title for my devices screen
  ///
  /// In de, this message translates to:
  /// **'Meine Geräte'**
  String get screenMyDevices;

  /// Title for systems screen
  ///
  /// In de, this message translates to:
  /// **'Systeme'**
  String get screenSystems;

  /// Action for live charts
  ///
  /// In de, this message translates to:
  /// **'Live-Diagramme'**
  String get actionLiveCharts;

  /// Action for more functions
  ///
  /// In de, this message translates to:
  /// **'Weitere Funktionen'**
  String get actionMoreFunctions;

  /// Empty state title when no devices
  ///
  /// In de, this message translates to:
  /// **'Keine Geräte'**
  String get emptyStateNoDevices;

  /// Empty state message to add first device
  ///
  /// In de, this message translates to:
  /// **'Fügen Sie Ihr erstes Gerät hinzu'**
  String get emptyStateAddFirstDevice;

  /// Action to add a device
  ///
  /// In de, this message translates to:
  /// **'Gerät hinzufügen'**
  String get actionAddDevice;

  /// Label for device
  ///
  /// In de, this message translates to:
  /// **'Gerät'**
  String get labelDevice;

  /// Empty state when no device is selected
  ///
  /// In de, this message translates to:
  /// **'Kein Gerät ausgewählt'**
  String get emptyStateNoDeviceSelected;

  /// Action to add a system
  ///
  /// In de, this message translates to:
  /// **'System hinzufügen'**
  String get actionAddSystem;

  /// Label for permissions
  ///
  /// In de, this message translates to:
  /// **'Berechtigungen'**
  String get labelPermissions;

  /// Error when no WiFi/LAN connection
  ///
  /// In de, this message translates to:
  /// **'Netzwerk-Scan ist nur über WiFi oder LAN möglich.\n\nBitte verbinden Sie sich mit einem WiFi-Netzwerk oder LAN und versuchen Sie es erneut.'**
  String get errorNoWifiLanConnection;

  /// Title for no WiFi/LAN connection error
  ///
  /// In de, this message translates to:
  /// **'Keine WiFi/LAN-Verbindung'**
  String get titleNoWifiLanConnection;

  /// Error when no private network found
  ///
  /// In de, this message translates to:
  /// **'Keine privaten Netzwerke gefunden.\n\nGefundene IPs: {ips}\n\nStellen Sie sicher, dass Sie mit einem lokalen Netzwerk verbunden sind.'**
  String errorNoPrivateNetwork(String ips);

  /// Title for no private network error
  ///
  /// In de, this message translates to:
  /// **'Kein privates Netzwerk'**
  String get titleNoPrivateNetwork;

  /// Generic network scan error
  ///
  /// In de, this message translates to:
  /// **'Netzwerk-Scan Fehler'**
  String get errorNetworkScan;

  /// Error message when not connected to WiFi
  ///
  /// In de, this message translates to:
  /// **'Nicht mit WiFi verbunden. Bitte WiFi aktivieren.'**
  String get errorNotConnectedToWifi;

  /// Network scan error with details
  ///
  /// In de, this message translates to:
  /// **'Netzwerk-Scan Fehler: {error}'**
  String errorNetworkScanWithDetails(String error);

  /// Warning about public network
  ///
  /// In de, this message translates to:
  /// **'Ihre aktuelle IP-Adresse scheint nicht in einem privaten Netzwerk zu sein.\n\nAktuelle IP: {currentIp}\n\nDas Scannen von öffentlichen IP-Bereichen ist möglicherweise nicht sinnvoll. Stellen Sie sicher, dass Sie mit einem lokalen WiFi-Netzwerk verbunden sind.\n\nMöchten Sie trotzdem fortfahren?'**
  String warningPublicNetwork(String currentIp);

  /// Title for public network warning
  ///
  /// In de, this message translates to:
  /// **'Warnung: Öffentliches Netzwerk'**
  String get titleWarningPublicNetwork;

  /// OK, continue action
  ///
  /// In de, this message translates to:
  /// **'OK, Fortfahren'**
  String get actionOkContinue;

  /// Message when IP and port updated
  ///
  /// In de, this message translates to:
  /// **'IP-Adresse wurde von {oldIp}:{oldPort} auf {newIp}:{newPort} aktualisiert'**
  String messageIpUpdated(
    String oldIp,
    String oldPort,
    String newIp,
    String newPort,
  );

  /// Message when IP address updated
  ///
  /// In de, this message translates to:
  /// **'IP-Adresse wurde von {oldIp} auf {newIp} aktualisiert'**
  String messageIpAddressUpdated(String oldIp, String newIp);

  /// Message when port was updated
  ///
  /// In de, this message translates to:
  /// **'Port wurde von {oldPort} auf {newPort} aktualisiert'**
  String messagePortUpdated(String oldPort, String newPort);

  /// Loading message while saving device
  ///
  /// In de, this message translates to:
  /// **'Gerät wird gespeichert...'**
  String get messageSavingDevice;

  /// Loading message while connecting to device
  ///
  /// In de, this message translates to:
  /// **'Verbinde zu Gerät...'**
  String get messageConnectingToDevice;

  /// Label for known device
  ///
  /// In de, this message translates to:
  /// **'Gerät bekannt'**
  String get labelDeviceKnown;

  /// Label for known device with new address
  ///
  /// In de, this message translates to:
  /// **'Bekannt (neue Adresse)'**
  String get labelKnownNewAddress;

  /// Label for found devices
  ///
  /// In de, this message translates to:
  /// **'Gefunden'**
  String get labelFound;

  /// Label for known devices
  ///
  /// In de, this message translates to:
  /// **'Bekannte Geräte'**
  String get labelKnownDevices;

  /// Label for tested devices
  ///
  /// In de, this message translates to:
  /// **'Geprüft'**
  String get labelTested;

  /// Label for remaining devices
  ///
  /// In de, this message translates to:
  /// **'Verbleibend'**
  String get labelRemaining;

  /// Label for known
  ///
  /// In de, this message translates to:
  /// **'Bekannt'**
  String get labelKnown;

  /// Label for devices left
  ///
  /// In de, this message translates to:
  /// **'Übrig'**
  String get labelLeft;

  /// Action to update IP address
  ///
  /// In de, this message translates to:
  /// **'IP Aktualisieren'**
  String get actionUpdateIp;

  /// Action to add devices
  ///
  /// In de, this message translates to:
  /// **'Geräte hinzufügen'**
  String get actionAddDevices;

  /// Action to inspect device
  ///
  /// In de, this message translates to:
  /// **'Gerät inspizieren'**
  String get actionInspectDevice;

  /// Action to choose a role
  ///
  /// In de, this message translates to:
  /// **'Rolle wählen'**
  String get actionChooseRole;

  /// Action to create a system
  ///
  /// In de, this message translates to:
  /// **'System erstellen'**
  String get actionCreateSystem;

  /// Action to delete a system
  ///
  /// In de, this message translates to:
  /// **'System löschen'**
  String get actionDeleteSystem;

  /// Error message when device has no role configuration
  ///
  /// In de, this message translates to:
  /// **'Gerät hat keine Rollen-Konfiguration'**
  String get messageDeviceHasNoRoleConfig;

  /// Error message when device has no configurable roles
  ///
  /// In de, this message translates to:
  /// **'Gerät hat keine konfigurierbaren Rollen'**
  String get messageDeviceHasNoConfigurableRoles;

  /// Warning message when device is already in system
  ///
  /// In de, this message translates to:
  /// **'Gerät bereits im System'**
  String get messageDeviceAlreadyInSystem;

  /// Success message when device is added with roles
  ///
  /// In de, this message translates to:
  /// **'Gerät \"{name}\" hinzugefügt mit Rolle(n): {roles}'**
  String messageDeviceAddedWithRoles(String name, String roles);

  /// Success message when device is removed
  ///
  /// In de, this message translates to:
  /// **'Gerät entfernt'**
  String get messageDeviceRemoved;

  /// Message shown when system has no devices
  ///
  /// In de, this message translates to:
  /// **'Keine Geräte im System'**
  String get messageNoDevicesInSystem;

  /// Help message prompting to add devices
  ///
  /// In de, this message translates to:
  /// **'Fügen Sie Geräte hinzu, um Metriken zu sehen.'**
  String get messageAddDevicesToSeeMetrics;

  /// Message shown when no devices have data
  ///
  /// In de, this message translates to:
  /// **'Keine aktiven Geräte mit Daten'**
  String get messageNoActiveDevicesWithData;

  /// Message shown when there are no systems
  ///
  /// In de, this message translates to:
  /// **'Keine Systeme'**
  String get messageNoSystems;

  /// Prompt to create first system
  ///
  /// In de, this message translates to:
  /// **'Erstellen Sie Ihr erstes System'**
  String get messageCreateYourFirstSystem;

  /// Confirmation dialog for removing device with roles
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie \"{name}\" mit {count} Rolle(n) ({roles}) aus diesem System entfernen?'**
  String confirmRemoveDeviceWithRoles(String name, int count, String roles);

  /// Confirmation dialog for removing unknown device
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie dieses Gerät mit {count} Rolle(n) ({roles}) aus dem System entfernen?'**
  String confirmRemoveUnknownDeviceWithRoles(int count, String roles);

  /// Confirmation dialog for deleting system
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie \"{name}\" wirklich löschen?'**
  String confirmDeleteSystem(String name);

  /// Screen title for editing system
  ///
  /// In de, this message translates to:
  /// **'{name} bearbeiten'**
  String screenEditSystem(String name);

  /// Screen title for creating new system
  ///
  /// In de, this message translates to:
  /// **'Neues System erstellen'**
  String get screenCreateNewSystem;

  /// Label for roles
  ///
  /// In de, this message translates to:
  /// **'Rollen: {roles}'**
  String labelRoles(String roles);

  /// Label for device count
  ///
  /// In de, this message translates to:
  /// **'{count} Geräte'**
  String labelDevicesCount(int count);

  /// Label with device count in parentheses
  ///
  /// In de, this message translates to:
  /// **'Geräte ({count})'**
  String labelDevicesWithCount(int count);

  /// Status message when device with serial number is not found
  ///
  /// In de, this message translates to:
  /// **'Gerät {sn} nicht gefunden'**
  String statusDeviceNotFoundWithSn(String sn);

  /// System metric: Solar production
  ///
  /// In de, this message translates to:
  /// **'Solar-Produktion'**
  String get systemSolarProduction;

  /// System metric: Solar to grid
  ///
  /// In de, this message translates to:
  /// **'Solar ins Netz'**
  String get systemSolarToGrid;

  /// Label for active status
  ///
  /// In de, this message translates to:
  /// **'aktiv'**
  String get active;

  /// Error title for no WiFi/LAN connection
  ///
  /// In de, this message translates to:
  /// **'Keine WiFi/LAN-Verbindung'**
  String get errorNoWifiLanConnectionTitle;

  /// Error title for no private network
  ///
  /// In de, this message translates to:
  /// **'Kein privates Netzwerk'**
  String get errorNoPrivateNetworkTitle;

  /// Message showing number of devices found in network
  ///
  /// In de, this message translates to:
  /// **'{count} Geräte im Netzwerk gefunden'**
  String messageDevicesFoundInNetwork(int count);

  /// Error message for network scan error
  ///
  /// In de, this message translates to:
  /// **'Netzwerk-Scan Fehler'**
  String get errorNetworkScanError;

  /// Error message for network scan failure
  ///
  /// In de, this message translates to:
  /// **'Netzwerk-Scan Fehler: {error}'**
  String errorNetworkScanFailed(String error);

  /// Warning title for public network
  ///
  /// In de, this message translates to:
  /// **'Warnung: Öffentliches Netzwerk'**
  String get warningPublicNetworkTitle;

  /// Action to continue anyway
  ///
  /// In de, this message translates to:
  /// **'OK, Fortfahren'**
  String get actionContinueAnyway;

  /// Message when only IP was updated
  ///
  /// In de, this message translates to:
  /// **'IP-Adresse wurde von {oldIp} auf {newIp} aktualisiert'**
  String messageIpOnlyUpdated(String oldIp, String newIp);

  /// Label for known device
  ///
  /// In de, this message translates to:
  /// **'Gerät bekannt'**
  String get labelKnownDevice;

  /// Generic device label
  ///
  /// In de, this message translates to:
  /// **'Gerät'**
  String get device;

  /// Action to update
  ///
  /// In de, this message translates to:
  /// **'Aktualisieren'**
  String get actionUpdate;

  /// Prompt to start scan to find devices
  ///
  /// In de, this message translates to:
  /// **'Starten Sie einen Scan um Geräte zu finden'**
  String get startScanToFindDevices;

  /// Message when searching for known devices
  ///
  /// In de, this message translates to:
  /// **'Suche nach bekannten Geräten...'**
  String get messageSearchingForKnownDevices;

  /// Bluetooth label
  ///
  /// In de, this message translates to:
  /// **'Bluetooth'**
  String get bluetooth;

  /// Network label
  ///
  /// In de, this message translates to:
  /// **'Netzwerk'**
  String get network;

  /// Label for Bluetooth devices
  ///
  /// In de, this message translates to:
  /// **'Bluetooth-Geräte'**
  String get labelBluetoothDevices;

  /// Help text for scanning nearby devices
  ///
  /// In de, this message translates to:
  /// **'Scannen Sie nach Geräten in der Nähe (Zendure, Shelly)'**
  String get helpScanForNearbyDevices;

  /// Message when scanning
  ///
  /// In de, this message translates to:
  /// **'Scannt...'**
  String get messageScanning;

  /// Action to perform Bluetooth scan
  ///
  /// In de, this message translates to:
  /// **'Bluetooth-Scan'**
  String get actionBluetoothScan;

  /// Label for network devices
  ///
  /// In de, this message translates to:
  /// **'Netzwerk-Geräte'**
  String get labelNetworkDevices;

  /// Help text for scanning local network
  ///
  /// In de, this message translates to:
  /// **'Scannen Sie Ihr lokales Netzwerk nach Geräten'**
  String get helpScanLocalNetwork;

  /// Action to perform network scan
  ///
  /// In de, this message translates to:
  /// **'Netzwerk-Scan'**
  String get actionNetworkScan;

  /// Manual action
  ///
  /// In de, this message translates to:
  /// **'Manuell'**
  String get actionManual;

  /// Remove action
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get remove;

  /// Create action
  ///
  /// In de, this message translates to:
  /// **'Erstellen'**
  String get create;

  /// Screen title for device information
  ///
  /// In de, this message translates to:
  /// **'Geräteinformationen'**
  String get screenDeviceInfo;

  /// Message when no information is available
  ///
  /// In de, this message translates to:
  /// **'Keine Informationen verfügbar'**
  String get messageNoInformationAvailable;

  /// Yes label
  ///
  /// In de, this message translates to:
  /// **'Ja'**
  String get yes;

  /// No label
  ///
  /// In de, this message translates to:
  /// **'Nein'**
  String get no;

  /// Title for live graphs screen
  ///
  /// In de, this message translates to:
  /// **'Live-Diagramme'**
  String get screenLiveGraphs;

  /// Title for app info screen
  ///
  /// In de, this message translates to:
  /// **'App-Informationen'**
  String get screenAppInfo;

  /// Title for power limit screen
  ///
  /// In de, this message translates to:
  /// **'Leistungslimit einstellen'**
  String get screenPowerLimit;

  /// Title for advanced power settings screen
  ///
  /// In de, this message translates to:
  /// **'Erweiterte Leistungseinstellungen'**
  String get screenAdvancedPowerSettings;

  /// Title for port configuration screen
  ///
  /// In de, this message translates to:
  /// **'{portName}'**
  String screenPortConfiguration(String portName);

  /// Title for percentage power limit screen
  ///
  /// In de, this message translates to:
  /// **'Leistungsbegrenzung'**
  String get screenPercentagePowerLimit;

  /// Title for online monitoring screen
  ///
  /// In de, this message translates to:
  /// **'Online-Monitoring konfigurieren'**
  String get screenOnlineMonitoring;

  /// Title for battery SOC screen
  ///
  /// In de, this message translates to:
  /// **'Batterie-Limits einstellen'**
  String get screenBatterySoc;

  /// Title for power screen
  ///
  /// In de, this message translates to:
  /// **'Leistung einstellen'**
  String get screenPower;

  /// Title for Zendure WiFi MQTT configuration screen
  ///
  /// In de, this message translates to:
  /// **'MQTT Konfiguration'**
  String get screenZendureWifiMqtt;

  /// Title for OpenDTU online monitoring screen
  ///
  /// In de, this message translates to:
  /// **'Online-Monitoring'**
  String get screenOpenDtuOnlineMonitoring;

  /// Validation error for empty SSID
  ///
  /// In de, this message translates to:
  /// **'SSID darf nicht leer sein'**
  String get validationSsidRequired;

  /// Validation error for empty password
  ///
  /// In de, this message translates to:
  /// **'Passwort darf nicht leer sein'**
  String get validationPasswordRequired;

  /// Validation error for empty port
  ///
  /// In de, this message translates to:
  /// **'Port darf nicht leer sein'**
  String get validationPortRequired;

  /// Validation error for port range
  ///
  /// In de, this message translates to:
  /// **'Port muss eine Zahl zwischen 1 und 65535 sein'**
  String get validationPortRange;

  /// Validation error for empty username
  ///
  /// In de, this message translates to:
  /// **'Benutzername darf nicht leer sein'**
  String get validationUsernameRequired;

  /// Validation error for empty password field
  ///
  /// In de, this message translates to:
  /// **'Passwort darf nicht leer sein'**
  String get validationPasswordEmpty;

  /// Validation error for min/max SOC
  ///
  /// In de, this message translates to:
  /// **'Minimum SOC muss kleiner als Maximum SOC sein'**
  String get validationMinSocLessThanMax;

  /// Validation error for empty primary server
  ///
  /// In de, this message translates to:
  /// **'Primärer Server URL ist erforderlich'**
  String get validationPrimaryServerRequired;

  /// Validation error for invalid primary URL
  ///
  /// In de, this message translates to:
  /// **'Ungültige primäre Server URL (kein Protokoll http:// oder https:// verwenden)'**
  String get validationPrimaryUrlInvalid;

  /// Validation error for empty system ID
  ///
  /// In de, this message translates to:
  /// **'System-ID ist erforderlich'**
  String get validationSystemIdRequired;

  /// Validation error for empty token
  ///
  /// In de, this message translates to:
  /// **'Token/Passwort ist erforderlich'**
  String get validationTokenRequired;

  /// Validation error for invalid secondary URL
  ///
  /// In de, this message translates to:
  /// **'Ungültige sekundäre Server URL (kein Protokoll http:// oder https:// verwenden)'**
  String get validationSecondaryUrlInvalid;

  /// Validation error for invalid primary port
  ///
  /// In de, this message translates to:
  /// **'Ungültiger primärer Port (1-65535)'**
  String get validationPrimaryPortInvalid;

  /// Validation error for invalid secondary port
  ///
  /// In de, this message translates to:
  /// **'Ungültiger sekundärer Port (1-65535)'**
  String get validationSecondaryPortInvalid;

  /// Validation error for upload interval range
  ///
  /// In de, this message translates to:
  /// **'Upload-Intervall muss zwischen 1 und 3600 Sekunden liegen'**
  String get validationUploadIntervalRange;

  /// Validation error for empty server A IP
  ///
  /// In de, this message translates to:
  /// **'Server A: IP-Adresse oder Domain muss angegeben werden'**
  String get validationServerAIpRequired;

  /// Validation error for invalid server A IP
  ///
  /// In de, this message translates to:
  /// **'Server A: Ungültige IP-Adresse'**
  String get validationServerAIpInvalid;

  /// Validation error for server A port range
  ///
  /// In de, this message translates to:
  /// **'Server A: Port muss zwischen 1 und 65534 liegen'**
  String get validationServerAPortRange;

  /// Validation error for empty server B IP
  ///
  /// In de, this message translates to:
  /// **'Server B: IP-Adresse oder Domain muss angegeben werden'**
  String get validationServerBIpRequired;

  /// Validation error for invalid server B IP
  ///
  /// In de, this message translates to:
  /// **'Server B: Ungültige IP-Adresse'**
  String get validationServerBIpInvalid;

  /// Validation error for server B port range
  ///
  /// In de, this message translates to:
  /// **'Server B: Port muss zwischen 1 und 65534 liegen'**
  String get validationServerBPortRange;

  /// Success message when copied to clipboard
  ///
  /// In de, this message translates to:
  /// **'In Zwischenablage kopiert'**
  String get messageCopiedToClipboard;

  /// Success message when WiFi config sent
  ///
  /// In de, this message translates to:
  /// **'WiFi-Konfiguration erfolgreich gesendet!'**
  String get messageWifiConfigSent;

  /// Success message when port configured
  ///
  /// In de, this message translates to:
  /// **'{portName} erfolgreich konfiguriert'**
  String messagePortConfigured(String portName);

  /// Success message when power limit set with value
  ///
  /// In de, this message translates to:
  /// **'Leistungseinstellungen erfolgreich gesetzt: {value} W'**
  String messagePowerLimitSetWithValue(String value);

  /// Success message when power percentage set
  ///
  /// In de, this message translates to:
  /// **'Leistungsbegrenzung auf {percentage}% gesetzt'**
  String messagePowerPercentageSet(String percentage);

  /// Success message when battery limits set
  ///
  /// In de, this message translates to:
  /// **'Batterie-Limits erfolgreich gesetzt: Min {min}%, Max {max}%'**
  String messageBatteryLimitsSet(String min, String max);

  /// Success message when online monitoring configured
  ///
  /// In de, this message translates to:
  /// **'Online-Monitoring erfolgreich konfiguriert'**
  String get messageOnlineMonitoringConfigured;

  /// Success message when setting updated
  ///
  /// In de, this message translates to:
  /// **'{settingName} wurde aktualisiert'**
  String messageSettingUpdated(String settingName);

  /// Success message when authentication enabled
  ///
  /// In de, this message translates to:
  /// **'Authentifizierung wurde aktiviert'**
  String get messageAuthEnabled;

  /// Success message when authentication disabled
  ///
  /// In de, this message translates to:
  /// **'Authentifizierung wurde deaktiviert'**
  String get messageAuthDisabled;

  /// Error message when sending fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Senden: {error}'**
  String errorWhileSending(String error);

  /// Error message when configuring port fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Konfigurieren des Ports: {error}'**
  String errorConfiguringPort(String error);

  /// Error message when setting power limit fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Setzen der Einstellungen: {error}'**
  String errorSettingPowerLimit(String error);

  /// Error message when setting percentage limit fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Setzen der Leistungsbegrenzung: {error}'**
  String errorSettingPercentageLimit(String error);

  /// Error message when setting battery limits fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Setzen der Batterie-Limits: {error}'**
  String errorSettingBatteryLimits(String error);

  /// Error message when configuring online monitoring fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Konfigurieren des Online-Monitorings: {error}'**
  String errorConfiguringOnlineMonitoring(String error);

  /// Error message when changing setting fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Ändern der Einstellung: {error}'**
  String errorChangingSetting(String error);

  /// Error message when saving authentication fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Speichern der Authentifizierung: {error}'**
  String errorSavingAuth(String error);

  /// Section title for network setup
  ///
  /// In de, this message translates to:
  /// **'Netzwerk einrichten'**
  String get sectionNetworkSetup;

  /// Section title for MQTT configuration
  ///
  /// In de, this message translates to:
  /// **'MQTT Konfiguration'**
  String get sectionMqttConfig;

  /// Section title for note
  ///
  /// In de, this message translates to:
  /// **'Hinweis'**
  String get sectionNote;

  /// Section title for limit type
  ///
  /// In de, this message translates to:
  /// **'Limit-Typ'**
  String get sectionLimitType;

  /// Section title for current value
  ///
  /// In de, this message translates to:
  /// **'Aktueller Wert'**
  String get sectionCurrentValue;

  /// Section title for adjust limit
  ///
  /// In de, this message translates to:
  /// **'Limit anpassen'**
  String get sectionAdjustLimit;

  /// Section title for current settings
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Einstellungen'**
  String get sectionCurrentSettings;

  /// Section title for max inverter power
  ///
  /// In de, this message translates to:
  /// **'Max Wechselrichter Leistung'**
  String get sectionMaxInverterPower;

  /// Section title for precise input
  ///
  /// In de, this message translates to:
  /// **'Präzise Eingabe'**
  String get sectionPreciseInput;

  /// Section title for grid feedback
  ///
  /// In de, this message translates to:
  /// **'Netzrückspeisung'**
  String get sectionGridFeedback;

  /// Section title for grid standard
  ///
  /// In de, this message translates to:
  /// **'Netzstandard'**
  String get sectionGridStandard;

  /// Section title for port number
  ///
  /// In de, this message translates to:
  /// **'Port-Nummer'**
  String get sectionPortNumber;

  /// Section title for percentage limit
  ///
  /// In de, this message translates to:
  /// **'Leistungsbegrenzung in Prozent'**
  String get sectionPercentageLimit;

  /// Section title for watt limit
  ///
  /// In de, this message translates to:
  /// **'Leistungsbegrenzung in Watt'**
  String get sectionWattLimit;

  /// Section title for device information
  ///
  /// In de, this message translates to:
  /// **'Geräteinformationen'**
  String get sectionDeviceInfo;

  /// Section title for online monitoring
  ///
  /// In de, this message translates to:
  /// **'Online-Monitoring'**
  String get sectionOnlineMonitoring;

  /// Section title for primary server
  ///
  /// In de, this message translates to:
  /// **'Primärer Server'**
  String get sectionPrimaryServer;

  /// Section title for secondary server
  ///
  /// In de, this message translates to:
  /// **'Sekundärer Server'**
  String get sectionSecondaryServer;

  /// Section title for credentials
  ///
  /// In de, this message translates to:
  /// **'Zugangsdaten'**
  String get sectionCredentials;

  /// Section title for server A
  ///
  /// In de, this message translates to:
  /// **'Server A (Hauptserver)'**
  String get sectionServerA;

  /// Section title for server B
  ///
  /// In de, this message translates to:
  /// **'Server B (Sekundärserver)'**
  String get sectionServerB;

  /// Section title for general settings
  ///
  /// In de, this message translates to:
  /// **'Allgemeine Einstellungen'**
  String get sectionGeneralSettings;

  /// Section title for current values
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Werte'**
  String get sectionCurrentValues;

  /// Section title for minimum SOC
  ///
  /// In de, this message translates to:
  /// **'Minimum SOC'**
  String get sectionMinSoc;

  /// Section title for maximum SOC
  ///
  /// In de, this message translates to:
  /// **'Maximum SOC'**
  String get sectionMaxSoc;

  /// Section title for authentication configuration
  ///
  /// In de, this message translates to:
  /// **'Authentifizierung konfigurieren'**
  String get sectionAuthConfig;

  /// Section title for username
  ///
  /// In de, this message translates to:
  /// **'Benutzername'**
  String get sectionUsername;

  /// Section title for password
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get sectionPassword;

  /// Button label for copy
  ///
  /// In de, this message translates to:
  /// **'Kopieren'**
  String get buttonCopy;

  /// Button label for configure WiFi
  ///
  /// In de, this message translates to:
  /// **'WiFi konfigurieren'**
  String get buttonConfigureWifi;

  /// Button label for save power limit
  ///
  /// In de, this message translates to:
  /// **'Leistungsbegrenzung speichern'**
  String get buttonSavePowerLimit;

  /// Button label for deactivate
  ///
  /// In de, this message translates to:
  /// **'Deaktivieren'**
  String get buttonDeactivate;

  /// Segment label for disabled
  ///
  /// In de, this message translates to:
  /// **'Deaktiviert'**
  String get segmentDisabled;

  /// Segment label for allowed
  ///
  /// In de, this message translates to:
  /// **'Erlaubt'**
  String get segmentAllowed;

  /// Segment label for forbidden
  ///
  /// In de, this message translates to:
  /// **'Verboten'**
  String get segmentForbidden;

  /// Segment label for Germany
  ///
  /// In de, this message translates to:
  /// **'Deutschland'**
  String get segmentGermany;

  /// Segment label for France
  ///
  /// In de, this message translates to:
  /// **'Frankreich'**
  String get segmentFrance;

  /// Segment label for Austria
  ///
  /// In de, this message translates to:
  /// **'Österreich'**
  String get segmentAustria;

  /// Label for max inverter power
  ///
  /// In de, this message translates to:
  /// **'Max Wechselrichter Leistung'**
  String get labelMaxInverterPower;

  /// Label for grid feedback
  ///
  /// In de, this message translates to:
  /// **'Rückspeisung'**
  String get labelGridFeedback;

  /// Label for grid standard
  ///
  /// In de, this message translates to:
  /// **'Netzstandard'**
  String get labelGridStandard;

  /// Label for power in watts
  ///
  /// In de, this message translates to:
  /// **'Leistung in Watt'**
  String get labelPowerInWatts;

  /// Label for percent
  ///
  /// In de, this message translates to:
  /// **'Prozent'**
  String get labelPercent;

  /// Label for watt
  ///
  /// In de, this message translates to:
  /// **'Watt'**
  String get labelWatt;

  /// Label for minimum
  ///
  /// In de, this message translates to:
  /// **'Minimum'**
  String get labelMinimum;

  /// Label for maximum
  ///
  /// In de, this message translates to:
  /// **'Maximum'**
  String get labelMaximum;

  /// Label for min SOC
  ///
  /// In de, this message translates to:
  /// **'Min SOC'**
  String get labelMinSoc;

  /// Label for max SOC
  ///
  /// In de, this message translates to:
  /// **'Max SOC'**
  String get labelMaxSoc;

  /// Label for protocol with required marker
  ///
  /// In de, this message translates to:
  /// **'Protokoll{required}'**
  String labelProtocol(String required);

  /// Label for server URL with required marker
  ///
  /// In de, this message translates to:
  /// **'Server-URL{required}'**
  String labelServerUrl(String required);

  /// Label for port field
  ///
  /// In de, this message translates to:
  /// **'Port'**
  String get labelPortField;

  /// Label for system ID
  ///
  /// In de, this message translates to:
  /// **'System-ID *'**
  String get labelSystemId;

  /// Label for token/password
  ///
  /// In de, this message translates to:
  /// **'Token/Passwort *'**
  String get labelToken;

  /// Label for upload interval
  ///
  /// In de, this message translates to:
  /// **'Upload-Intervall (Sekunden)'**
  String get labelUploadInterval;

  /// Label for IP address
  ///
  /// In de, this message translates to:
  /// **'IP-Adresse'**
  String get labelIpAddress;

  /// Label for domain
  ///
  /// In de, this message translates to:
  /// **'Domain'**
  String get labelDomain;

  /// Label for username
  ///
  /// In de, this message translates to:
  /// **'Benutzername'**
  String get labelUsername;

  /// Label for password
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get labelPassword;

  /// Label for required field
  ///
  /// In de, this message translates to:
  /// **'Erforderlich'**
  String get labelRequiredField;

  /// Label for optional field
  ///
  /// In de, this message translates to:
  /// **'Optional'**
  String get labelOptionalField;

  /// Label for input limit
  ///
  /// In de, this message translates to:
  /// **'Input (Netz → Gerät)'**
  String get labelInputLimit;

  /// Label for output limit
  ///
  /// In de, this message translates to:
  /// **'Output (Gerät → Netz)'**
  String get labelOutputLimit;

  /// Label for unknown
  ///
  /// In de, this message translates to:
  /// **'Unbekannt'**
  String get labelUnknown;

  /// Help text for connecting device to WiFi
  ///
  /// In de, this message translates to:
  /// **'Verbinden Sie Ihr Gerät mit Ihrem WLAN-Netzwerk,'**
  String get helpConnectDeviceToWifi;

  /// Help text with WiFi setup instructions
  ///
  /// In de, this message translates to:
  /// **'• Stellen Sie sicher, dass Ihr Gerät eingeschaltet ist\n• Das WLAN-Passwort wird sicher übertragen\n• Nach erfolgreicher Konfiguration kann es einige Sekunden dauern, bis das Gerät verbunden ist'**
  String get helpWifiSetupInstructions;

  /// Help text explaining MQTT configuration
  ///
  /// In de, this message translates to:
  /// **'Dies ist für die offizielle App Web-Kommunikation, nicht für lokales MQTT. Bei alten Versionen war es der einzige Weg, um Daten zu bekommen. Nur ändern, wenn Sie wissen, was Sie tun!'**
  String get helpMqttExplanation;

  /// Help text with MQTT server example
  ///
  /// In de, this message translates to:
  /// **'z.B. broker.example.com:1883'**
  String get helpMqttServerExample;

  /// Help text asking to wait
  ///
  /// In de, this message translates to:
  /// **'Bitte warten Sie einen Moment'**
  String get helpPleaseWait;

  /// Help text when input limit not available
  ///
  /// In de, this message translates to:
  /// **'Input-Limit ist nicht verfügbar'**
  String get helpInputNotAvailable;

  /// Help text showing power range
  ///
  /// In de, this message translates to:
  /// **'Bereich: 0 - {maxValue} W'**
  String helpPowerRange(String maxValue);

  /// Help text for watt value range
  ///
  /// In de, this message translates to:
  /// **'Wert zwischen 1 und 100'**
  String get helpWattValue;

  /// Help text showing max watt
  ///
  /// In de, this message translates to:
  /// **'Max: {maxWatt} W (entspricht 100%)'**
  String helpMaxWatt(String maxWatt);

  /// Help text about watt value rounding
  ///
  /// In de, this message translates to:
  /// **'Watt-Werte werden auf volle Prozentschritte gerundet'**
  String get helpWattRounding;

  /// Help text showing nominal power
  ///
  /// In de, this message translates to:
  /// **'Nennleistung: {maxWatt} W'**
  String helpNominalPower(String maxWatt);

  /// Help text showing current limit
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Begrenzung: {watt} W ({percentage}%)'**
  String helpCurrentLimit(String watt, String percentage);

  /// Help text describing grid feedback
  ///
  /// In de, this message translates to:
  /// **'Bestimmt, ob Energie ins Netz eingespeist werden darf'**
  String get helpGridFeedbackDescription;

  /// Help text describing grid standard
  ///
  /// In de, this message translates to:
  /// **'Netzanschluss-Standard für Ihr Land'**
  String get helpGridStandardDescription;

  /// Help text showing port range
  ///
  /// In de, this message translates to:
  /// **'Port muss zwischen 1 und 65535 liegen'**
  String get helpPortRange;

  /// Help text with port configuration warnings
  ///
  /// In de, this message translates to:
  /// **'• Stellen Sie sicher, dass der Port nicht von anderen Diensten verwendet wird\n• Nach der Konfiguration wird das Gerät möglicherweise neu gestartet\n• Standard-Ports sollten nur geändert werden, wenn notwendig'**
  String get helpPortWarning;

  /// Help text showing current percentage limit
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Begrenzung: {limit}%'**
  String helpCurrentPercentageLimit(String limit);

  /// Help text for server URL format
  ///
  /// In de, this message translates to:
  /// **'Ohne http:// oder https://'**
  String get helpServerUrlFormat;

  /// Help text showing default port
  ///
  /// In de, this message translates to:
  /// **'Standard: {port}'**
  String helpDefaultPort(String port);

  /// Help text about default ports in URL
  ///
  /// In de, this message translates to:
  /// **'Standard-Ports werden nicht in URL angezeigt'**
  String get helpDefaultPortNote;

  /// Help text for configuring online monitoring
  ///
  /// In de, this message translates to:
  /// **'Konfigurieren Sie die Server für das Online-Monitoring'**
  String get helpConfigureOnlineMonitoring;

  /// Help text with online monitoring instructions
  ///
  /// In de, this message translates to:
  /// **'• Geben Sie die URL des Monitoring-Servers ein\n• Tragen Sie Ihre Zugangsdaten ein\n• Optional können Sie einen zweiten Server konfigurieren\n• Das Upload-Intervall bestimmt, wie oft Daten gesendet werden\n• Nach der Konfiguration werden Daten automatisch hochgeladen'**
  String get helpOnlineMonitoringInstructions;

  /// Help text with server IP example
  ///
  /// In de, this message translates to:
  /// **'z.B. 192.168.1.100'**
  String get helpServerExampleIp;

  /// Help text with server domain example
  ///
  /// In de, this message translates to:
  /// **'z.B. monitoring.example.com'**
  String get helpServerExampleDomain;

  /// Help text with port example
  ///
  /// In de, this message translates to:
  /// **'z.B. 10000'**
  String get helpPortExample;

  /// Help text with system ID example
  ///
  /// In de, this message translates to:
  /// **'z.B. 1234'**
  String get helpSystemIdExample;

  /// Help text with upload interval example
  ///
  /// In de, this message translates to:
  /// **'z.B. 30'**
  String get helpUploadIntervalExample;

  /// Help text with protocol example
  ///
  /// In de, this message translates to:
  /// **'z.B. solar.pihost.org'**
  String get helpProtocolExample;

  /// Help text describing online monitoring configuration
  ///
  /// In de, this message translates to:
  /// **'• Stellen Sie sicher, dass die Server-URLs korrekt sind\n• Optional: Sekundärer Server als Backup\n• Upload-Intervall: 1-3600 Sekunden\n• Änderungen werden sofort übernommen'**
  String get helpOnlineMonitoringDescription;

  /// Help text for managing device settings
  ///
  /// In de, this message translates to:
  /// **'Verwalten Sie die grundlegenden Einstellungen Ihres Geräts.'**
  String get helpManageDeviceSettings;

  /// Help text when no settings available
  ///
  /// In de, this message translates to:
  /// **'Keine Einstellungen verfügbar'**
  String get helpNoSettingsAvailable;

  /// Help text about settings applying immediately
  ///
  /// In de, this message translates to:
  /// **'Änderungen werden sofort auf das Gerät übertragen. Einstellungen mit Bestätigungsanforderung zeigen einen Dialog vor der Änderung an.'**
  String get helpSettingsApplyImmediately;

  /// Help text indicating confirmation required
  ///
  /// In de, this message translates to:
  /// **'Bestätigung erforderlich'**
  String get helpConfirmationRequired;

  /// Help text for protecting device
  ///
  /// In de, this message translates to:
  /// **'Schützen Sie Ihr Gerät mit Benutzername und Passwort.'**
  String get helpProtectDevice;

  /// Help text for authentication toggle
  ///
  /// In de, this message translates to:
  /// **'Aktiviert oder deaktiviert die Passwortabfrage für das Gerät'**
  String get helpAuthToggle;

  /// Help text when username cannot be changed
  ///
  /// In de, this message translates to:
  /// **'Benutzername kann nicht geändert werden'**
  String get helpUsernameCannotChange;

  /// Help text for entering secure password
  ///
  /// In de, this message translates to:
  /// **'Geben Sie ein sicheres Passwort ein'**
  String get helpEnterSecurePassword;

  /// Help text warning about authentication disabled
  ///
  /// In de, this message translates to:
  /// **'Warnung: Wenn die Authentifizierung deaktiviert ist, kann jeder im Netzwerk auf das Gerät zugreifen.'**
  String get helpAuthWarning;

  /// Dialog message when sending WiFi configuration
  ///
  /// In de, this message translates to:
  /// **'WiFi-Konfiguration wird gesendet...'**
  String get dialogWifiConfigSending;

  /// Dialog message when changing setting
  ///
  /// In de, this message translates to:
  /// **'Einstellung wird geändert...'**
  String get dialogSettingChanging;

  /// Dialog message when setting power limit
  ///
  /// In de, this message translates to:
  /// **'Setze Leistungsbegrenzung auf {percentage}%...'**
  String dialogPowerLimitSetting(String percentage);

  /// Dialog title for confirming toggle setting
  ///
  /// In de, this message translates to:
  /// **'{settingName} {action}?'**
  String dialogConfirmToggleSetting(String settingName, String action);

  /// Dialog message for confirming toggle
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie {settingName} wirklich {action}?'**
  String dialogConfirmToggleMessage(String settingName, String action);

  /// Dialog action text for enable
  ///
  /// In de, this message translates to:
  /// **'aktivieren'**
  String get dialogActionEnable;

  /// Dialog action text for disable
  ///
  /// In de, this message translates to:
  /// **'deaktivieren'**
  String get dialogActionDisable;

  /// Dialog title for disabling authentication
  ///
  /// In de, this message translates to:
  /// **'Authentifizierung deaktivieren?'**
  String get dialogDisableAuthTitle;

  /// Dialog message for disabling authentication
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie die Authentifizierung wirklich deaktivieren? Das Gerät wird danach ohne Passwortschutz zugänglich sein.'**
  String get dialogDisableAuthMessage;

  /// Info message when no graph fields
  ///
  /// In de, this message translates to:
  /// **'Dieses Gerät hat keine sichtbaren Diagrammfelder.'**
  String get infoNoGraphFields;

  /// Info text showing data range
  ///
  /// In de, this message translates to:
  /// **'Datenbereich: Letzte 5 Minuten | Aktualisierung: alle 5 Sekunden'**
  String get infoDataRange;

  /// Info note about watt value rounding
  ///
  /// In de, this message translates to:
  /// **'Watt-Werte werden auf volle Prozentschritte gerundet'**
  String get infoWattRoundingNote;

  /// Screen title for Shelly scripts list
  ///
  /// In de, this message translates to:
  /// **'Scripts & Automationen'**
  String get shellyScriptsScreenTitle;

  /// Screen title for script details
  ///
  /// In de, this message translates to:
  /// **'Script-Details'**
  String get shellyScriptDetailTitle;

  /// Screen title for script parameter configuration
  ///
  /// In de, this message translates to:
  /// **'Parameter konfigurieren'**
  String get shellyScriptConfigTitle;

  /// Screen title for script template library
  ///
  /// In de, this message translates to:
  /// **'Script-Vorlagen'**
  String get shellyScriptLibraryTitle;

  /// Screen title for script code preview
  ///
  /// In de, this message translates to:
  /// **'Code-Vorschau'**
  String get shellyScriptPreviewTitle;

  /// Screen title for updating script parameters
  ///
  /// In de, this message translates to:
  /// **'Parameter aktualisieren'**
  String get shellyScriptUpdateTitle;

  /// Status label for activated
  ///
  /// In de, this message translates to:
  /// **'Aktiviert'**
  String get statusActivated;

  /// Status label for deactivated
  ///
  /// In de, this message translates to:
  /// **'Deaktiviert'**
  String get statusDeactivated;

  /// Status label for running
  ///
  /// In de, this message translates to:
  /// **'Läuft'**
  String get statusRunning;

  /// Status label for stopped
  ///
  /// In de, this message translates to:
  /// **'Gestoppt'**
  String get statusStopped;

  /// Button label for configuring parameters
  ///
  /// In de, this message translates to:
  /// **'Parameter konfigurieren'**
  String get shellyScriptsConfigureParams;

  /// Button label for direct installation
  ///
  /// In de, this message translates to:
  /// **'Direkt installieren'**
  String get shellyScriptsDirectInstall;

  /// Button label for repairing failed script
  ///
  /// In de, this message translates to:
  /// **'Script reparieren (fehlgeschlagenes Update)'**
  String get shellyScriptsRepairScript;

  /// Button label for upgrading to new version
  ///
  /// In de, this message translates to:
  /// **'Auf neue Version aktualisieren'**
  String get shellyScriptsUpgradeVersion;

  /// Loading message for script code
  ///
  /// In de, this message translates to:
  /// **'Lade Script-Code...'**
  String get shellyScriptsLoadingCode;

  /// Loading message for current script
  ///
  /// In de, this message translates to:
  /// **'Lade aktuelles Script...'**
  String get shellyScriptsLoadingCurrent;

  /// Loading message for stopping script
  ///
  /// In de, this message translates to:
  /// **'Stoppe Script...'**
  String get shellyScriptsStoppingScript;

  /// Loading message for preparing update
  ///
  /// In de, this message translates to:
  /// **'Bereite Update vor...'**
  String get shellyScriptsPreparingUpdate;

  /// Loading message for updating script
  ///
  /// In de, this message translates to:
  /// **'Aktualisiere Script...'**
  String get shellyScriptsUpdatingScript;

  /// Loading message for finalizing update
  ///
  /// In de, this message translates to:
  /// **'Finalisiere Update...'**
  String get shellyScriptsFinalizingUpdate;

  /// Loading message for deleting script
  ///
  /// In de, this message translates to:
  /// **'Lösche Script...'**
  String get shellyScriptsDeletingScript;

  /// Loading message for activating script
  ///
  /// In de, this message translates to:
  /// **'Aktiviere Script...'**
  String get shellyScriptsActivatingScript;

  /// Loading message for deactivating script
  ///
  /// In de, this message translates to:
  /// **'Deaktiviere Script...'**
  String get shellyScriptsDeactivatingScript;

  /// Loading message for starting script
  ///
  /// In de, this message translates to:
  /// **'Starte Script...'**
  String get shellyScriptsStartingScript;

  /// Button label for start script
  ///
  /// In de, this message translates to:
  /// **'Script starten'**
  String get shellyScriptsStartScript;

  /// Button label for stop script
  ///
  /// In de, this message translates to:
  /// **'Script stoppen'**
  String get shellyScriptsStopScript;

  /// Loading message for creating script on device
  ///
  /// In de, this message translates to:
  /// **'Erstelle Script auf Gerät...'**
  String get shellyScriptsCreatingScript;

  /// Loading message for uploading script code
  ///
  /// In de, this message translates to:
  /// **'Lade Script-Code hoch...'**
  String get shellyScriptsUploadingCode;

  /// Loading message for finalizing installation
  ///
  /// In de, this message translates to:
  /// **'Finalisiere Installation...'**
  String get shellyScriptsFinalizingInstall;

  /// Loading message for searching devices
  ///
  /// In de, this message translates to:
  /// **'Suche Geräte...'**
  String get shellyScriptsSearchingDevices;

  /// Success message for script update
  ///
  /// In de, this message translates to:
  /// **'Script erfolgreich auf Version {version} aktualisiert'**
  String shellyScriptsScriptUpdated(String version);

  /// Success message for script deletion
  ///
  /// In de, this message translates to:
  /// **'Script gelöscht'**
  String get shellyScriptsScriptDeleted;

  /// Success message for script activation
  ///
  /// In de, this message translates to:
  /// **'Script aktiviert'**
  String get shellyScriptsScriptActivated;

  /// Success message for script deactivation
  ///
  /// In de, this message translates to:
  /// **'Script deaktiviert'**
  String get shellyScriptsScriptDeactivated;

  /// Success message for script start
  ///
  /// In de, this message translates to:
  /// **'Script gestartet'**
  String get shellyScriptsScriptStarted;

  /// Success message for script stop
  ///
  /// In de, this message translates to:
  /// **'Script gestoppt'**
  String get shellyScriptsScriptStopped;

  /// Success message for script installation
  ///
  /// In de, this message translates to:
  /// **'Script erfolgreich installiert und gestartet'**
  String get shellyScriptsScriptInstalled;

  /// Success message for parameter update
  ///
  /// In de, this message translates to:
  /// **'Parameter erfolgreich aktualisiert'**
  String get shellyScriptsParamsUpdated;

  /// Error message for loading script code
  ///
  /// In de, this message translates to:
  /// **'Konnte Script-Code nicht abrufen'**
  String get shellyScriptsErrorLoadingCode;

  /// Error message for missing metadata
  ///
  /// In de, this message translates to:
  /// **'Konnte Template-Metadaten nicht extrahieren'**
  String get shellyScriptsErrorNoMetadata;

  /// Error message for missing template ID
  ///
  /// In de, this message translates to:
  /// **'Template-ID fehlt in Metadaten'**
  String get shellyScriptsErrorNoTemplateId;

  /// Error message for template not found
  ///
  /// In de, this message translates to:
  /// **'Vorlage nicht gefunden: {templateId}'**
  String shellyScriptsErrorTemplateNotFound(String templateId);

  /// Error message for update staging failure
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Aktualisieren: {error}\nScript bleibt im Staging-Status (0.0.0).'**
  String shellyScriptsErrorUpdatingStaging(String error);

  /// Error message for missing script ID
  ///
  /// In de, this message translates to:
  /// **'Fehler: Konnte Script-ID nicht abrufen'**
  String get shellyScriptsErrorNoScriptId;

  /// Error message for code upload failure
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Hochladen: {error}\nScript bleibt im Staging-Status (0.0.0).'**
  String shellyScriptsErrorUploadingCode(String error);

  /// Error message for code upload failed
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Hochladen des Codes'**
  String get shellyScriptsErrorCodeUploadFailed;

  /// Error message for script installation failure
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Installieren des Scripts: {error}'**
  String shellyScriptsErrorInstalling(String error);

  /// Error message for loading templates failure
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Vorlagen: {error}'**
  String shellyScriptsErrorLoadingTemplates(String error);

  /// Error section title
  ///
  /// In de, this message translates to:
  /// **'Fehler'**
  String get shellyScriptsErrorSectionTitle;

  /// Script error type: crashed
  ///
  /// In de, this message translates to:
  /// **'Absturz'**
  String get shellyScriptErrorCrashed;

  /// Script error type: syntax error
  ///
  /// In de, this message translates to:
  /// **'Syntaxfehler'**
  String get shellyScriptErrorSyntax;

  /// Script error type: reference error
  ///
  /// In de, this message translates to:
  /// **'Referenzfehler'**
  String get shellyScriptErrorReference;

  /// Script error type: type error
  ///
  /// In de, this message translates to:
  /// **'Typfehler'**
  String get shellyScriptErrorType;

  /// Script error type: out of memory
  ///
  /// In de, this message translates to:
  /// **'Speicher voll'**
  String get shellyScriptErrorMemory;

  /// Script error type: out of codespace
  ///
  /// In de, this message translates to:
  /// **'Code-Speicher voll'**
  String get shellyScriptErrorCodespace;

  /// Script error type: internal error
  ///
  /// In de, this message translates to:
  /// **'Interner Fehler'**
  String get shellyScriptErrorInternal;

  /// Script error type: not implemented
  ///
  /// In de, this message translates to:
  /// **'Nicht implementiert'**
  String get shellyScriptErrorNotImplemented;

  /// Script error type: file read error
  ///
  /// In de, this message translates to:
  /// **'Datei-Lesefehler'**
  String get shellyScriptErrorFileRead;

  /// Script error type: bad arguments
  ///
  /// In de, this message translates to:
  /// **'Ungültige Parameter'**
  String get shellyScriptErrorBadArgs;

  /// Validation message for required field
  ///
  /// In de, this message translates to:
  /// **'{label} ist erforderlich'**
  String shellyScriptsValidationRequired(String label);

  /// Validation message for number field
  ///
  /// In de, this message translates to:
  /// **'{label} muss eine Zahl sein'**
  String shellyScriptsValidationMustBeNumber(String label);

  /// Validation message for minimum value
  ///
  /// In de, this message translates to:
  /// **'{label} muss mindestens {min} sein'**
  String shellyScriptsValidationMinValue(String label, String min);

  /// Validation message for maximum value
  ///
  /// In de, this message translates to:
  /// **'{label} darf höchstens {max} sein'**
  String shellyScriptsValidationMaxValue(String label, String max);

  /// Validation message for port range
  ///
  /// In de, this message translates to:
  /// **'Port muss zwischen 1 und 65535 liegen'**
  String get shellyScriptsValidationPortRange;

  /// Generic validation message for required field
  ///
  /// In de, this message translates to:
  /// **'Dieses Feld ist erforderlich'**
  String get shellyScriptsValidationFieldRequired;

  /// Generic validation message for invalid value
  ///
  /// In de, this message translates to:
  /// **'Ungültiger Wert'**
  String get shellyScriptsValidationInvalidValue;

  /// Dialog title for new parameters available
  ///
  /// In de, this message translates to:
  /// **'Neue Parameter verfügbar'**
  String get shellyScriptsDialogNewParamsTitle;

  /// Dialog message for new parameters available
  ///
  /// In de, this message translates to:
  /// **'Die neue Version {version} enthält neue Parameter, die konfiguriert werden müssen:\n\n{params}\n\nAktuelle Version: {currentVersion}\nNeue Version: {newVersion}'**
  String shellyScriptsDialogNewParamsMessage(
    String version,
    String params,
    String currentVersion,
    String newVersion,
  );

  /// Dialog title for upgrade confirmation
  ///
  /// In de, this message translates to:
  /// **'Auf neue Version aktualisieren?'**
  String get shellyScriptsDialogUpgradeTitle;

  /// Dialog message for upgrade confirmation
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie das Script auf Version {version} aktualisieren?\n\nDiese Operation wird das Script kurzzeitig stoppen und neu starten.'**
  String shellyScriptsDialogUpgradeMessage(String version);

  /// Dialog title for delete confirmation
  ///
  /// In de, this message translates to:
  /// **'Script löschen?'**
  String get shellyScriptsDialogDeleteTitle;

  /// Dialog message for delete confirmation
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie das Script \"{name}\" wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.'**
  String shellyScriptsDialogDeleteMessage(String name);

  /// Dialog title for install confirmation
  ///
  /// In de, this message translates to:
  /// **'Script installieren?'**
  String get shellyScriptsDialogInstallTitle;

  /// Dialog message for install confirmation
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie das Script \"{name}\" ohne Vorschau installieren?'**
  String shellyScriptsDialogInstallMessage(String name);

  /// Dialog title for install on device confirmation
  ///
  /// In de, this message translates to:
  /// **'Script auf Gerät installieren?'**
  String get shellyScriptsDialogInstallConfirmTitle;

  /// Dialog message for install on device confirmation
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie das Script \"{name}\" wirklich auf Ihrem Shelly-Gerät installieren?'**
  String shellyScriptsDialogInstallConfirmMessage(String name);

  /// Dialog title for parameter update confirmation
  ///
  /// In de, this message translates to:
  /// **'Parameter aktualisieren?'**
  String get shellyScriptsDialogUpdateParamsTitle;

  /// Dialog message for parameter update confirmation
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie die Parameter wirklich aktualisieren? Das Script wird mit den neuen Werten neu generiert.'**
  String get shellyScriptsDialogUpdateParamsMessage;

  /// Dialog title for compatibility information
  ///
  /// In de, this message translates to:
  /// **'Kompatibilitäts-Information'**
  String get shellyScriptsDialogCompatibilityTitle;

  /// Info label for automation
  ///
  /// In de, this message translates to:
  /// **'Automatisierung'**
  String get shellyScriptsInfoAutomation;

  /// Info label for failed
  ///
  /// In de, this message translates to:
  /// **'Fehlgeschlagen'**
  String get shellyScriptsInfoFailed;

  /// Info text for version and ID
  ///
  /// In de, this message translates to:
  /// **'Version: {version} • ID: {id}'**
  String shellyScriptsInfoVersion(String version, String id);

  /// Info text for script ID
  ///
  /// In de, this message translates to:
  /// **'Script ID: {id}'**
  String shellyScriptsInfoScriptId(String id);

  /// Info text for version being updated
  ///
  /// In de, this message translates to:
  /// **'Version: {version} (wird aktualisiert)'**
  String shellyScriptsInfoVersionUpdating(String version);

  /// Help text for editing tip
  ///
  /// In de, this message translates to:
  /// **'Tippen Sie auf Bearbeiten um ein Script zu öffnen.'**
  String get shellyScriptsHelpEditTip;

  /// Empty state title when no scripts
  ///
  /// In de, this message translates to:
  /// **'Keine Scripts verfügbar'**
  String get shellyScriptsEmptyStateTitle;

  /// Empty state message when no scripts
  ///
  /// In de, this message translates to:
  /// **'Auf diesem Gerät sind aktuell keine Scripts konfiguriert.'**
  String get shellyScriptsEmptyStateMessage;

  /// Info section title
  ///
  /// In de, this message translates to:
  /// **'Hinweise:'**
  String get shellyScriptsInfoTitle;

  /// Info section content
  ///
  /// In de, this message translates to:
  /// **'• Aktiviert: Script läuft automatisch bei Events\n• Läuft: Script wird gerade ausgeführt\n• Status wird alle 10 Sekunden aktualisiert\n• Bearbeiten: Öffnet Detailansicht mit Steuerung'**
  String get shellyScriptsInfoContent;

  /// FAB label for creating from template
  ///
  /// In de, this message translates to:
  /// **'Aus Vorlage erstellen'**
  String get shellyScriptsFabCreateFromTemplate;

  /// Status section title
  ///
  /// In de, this message translates to:
  /// **'Status'**
  String get shellyScriptsStatusTitle;

  /// Autostart section title
  ///
  /// In de, this message translates to:
  /// **'Autostart aktiviert'**
  String get shellyScriptsAutostartTitle;

  /// Autostart section subtitle
  ///
  /// In de, this message translates to:
  /// **'Script startet automatisch bei konfigurierten Events'**
  String get shellyScriptsAutostartSubtitle;

  /// Control section title
  ///
  /// In de, this message translates to:
  /// **'Steuerung:'**
  String get shellyScriptsControlTitle;

  /// Control section info
  ///
  /// In de, this message translates to:
  /// **'• Autostart: Script läuft automatisch bei Events\n• Start/Stop: Manuelles Starten/Stoppen des Scripts\n• Status wird automatisch aktualisiert'**
  String get shellyScriptsControlInfo;

  /// Config screen info text
  ///
  /// In de, this message translates to:
  /// **'Füllen Sie alle Parameter aus und tippen Sie auf \"Vorschau\", um den generierten Script-Code zu sehen.'**
  String get shellyScriptsConfigInfoText;

  /// Preview screen subtitle
  ///
  /// In de, this message translates to:
  /// **'Prüfen Sie den generierten Code vor der Installation'**
  String get shellyScriptsPreviewSubtitle;

  /// Preview screen info text
  ///
  /// In de, this message translates to:
  /// **'Das Script wird auf Ihrem Shelly-Gerät installiert, aktiviert und automatisch gestartet.'**
  String get shellyScriptsPreviewInfoText;

  /// Update screen info text
  ///
  /// In de, this message translates to:
  /// **'Aktualisieren Sie die Parameter. Das Script wird mit den neuen Werten neu generiert und hochgeladen.'**
  String get shellyScriptsUpdateInfoText;

  /// Search field placeholder
  ///
  /// In de, this message translates to:
  /// **'Vorlagen durchsuchen...'**
  String get shellyScriptsSearchPlaceholder;

  /// Toggle label for showing all scripts
  ///
  /// In de, this message translates to:
  /// **'Alle Scripte anzeigen'**
  String get shellyScriptsShowAllToggle;

  /// Label for current device
  ///
  /// In de, this message translates to:
  /// **'Aktuelles Gerät:'**
  String get shellyScriptsCurrentDevice;

  /// Label for compatible devices
  ///
  /// In de, this message translates to:
  /// **'Kompatible Geräte:'**
  String get shellyScriptsCompatibleDevices;

  /// Label for all devices
  ///
  /// In de, this message translates to:
  /// **'Alle Geräte'**
  String get shellyScriptsAllDevices;

  /// Warning for incompatible device
  ///
  /// In de, this message translates to:
  /// **'Nicht für dieses Gerät vorgesehen'**
  String get shellyScriptsNotCompatibleWarning;

  /// Version display text
  ///
  /// In de, this message translates to:
  /// **'Version {version}'**
  String shellyScriptsVersionDisplay(String version);

  /// Author credit text
  ///
  /// In de, this message translates to:
  /// **'von {author}'**
  String shellyScriptsAuthorCredit(String author);

  /// Required devices text
  ///
  /// In de, this message translates to:
  /// **'Benötigt: {devices}'**
  String shellyScriptsRequiresDevices(String devices);

  /// Parameter count text
  ///
  /// In de, this message translates to:
  /// **'{count} Parameter'**
  String shellyScriptsParamCount(int count);

  /// Filter option for all
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get shellyScriptsFilterAll;

  /// Empty state for template library
  ///
  /// In de, this message translates to:
  /// **'Keine Vorlagen gefunden'**
  String get shellyScriptsEmptyLibrary;

  /// Unknown model label
  ///
  /// In de, this message translates to:
  /// **'Unbekannt'**
  String get shellyScriptsUnknownModel;

  /// Message when no matching devices found
  ///
  /// In de, this message translates to:
  /// **'Keine passenden Geräte gefunden'**
  String get shellyScriptsNoDevicesFound;

  /// Auto-filled indicator text
  ///
  /// In de, this message translates to:
  /// **'Auto-ausgefüllt von: {deviceName}'**
  String shellyScriptsAutoFilledFrom(String deviceName);

  /// Select device text with count
  ///
  /// In de, this message translates to:
  /// **'Gerät auswählen ({count} gefunden)'**
  String shellyScriptsSelectDeviceCount(int count);

  /// Source property text
  ///
  /// In de, this message translates to:
  /// **'Quelle: {sourceProperty}'**
  String shellyScriptsSourceProperty(String sourceProperty);

  /// Filter property text
  ///
  /// In de, this message translates to:
  /// **'Filter: {filter}'**
  String shellyScriptsFilterProperty(String filter);

  /// Helper text when no devices found
  ///
  /// In de, this message translates to:
  /// **'(keine Geräte gefunden)'**
  String get shellyScriptsNoDevicesFoundHelper;

  /// Helper text for auto-filled field
  ///
  /// In de, this message translates to:
  /// **'(automatisch ausgefüllt)'**
  String get shellyScriptsAutoFilledHelper;

  /// Helper text for devices found
  ///
  /// In de, this message translates to:
  /// **'({count} Geräte gefunden)'**
  String shellyScriptsDevicesFoundHelper(int count);

  /// Modal title for selecting device
  ///
  /// In de, this message translates to:
  /// **'Gerät auswählen für \"{label}\"'**
  String shellyScriptsSelectDeviceModal(String label);

  /// Required parameter indicator
  ///
  /// In de, this message translates to:
  /// **'(erforderlich)'**
  String get shellyScriptsParamRequired;

  /// Unknown status while updating
  ///
  /// In de, this message translates to:
  /// **'Unknown (wird aktualisiert)'**
  String get unknownUpdating;

  /// Success message when WiFi configuration is completed
  ///
  /// In de, this message translates to:
  /// **'WiFi-Konfiguration abgeschlossen'**
  String get wifiConfigurationCompleted;

  /// Success message when access point is configured
  ///
  /// In de, this message translates to:
  /// **'Access Point erfolgreich konfiguriert'**
  String get accessPointConfigured;

  /// Success message when power limit is set
  ///
  /// In de, this message translates to:
  /// **'Leistungslimit erfolgreich gesetzt'**
  String get powerLimitSet;

  /// Message indicating device is restarting
  ///
  /// In de, this message translates to:
  /// **'Gerät wird neu gestartet'**
  String get deviceRestarting;

  /// Error message when loading configuration fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Konfiguration: {error}'**
  String errorLoadingConfiguration(String error);

  /// Error message when device restart fails
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Neustarten des Geräts: {error}'**
  String errorRestartingDevice(String error);

  /// Error message when firmware version is unknown
  ///
  /// In de, this message translates to:
  /// **'Nicht möglich da die aktuelle Firmware unbekannt ist, in einem Moment noch mal versuchen (warte noch auf Daten)'**
  String get errorUnknownFirmware;

  /// Loading message while fetching device information
  ///
  /// In de, this message translates to:
  /// **'Lade Geräteinformationen...'**
  String get loadingDeviceInfo;

  /// Loading message while fetching configuration
  ///
  /// In de, this message translates to:
  /// **'Lade aktuelle Konfiguration...'**
  String get loadingConfiguration;

  /// Menu item title for device information
  ///
  /// In de, this message translates to:
  /// **'Geräteinformationen'**
  String get menuDeviceInfo;

  /// Menu item title for WiFi configuration
  ///
  /// In de, this message translates to:
  /// **'WiFi konfigurieren'**
  String get menuConfigureWifi;

  /// Menu item title for setting up AP WiFi
  ///
  /// In de, this message translates to:
  /// **'AP WiFi einrichten'**
  String get menuSetupApWifi;

  /// Menu item title for password configuration
  ///
  /// In de, this message translates to:
  /// **'Passwort konfigurieren'**
  String get menuConfigurePassword;

  /// Menu item title for WLAN setup
  ///
  /// In de, this message translates to:
  /// **'WLAN-Verbindung einrichten'**
  String get menuSetupWlan;

  /// Menu item title for online monitoring configuration
  ///
  /// In de, this message translates to:
  /// **'Online-Monitoring konfigurieren'**
  String get menuOnlineMonitoring;

  /// Menu item title for general settings
  ///
  /// In de, this message translates to:
  /// **'Allgemeine Einstellungen'**
  String get menuGeneralSettings;

  /// Menu item title for inverter power limit
  ///
  /// In de, this message translates to:
  /// **'Wechselrichterleistung begrenzen'**
  String get menuInverterPowerLimit;

  /// Menu item title for output power limit
  ///
  /// In de, this message translates to:
  /// **'Ausgangsleistung begrenzen'**
  String get menuOutputPowerLimit;

  /// Menu item title for restarting OpenDTU
  ///
  /// In de, this message translates to:
  /// **'OpenDTU neu starten'**
  String get menuRestartOpendtu;

  /// Menu item title for RPC UDP port configuration
  ///
  /// In de, this message translates to:
  /// **'RPC UDP Port konfigurieren'**
  String get menuConfigureRpcPort;

  /// Menu item subtitle for setting up network connection
  ///
  /// In de, this message translates to:
  /// **'Netzwerkverbindung einrichten'**
  String get menuSubtitleSetupNetwork;

  /// Menu item subtitle for setting up access point
  ///
  /// In de, this message translates to:
  /// **'AP WiFi einrichten'**
  String get menuSubtitleSetupAccessPoint;

  /// Menu item subtitle for MQTT setup
  ///
  /// In de, this message translates to:
  /// **'MQTT-Broker Verbindung einrichten'**
  String get menuSubtitleMqttSetup;

  /// Menu item subtitle for toggling all inverters
  ///
  /// In de, this message translates to:
  /// **'Schaltet alle Wechselrichter'**
  String get menuSubtitleToggleAllInverters;

  /// Fallback name for device when no specific name is available
  ///
  /// In de, this message translates to:
  /// **'Gerät'**
  String get deviceFallbackName;

  /// Label for port field
  ///
  /// In de, this message translates to:
  /// **'Port'**
  String get labelPort;

  /// Label for power input
  ///
  /// In de, this message translates to:
  /// **'Input (Netz → Gerät)'**
  String get labelPowerInput;

  /// Label for power output
  ///
  /// In de, this message translates to:
  /// **'Output (Gerät → Netz)'**
  String get labelPowerOutput;

  /// Hint text for hostname or IP address field
  ///
  /// In de, this message translates to:
  /// **'Hostname oder IP-Adresse'**
  String get hintHostnameOrIp;

  /// Help text reminding user to power on device
  ///
  /// In de, this message translates to:
  /// **'• Stellen Sie sicher, dass Ihr Gerät eingeschaltet ist'**
  String get helpDevicePoweredOn;

  /// Help text about using strong password
  ///
  /// In de, this message translates to:
  /// **'• Ein starkes Passwort schützt Ihr Netzwerk'**
  String get helpStrongPassword;

  /// Help text about MQTT ports
  ///
  /// In de, this message translates to:
  /// **'• Standard MQTT-Port ist 1883 (unverschlüsselt) oder 8883 (TLS)'**
  String get helpMqttPorts;

  /// Help text about MQTT authentication
  ///
  /// In de, this message translates to:
  /// **'• Die Authentifizierung ist optional, wird aber empfohlen'**
  String get helpMqttAuthRecommended;

  /// Help text about automatic MQTT connection
  ///
  /// In de, this message translates to:
  /// **'• Nach der Konfiguration verbindet sich das Gerät automatisch'**
  String get helpMqttAutoConnect;

  /// Information text for access point configuration
  ///
  /// In de, this message translates to:
  /// **'Konfigurieren Sie den WiFi Access Point Ihres Geräts'**
  String get infoConfigureAccessPoint;

  /// Information text for MQTT authentication toggle
  ///
  /// In de, this message translates to:
  /// **'Aktiviert Benutzername und Passwort für MQTT'**
  String get infoMqttAuthToggle;

  /// Information text when MQTT is disabled
  ///
  /// In de, this message translates to:
  /// **'MQTT ist deaktiviert. Das Gerät wird nicht mit einem MQTT-Broker verbunden sein.'**
  String get infoMqttDisabled;

  /// Message when device has no role support
  ///
  /// In de, this message translates to:
  /// **'Keine Rollen-Unterstützung'**
  String get noRoleSupport;

  /// Message when no details are available
  ///
  /// In de, this message translates to:
  /// **'Keine Details verfügbar'**
  String get noDetailsAvailable;

  /// Success message when online monitoring is configured
  ///
  /// In de, this message translates to:
  /// **'Online-Monitoring erfolgreich konfiguriert'**
  String get onlineMonitoringConfigured;

  /// Success message when authentication is configured
  ///
  /// In de, this message translates to:
  /// **'Authentifizierung erfolgreich konfiguriert'**
  String get authenticationConfigured;

  /// Success message when MQTT configuration is updated
  ///
  /// In de, this message translates to:
  /// **'MQTT-Konfiguration erfolgreich aktualisiert'**
  String get mqttConfigurationUpdated;

  /// Data field: Daily energy yield
  ///
  /// In de, this message translates to:
  /// **'Tagesertrag'**
  String get fieldDailyYield;

  /// Data field: Total energy yield
  ///
  /// In de, this message translates to:
  /// **'Gesamtertrag'**
  String get fieldTotalYield;

  /// Data field: Current power
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Leistung'**
  String get fieldCurrentPower;

  /// Data field: AC power
  ///
  /// In de, this message translates to:
  /// **'AC Leistung'**
  String get fieldAcPower;

  /// Data field: DC power
  ///
  /// In de, this message translates to:
  /// **'DC Leistung'**
  String get fieldDcPower;

  /// Data field: Active power
  ///
  /// In de, this message translates to:
  /// **'Wirkleistung'**
  String get fieldActivePower;

  /// Data field: Reactive power
  ///
  /// In de, this message translates to:
  /// **'Blindleistung'**
  String get fieldReactivePower;

  /// Data field: Apparent power
  ///
  /// In de, this message translates to:
  /// **'Scheinleistung'**
  String get fieldApparentPower;

  /// Data field: Power factor
  ///
  /// In de, this message translates to:
  /// **'Leistungsfaktor'**
  String get fieldPowerFactor;

  /// Data field: DC total power
  ///
  /// In de, this message translates to:
  /// **'DC Gesamtleistung'**
  String get fieldDcTotalPower;

  /// Data field: PV string voltage with number
  ///
  /// In de, this message translates to:
  /// **'PV{num} Spannung'**
  String fieldPvVoltage(String num);

  /// Data field: PV string current with number
  ///
  /// In de, this message translates to:
  /// **'PV{num} Strom'**
  String fieldPvCurrent(String num);

  /// Data field: PV string power with number
  ///
  /// In de, this message translates to:
  /// **'PV{num} Leistung'**
  String fieldPvPower(String num);

  /// Data field: PV string total yield with number
  ///
  /// In de, this message translates to:
  /// **'PV{num} Gesamtertrag'**
  String fieldPvTotalYield(String num);

  /// Data field: PV string daily yield with number
  ///
  /// In de, this message translates to:
  /// **'PV{num} Tagesertrag'**
  String fieldPvDailyYield(String num);

  /// Data field: Total energy import
  ///
  /// In de, this message translates to:
  /// **'Gesamtenergie Bezug'**
  String get fieldTotalEnergyImport;

  /// Data field: Total energy export
  ///
  /// In de, this message translates to:
  /// **'Gesamtenergie Einspeisung'**
  String get fieldTotalEnergyExport;

  /// Data field: Total energy
  ///
  /// In de, this message translates to:
  /// **'Gesamtenergie'**
  String get fieldTotalEnergy;

  /// Data field: Energy per minute import
  ///
  /// In de, this message translates to:
  /// **'Energie pro Minute (Bezug)'**
  String get fieldEnergyPerMinuteImport;

  /// Data field: Energy per minute export
  ///
  /// In de, this message translates to:
  /// **'Energie pro Minute (Einspeisung)'**
  String get fieldEnergyPerMinuteExport;

  /// Data field: Output limit
  ///
  /// In de, this message translates to:
  /// **'Ausgangsleistung Limit'**
  String get fieldOutputLimit;

  /// Data field: Input limit
  ///
  /// In de, this message translates to:
  /// **'Eingangsleistung Limit'**
  String get fieldInputLimit;

  /// Data field: Grid voltage
  ///
  /// In de, this message translates to:
  /// **'Netzspannung'**
  String get fieldGridVoltage;

  /// Data field: Grid current
  ///
  /// In de, this message translates to:
  /// **'Netzstrom'**
  String get fieldGridCurrent;

  /// Data field: Grid frequency
  ///
  /// In de, this message translates to:
  /// **'Netzfrequenz'**
  String get fieldGridFrequency;

  /// Data field: Voltage phase 1
  ///
  /// In de, this message translates to:
  /// **'Spannung Phase 1'**
  String get fieldVoltagePhase1;

  /// Data field: Voltage phase 2
  ///
  /// In de, this message translates to:
  /// **'Spannung Phase 2'**
  String get fieldVoltagePhase2;

  /// Data field: Voltage phase 3
  ///
  /// In de, this message translates to:
  /// **'Spannung Phase 3'**
  String get fieldVoltagePhase3;

  /// Data field: Current phase 1
  ///
  /// In de, this message translates to:
  /// **'Strom Phase 1'**
  String get fieldCurrentPhase1;

  /// Data field: Current phase 2
  ///
  /// In de, this message translates to:
  /// **'Strom Phase 2'**
  String get fieldCurrentPhase2;

  /// Data field: Current phase 3
  ///
  /// In de, this message translates to:
  /// **'Strom Phase 3'**
  String get fieldCurrentPhase3;

  /// Data field: Voltage with instance number
  ///
  /// In de, this message translates to:
  /// **'Spannung {instanceNum}'**
  String fieldVoltageInstance(String instanceNum);

  /// Data field: Current with instance number
  ///
  /// In de, this message translates to:
  /// **'Strom {instanceNum}'**
  String fieldCurrentInstance(String instanceNum);

  /// Data field: DC voltage
  ///
  /// In de, this message translates to:
  /// **'DC Spannung'**
  String get fieldDcVoltage;

  /// Data field: DC current
  ///
  /// In de, this message translates to:
  /// **'DC Strom'**
  String get fieldDcCurrent;

  /// Data field: AC voltage
  ///
  /// In de, this message translates to:
  /// **'AC Spannung'**
  String get fieldAcVoltage;

  /// Data field: AC current
  ///
  /// In de, this message translates to:
  /// **'AC Strom'**
  String get fieldAcCurrent;

  /// Data field: Battery level
  ///
  /// In de, this message translates to:
  /// **'Batterie Level'**
  String get fieldBatteryLevel;

  /// Data field: Battery power
  ///
  /// In de, this message translates to:
  /// **'Batterie Leistung'**
  String get fieldBatteryPower;

  /// Data field: Battery state of charge
  ///
  /// In de, this message translates to:
  /// **'Batterie SOC'**
  String get fieldBatterySoc;

  /// Data field: Battery state
  ///
  /// In de, this message translates to:
  /// **'Batterie Status'**
  String get fieldBatteryState;

  /// Data field: Charge max limit
  ///
  /// In de, this message translates to:
  /// **'Maximale Ladeleistung'**
  String get fieldChargeMaxLimit;

  /// Data field: Discharge max limit
  ///
  /// In de, this message translates to:
  /// **'Maximale Entladeleistung'**
  String get fieldDischargeMaxLimit;

  /// Data field: Pack state
  ///
  /// In de, this message translates to:
  /// **'Pack Status'**
  String get fieldPackState;

  /// Data field: Cell voltage min
  ///
  /// In de, this message translates to:
  /// **'Zellspannung Min'**
  String get fieldCellVoltageMin;

  /// Data field: Cell voltage max
  ///
  /// In de, this message translates to:
  /// **'Zellspannung Max'**
  String get fieldCellVoltageMax;

  /// Data field: Cell temperature max
  ///
  /// In de, this message translates to:
  /// **'Zelltemperatur Max'**
  String get fieldCellTemperatureMax;

  /// Data field: Message displayed when no battery pack data is available
  ///
  /// In de, this message translates to:
  /// **'Keine Batteriepack-Daten verfügbar'**
  String get fieldBatteryPackEmpty;

  /// Data field: Battery pack number label with index (e.g., Batterie #1, Batterie #2)
  ///
  /// In de, this message translates to:
  /// **'Batterie #{num}'**
  String fieldBatteryPackNumber(String num);

  /// Data field: Battery pack state when idle (not charging or discharging)
  ///
  /// In de, this message translates to:
  /// **'Idle'**
  String get fieldBatteryStateIdle;

  /// Data field: Battery pack state when charging
  ///
  /// In de, this message translates to:
  /// **'Lädt'**
  String get fieldBatteryStateCharging;

  /// Data field: Battery pack state when discharging
  ///
  /// In de, this message translates to:
  /// **'Entlädt'**
  String get fieldBatteryStateDischarging;

  /// Data field: Battery pack state when status is unknown
  ///
  /// In de, this message translates to:
  /// **'Unbekannt'**
  String get fieldBatteryStateUnknown;

  /// Data field: Battery pack type identifier
  ///
  /// In de, this message translates to:
  /// **'Typ'**
  String get fieldBatteryType;

  /// Data field: Temperature
  ///
  /// In de, this message translates to:
  /// **'Temperatur'**
  String get fieldTemperature;

  /// Data field: Uptime
  ///
  /// In de, this message translates to:
  /// **'Betriebszeit'**
  String get fieldUptime;

  /// Data field: Limit status
  ///
  /// In de, this message translates to:
  /// **'Limit-Status'**
  String get fieldLimitStatus;

  /// Data field: Power limit
  ///
  /// In de, this message translates to:
  /// **'Leistungslimit'**
  String get fieldPowerLimit;

  /// Data field: Model
  ///
  /// In de, this message translates to:
  /// **'Modell'**
  String get fieldModel;

  /// Data field: Rated power
  ///
  /// In de, this message translates to:
  /// **'Nennleistung'**
  String get fieldRatedPower;

  /// Data field: Firmware version
  ///
  /// In de, this message translates to:
  /// **'Firmware Version'**
  String get fieldFirmwareVersion;

  /// Data field: Serial number
  ///
  /// In de, this message translates to:
  /// **'Seriennummer'**
  String get fieldSerialNumber;

  /// Data field: Article number
  ///
  /// In de, this message translates to:
  /// **'Artikelnummer'**
  String get fieldArticleNumber;

  /// Data field: Manufacturer
  ///
  /// In de, this message translates to:
  /// **'Hersteller'**
  String get fieldManufacturer;

  /// Data field: Average temperature
  ///
  /// In de, this message translates to:
  /// **'Durchschnittstemperatur'**
  String get fieldAverageTemperature;

  /// Data field: Max temperature
  ///
  /// In de, this message translates to:
  /// **'Max. Temperatur'**
  String get fieldMaxTemperature;

  /// Data field: Min temperature
  ///
  /// In de, this message translates to:
  /// **'Min. Temperatur'**
  String get fieldMinTemperature;

  /// Data field: WiFi signal
  ///
  /// In de, this message translates to:
  /// **'WiFi Signal'**
  String get fieldWifiSignal;

  /// Data field: WiFi state
  ///
  /// In de, this message translates to:
  /// **'WiFi Status'**
  String get fieldWifiState;

  /// Data field: Switch with instance number
  ///
  /// In de, this message translates to:
  /// **'Switch {instanceNum}'**
  String fieldSwitchInstance(String instanceNum);

  /// Data field: Power with instance number
  ///
  /// In de, this message translates to:
  /// **'Leistung {instanceNum}'**
  String fieldPowerInstance(String instanceNum);

  /// Data field: Energy with instance number
  ///
  /// In de, this message translates to:
  /// **'Energie {instanceNum}'**
  String fieldEnergyInstance(String instanceNum);

  /// Data field: Frequency with instance number
  ///
  /// In de, this message translates to:
  /// **'Frequenz {instanceNum}'**
  String fieldFrequencyInstance(String instanceNum);

  /// Data field: Power factor with instance number
  ///
  /// In de, this message translates to:
  /// **'Leistungsfaktor {instanceNum}'**
  String fieldPowerFactorInstance(String instanceNum);

  /// Data field: Active power with instance number
  ///
  /// In de, this message translates to:
  /// **'Wirkleistung {instanceNum}'**
  String fieldActivePowerInstance(String instanceNum);

  /// Data field: Reactive power with instance number
  ///
  /// In de, this message translates to:
  /// **'Blindleistung {instanceNum}'**
  String fieldReactivePowerInstance(String instanceNum);

  /// Data field: Apparent power with instance number
  ///
  /// In de, this message translates to:
  /// **'Scheinleistung {instanceNum}'**
  String fieldApparentPowerInstance(String instanceNum);

  /// Data field: Temperature with instance number
  ///
  /// In de, this message translates to:
  /// **'Temperatur {instanceNum}'**
  String fieldTemperatureInstance(String instanceNum);

  /// Data field: Status with instance number
  ///
  /// In de, this message translates to:
  /// **'Status {instanceNum}'**
  String fieldStatusInstance(String instanceNum);

  /// Data field: Yield with instance number
  ///
  /// In de, this message translates to:
  /// **'Ertrag {instanceNum}'**
  String fieldYieldInstance(String instanceNum);

  /// Data field: Total power
  ///
  /// In de, this message translates to:
  /// **'Gesamtleistung'**
  String get fieldTotalPower;

  /// Data field: Total current
  ///
  /// In de, this message translates to:
  /// **'Gesamtstrom'**
  String get fieldTotalCurrent;

  /// Data field: Total voltage
  ///
  /// In de, this message translates to:
  /// **'Gesamtspannung'**
  String get fieldTotalVoltage;

  /// Data field: Active power total
  ///
  /// In de, this message translates to:
  /// **'Wirkleistung Gesamt'**
  String get fieldActivePowerTotal;

  /// Data field: Reactive power total
  ///
  /// In de, this message translates to:
  /// **'Blindleistung Gesamt'**
  String get fieldReactivePowerTotal;

  /// Data field: Apparent power total
  ///
  /// In de, this message translates to:
  /// **'Scheinleistung Gesamt'**
  String get fieldApparentPowerTotal;

  /// Data field: Energy total
  ///
  /// In de, this message translates to:
  /// **'Energie Gesamt'**
  String get fieldEnergyTotal;

  /// Data field: Combined power
  ///
  /// In de, this message translates to:
  /// **'Kombinierte Leistung'**
  String get fieldCombinedPower;

  /// Data field: Power phase 1
  ///
  /// In de, this message translates to:
  /// **'Leistung Phase 1'**
  String get fieldPowerPhase1;

  /// Data field: Power phase 2
  ///
  /// In de, this message translates to:
  /// **'Leistung Phase 2'**
  String get fieldPowerPhase2;

  /// Data field: Power phase 3
  ///
  /// In de, this message translates to:
  /// **'Leistung Phase 3'**
  String get fieldPowerPhase3;

  /// Data field: Active power phase 1
  ///
  /// In de, this message translates to:
  /// **'Wirkleistung Phase 1'**
  String get fieldActivePowerPhase1;

  /// Data field: Active power phase 2
  ///
  /// In de, this message translates to:
  /// **'Wirkleistung Phase 2'**
  String get fieldActivePowerPhase2;

  /// Data field: Active power phase 3
  ///
  /// In de, this message translates to:
  /// **'Wirkleistung Phase 3'**
  String get fieldActivePowerPhase3;

  /// Data field: Reactive power phase 1
  ///
  /// In de, this message translates to:
  /// **'Blindleistung Phase 1'**
  String get fieldReactivePowerPhase1;

  /// Data field: Reactive power phase 2
  ///
  /// In de, this message translates to:
  /// **'Blindleistung Phase 2'**
  String get fieldReactivePowerPhase2;

  /// Data field: Reactive power phase 3
  ///
  /// In de, this message translates to:
  /// **'Blindleistung Phase 3'**
  String get fieldReactivePowerPhase3;

  /// Data field: Apparent power phase 1
  ///
  /// In de, this message translates to:
  /// **'Scheinleistung Phase 1'**
  String get fieldApparentPowerPhase1;

  /// Data field: Apparent power phase 2
  ///
  /// In de, this message translates to:
  /// **'Scheinleistung Phase 2'**
  String get fieldApparentPowerPhase2;

  /// Data field: Apparent power phase 3
  ///
  /// In de, this message translates to:
  /// **'Scheinleistung Phase 3'**
  String get fieldApparentPowerPhase3;

  /// Data field: Frequency phase 1
  ///
  /// In de, this message translates to:
  /// **'Frequenz Phase 1'**
  String get fieldFrequencyPhase1;

  /// Data field: Frequency phase 2
  ///
  /// In de, this message translates to:
  /// **'Frequenz Phase 2'**
  String get fieldFrequencyPhase2;

  /// Data field: Frequency phase 3
  ///
  /// In de, this message translates to:
  /// **'Frequenz Phase 3'**
  String get fieldFrequencyPhase3;

  /// Data field: Inverter type
  ///
  /// In de, this message translates to:
  /// **'Inverter Typ'**
  String get fieldInverterType;

  /// Data field: Access model
  ///
  /// In de, this message translates to:
  /// **'Zugriffsmodus'**
  String get fieldAccessModel;

  /// Data field: DTU serial number
  ///
  /// In de, this message translates to:
  /// **'DTU Seriennummer'**
  String get fieldDtuSerialNumber;

  /// Data field: Network mode
  ///
  /// In de, this message translates to:
  /// **'Netzwerkmodus'**
  String get fieldNetworkMode;

  /// Data field: Server domain
  ///
  /// In de, this message translates to:
  /// **'Server Domain'**
  String get fieldServerDomain;

  /// Data field: Server port
  ///
  /// In de, this message translates to:
  /// **'Server Port'**
  String get fieldServerPort;

  /// Data field: Send interval
  ///
  /// In de, this message translates to:
  /// **'Sendeintervall'**
  String get fieldSendInterval;

  /// Data field: Channel
  ///
  /// In de, this message translates to:
  /// **'Kanal'**
  String get fieldChannel;

  /// Data field: Meter kind
  ///
  /// In de, this message translates to:
  /// **'Zähler Art'**
  String get fieldMeterKind;

  /// Data field: Meter interface
  ///
  /// In de, this message translates to:
  /// **'Zähler Schnittstelle'**
  String get fieldMeterInterface;

  /// Data field: Zero export enabled
  ///
  /// In de, this message translates to:
  /// **'Nulleinspeisung aktiviert'**
  String get fieldZeroExportEnabled;

  /// Data field: Zero export address
  ///
  /// In de, this message translates to:
  /// **'Nulleinspeisung Adresse'**
  String get fieldZeroExportAddress;

  /// Data field: Lock password set
  ///
  /// In de, this message translates to:
  /// **'Sperrpasswort gesetzt'**
  String get fieldLockPasswordSet;

  /// Data field: Lock time minutes
  ///
  /// In de, this message translates to:
  /// **'Sperrzeit Minuten'**
  String get fieldLockTimeMinutes;

  /// Data field: Inverter
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter'**
  String get fieldInverter;

  /// Data field: Inverter toggle description
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter ein- oder ausschalten'**
  String get fieldInverterToggleDescription;

  /// Data field: Number of inverters
  ///
  /// In de, this message translates to:
  /// **'Anzahl Wechselrichter'**
  String get fieldNumberOfInverters;

  /// Data field: Current PV power
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Leistung PV'**
  String get fieldCurrentPvPower;

  /// Data field: Monthly energy yield
  ///
  /// In de, this message translates to:
  /// **'Monatsertrag'**
  String get fieldMonthlyYield;

  /// Data field: Yearly energy yield
  ///
  /// In de, this message translates to:
  /// **'Jahresertrag'**
  String get fieldYearlyYield;

  /// Data field: Voltage (generic)
  ///
  /// In de, this message translates to:
  /// **'Spannung'**
  String get fieldVoltage;

  /// Data field: Current (generic)
  ///
  /// In de, this message translates to:
  /// **'Strom'**
  String get fieldCurrent;

  /// Data field: Battery cycles
  ///
  /// In de, this message translates to:
  /// **'Zyklen'**
  String get fieldBatteryCycles;

  /// Data field: Battery capacity gross
  ///
  /// In de, this message translates to:
  /// **'Kapazität (brutto)'**
  String get fieldBatteryCapacityGross;

  /// Data field: Battery capacity net
  ///
  /// In de, this message translates to:
  /// **'Kapazität (netto)'**
  String get fieldBatteryCapacityNet;

  /// Data field: Total consumption
  ///
  /// In de, this message translates to:
  /// **'Gesamtverbrauch'**
  String get fieldTotalConsumption;

  /// Data field: Consumption from PV
  ///
  /// In de, this message translates to:
  /// **'Verbrauch aus PV'**
  String get fieldConsumptionFromPv;

  /// Data field: Consumption from grid
  ///
  /// In de, this message translates to:
  /// **'Verbrauch aus Netz'**
  String get fieldConsumptionFromGrid;

  /// Data field: Consumption from battery
  ///
  /// In de, this message translates to:
  /// **'Verbrauch aus Batterie'**
  String get fieldConsumptionFromBattery;

  /// Data field: Frequency (generic)
  ///
  /// In de, this message translates to:
  /// **'Frequenz'**
  String get fieldFrequency;

  /// Data field: Max inverter power
  ///
  /// In de, this message translates to:
  /// **'Max. Wechselrichterleistung'**
  String get fieldMaxInverterPower;

  /// Data field: Inverter generation power
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter-Erzeugungsleistung'**
  String get fieldInverterGenerationPower;

  /// Data field: Isolation resistance
  ///
  /// In de, this message translates to:
  /// **'Isolationswiderstand'**
  String get fieldIsolationResistance;

  /// Category: PV1 string
  ///
  /// In de, this message translates to:
  /// **'PV1'**
  String get categoryPv1;

  /// Category: PV2 string
  ///
  /// In de, this message translates to:
  /// **'PV2'**
  String get categoryPv2;

  /// Category: PV3 string
  ///
  /// In de, this message translates to:
  /// **'PV3'**
  String get categoryPv3;

  /// Category: PV4 string
  ///
  /// In de, this message translates to:
  /// **'PV4'**
  String get categoryPv4;

  /// Category: AC (Grid)
  ///
  /// In de, this message translates to:
  /// **'AC (Netz)'**
  String get categoryAcGrid;

  /// Category: AC total
  ///
  /// In de, this message translates to:
  /// **'AC Gesamt'**
  String get categoryAcTotal;

  /// Category: Phase 1
  ///
  /// In de, this message translates to:
  /// **'Phase 1'**
  String get categoryPhase1;

  /// Category: Phase 2
  ///
  /// In de, this message translates to:
  /// **'Phase 2'**
  String get categoryPhase2;

  /// Category: Phase 3
  ///
  /// In de, this message translates to:
  /// **'Phase 3'**
  String get categoryPhase3;

  /// Category: Totals
  ///
  /// In de, this message translates to:
  /// **'Summen'**
  String get categoryTotals;

  /// Category: AC phase 1
  ///
  /// In de, this message translates to:
  /// **'AC Phase 1'**
  String get categoryAcPhase1;

  /// Category: AC phase 2
  ///
  /// In de, this message translates to:
  /// **'AC Phase 2'**
  String get categoryAcPhase2;

  /// Category: AC phase 3
  ///
  /// In de, this message translates to:
  /// **'AC Phase 3'**
  String get categoryAcPhase3;

  /// Category: DC string 1
  ///
  /// In de, this message translates to:
  /// **'DC String 1'**
  String get categoryDcString1;

  /// Category: DC string 2
  ///
  /// In de, this message translates to:
  /// **'DC String 2'**
  String get categoryDcString2;

  /// Category: DC string 3
  ///
  /// In de, this message translates to:
  /// **'DC String 3'**
  String get categoryDcString3;

  /// Category: System
  ///
  /// In de, this message translates to:
  /// **'System'**
  String get categorySystem;

  /// Category: Device information
  ///
  /// In de, this message translates to:
  /// **'Geräteinformationen'**
  String get categoryDeviceInfo;

  /// Category: Battery
  ///
  /// In de, this message translates to:
  /// **'Batterie'**
  String get categoryBattery;

  /// Category: Inverter
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter'**
  String get categoryInverter;

  /// Category: Memory
  ///
  /// In de, this message translates to:
  /// **'Speicher'**
  String get categoryMemory;

  /// Category: Storage
  ///
  /// In de, this message translates to:
  /// **'Lagerung'**
  String get categoryStorage;

  /// Category: Power meter
  ///
  /// In de, this message translates to:
  /// **'Stromzähler'**
  String get categoryPowerMeter;

  /// Category: Home consumption
  ///
  /// In de, this message translates to:
  /// **'Hausverbrauch'**
  String get categoryHomeConsumption;

  /// Category: Measurement with instance number
  ///
  /// In de, this message translates to:
  /// **'Messung {instanceNum}'**
  String categoryMeasurementInstance(String instanceNum);

  /// Category: Switch with instance number
  ///
  /// In de, this message translates to:
  /// **'Switch {instanceNum}'**
  String categorySwitchInstance(String instanceNum);

  /// Category: PM measurement with instance number
  ///
  /// In de, this message translates to:
  /// **'PM Messung {instanceNum}'**
  String categoryPmMeasurementInstance(String instanceNum);

  /// Category: Inverter with instance number
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter {instanceNum}'**
  String categoryInverterInstance(String instanceNum);

  /// Category: String with instance number
  ///
  /// In de, this message translates to:
  /// **'String {instanceNum}'**
  String categoryStringInstance(String instanceNum);

  /// Category: EM1 combined
  ///
  /// In de, this message translates to:
  /// **'Kombiniert'**
  String get categoryEm1Combined;

  /// Category: PM1 combined
  ///
  /// In de, this message translates to:
  /// **'PM Kombiniert'**
  String get categoryPm1Combined;

  /// Category: Switch combined
  ///
  /// In de, this message translates to:
  /// **'Switch Kombiniert'**
  String get categorySwitchCombined;

  /// Category: Power meter phase 1
  ///
  /// In de, this message translates to:
  /// **'Stromzähler Phase 1'**
  String get categoryPowerMeterPhase1;

  /// Category: Power meter phase 2
  ///
  /// In de, this message translates to:
  /// **'Stromzähler Phase 2'**
  String get categoryPowerMeterPhase2;

  /// Category: Power meter phase 3
  ///
  /// In de, this message translates to:
  /// **'Stromzähler Phase 3'**
  String get categoryPowerMeterPhase3;

  /// Field: Solar power
  ///
  /// In de, this message translates to:
  /// **'Leistung Solar'**
  String get fieldSolarPower;

  /// Field: Consumption
  ///
  /// In de, this message translates to:
  /// **'Verbrauch'**
  String get fieldConsumption;

  /// Field: Grid import
  ///
  /// In de, this message translates to:
  /// **'Bezug Netz'**
  String get fieldGridImport;

  /// Field: Battery charge/discharge power
  ///
  /// In de, this message translates to:
  /// **'Batterie Lade/Entladeleistung'**
  String get fieldBatteryChargeDischargePower;

  /// Field: Solar input power
  ///
  /// In de, this message translates to:
  /// **'Solar Eingangsleistung'**
  String get fieldSolarInputPower;

  /// Field: Home output power
  ///
  /// In de, this message translates to:
  /// **'Ausgang Haus'**
  String get fieldHomeOutputPower;

  /// Field: AC mode
  ///
  /// In de, this message translates to:
  /// **'AC Modus'**
  String get fieldAcMode;

  /// Field: Pack count
  ///
  /// In de, this message translates to:
  /// **'Pack Anzahl'**
  String get fieldPackCount;

  /// Menu: Configure WiFi
  ///
  /// In de, this message translates to:
  /// **'WiFi konfigurieren'**
  String get menuWifiConfiguration;

  /// Menu: Configure online monitoring
  ///
  /// In de, this message translates to:
  /// **'Online-Monitoring konfigurieren'**
  String get menuOnlineMonitoringConfiguration;

  /// Menu: Restart device
  ///
  /// In de, this message translates to:
  /// **'Gerät neustarten'**
  String get menuRestartDevice;

  /// Menu: Configure access point
  ///
  /// In de, this message translates to:
  /// **'Access Point konfigurieren'**
  String get menuAccessPointConfiguration;

  /// Menu: Power limit
  ///
  /// In de, this message translates to:
  /// **'Leistungsbegrenzung'**
  String get menuPowerLimit;

  /// Menu: Authentication
  ///
  /// In de, this message translates to:
  /// **'Authentifizierung'**
  String get menuAuthentication;

  /// Menu: Automation
  ///
  /// In de, this message translates to:
  /// **'Automatisierung'**
  String get menuAutomation;

  /// Menu: Power settings
  ///
  /// In de, this message translates to:
  /// **'Leistungseinstellungen'**
  String get menuPowerSettings;

  /// Menu: Battery limits
  ///
  /// In de, this message translates to:
  /// **'Batterie-Limits'**
  String get menuBatteryLimits;

  /// Menu: Advanced power settings
  ///
  /// In de, this message translates to:
  /// **'Erweiterte Leistungseinstellungen'**
  String get menuAdvancedPowerSettings;

  /// Menu: Port configuration
  ///
  /// In de, this message translates to:
  /// **'Port konfigurieren'**
  String get menuPortConfiguration;

  /// Menu subtitle: General settings
  ///
  /// In de, this message translates to:
  /// **'Grundlegende Geräteeinstellungen verwalten'**
  String get menuSubtitleGeneralSettings;

  /// Menu subtitle: WiFi configuration
  ///
  /// In de, this message translates to:
  /// **'Netzwerkverbindung einrichten'**
  String get menuSubtitleWifiConfiguration;

  /// Menu subtitle: Online monitoring
  ///
  /// In de, this message translates to:
  /// **'Server für Datenübertragung einrichten'**
  String get menuSubtitleOnlineMonitoring;

  /// Menu subtitle: Restart device
  ///
  /// In de, this message translates to:
  /// **'Startet das Gerät neu'**
  String get menuSubtitleRestartDevice;

  /// Menu subtitle: Access point
  ///
  /// In de, this message translates to:
  /// **'WiFi Access Point einrichten'**
  String get menuSubtitleAccessPoint;

  /// Menu subtitle: Power limit
  ///
  /// In de, this message translates to:
  /// **'Ausgangsleistung begrenzen'**
  String get menuSubtitlePowerLimit;

  /// Menu subtitle: Authentication
  ///
  /// In de, this message translates to:
  /// **'Zugangsdaten konfigurieren'**
  String get menuSubtitleAuthentication;

  /// Menu subtitle: Device information
  ///
  /// In de, this message translates to:
  /// **'Geräteinformationen anzeigen'**
  String get menuSubtitleDeviceInfo;

  /// Menu subtitle: Power settings
  ///
  /// In de, this message translates to:
  /// **'Leistungsparameter einstellen'**
  String get menuSubtitlePowerSettings;

  /// Menu subtitle: Battery limits
  ///
  /// In de, this message translates to:
  /// **'Batterie-Grenzwerte konfigurieren'**
  String get menuSubtitleBatteryLimits;

  /// Menu subtitle: Advanced power settings
  ///
  /// In de, this message translates to:
  /// **'Erweiterte Leistungsoptionen'**
  String get menuSubtitleAdvancedPowerSettings;

  /// Menu subtitle: Port configuration
  ///
  /// In de, this message translates to:
  /// **'RPC UDP Port konfigurieren'**
  String get menuSubtitlePortConfiguration;

  /// Menu subtitle: Automation
  ///
  /// In de, this message translates to:
  /// **'Shelly Scripts verwalten'**
  String get menuSubtitleAutomation;

  /// Menu: Percentage power limit
  ///
  /// In de, this message translates to:
  /// **'Leistungslimit (Prozent)'**
  String get menuPercentagePowerLimit;

  /// Menu subtitle: Limit inverter power
  ///
  /// In de, this message translates to:
  /// **'Wechselrichterleistung begrenzen'**
  String get menuSubtitlePercentagePowerLimit;

  /// Menu: Toggle inverter on/off
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter ein-/ausschalten'**
  String get menuInverterToggle;

  /// Menu subtitle: Toggles all inverters
  ///
  /// In de, this message translates to:
  /// **'Schaltet alle Wechselrichter'**
  String get menuSubtitleInverterToggle;

  /// Menu: Configure MQTT
  ///
  /// In de, this message translates to:
  /// **'MQTT konfigurieren'**
  String get menuMqttConfiguration;

  /// Menu subtitle: Setup MQTT broker connection
  ///
  /// In de, this message translates to:
  /// **'MQTT-Broker Verbindung einrichten'**
  String get menuSubtitleMqttConfiguration;

  /// Field: Chip model
  ///
  /// In de, this message translates to:
  /// **'Chip Modell'**
  String get fieldChipModel;

  /// Field: Heap memory
  ///
  /// In de, this message translates to:
  /// **'Heap'**
  String get fieldHeap;

  /// Field: Sketch memory
  ///
  /// In de, this message translates to:
  /// **'Sketch'**
  String get fieldSketch;

  /// Field: LittleFS filesystem
  ///
  /// In de, this message translates to:
  /// **'LittleFS'**
  String get fieldLittleFs;

  /// Field: SOC set target
  ///
  /// In de, this message translates to:
  /// **'SOC Set'**
  String get fieldSocSet;

  /// Field: Minimum SOC
  ///
  /// In de, this message translates to:
  /// **'Min SOC'**
  String get fieldMinSoc;

  /// Field: Grid reverse mode
  ///
  /// In de, this message translates to:
  /// **'Netz Rückspeisung'**
  String get fieldGridReverse;

  /// Field: Lamp switch
  ///
  /// In de, this message translates to:
  /// **'Lampe Schalter'**
  String get fieldLampSwitch;

  /// Field: Grid off mode
  ///
  /// In de, this message translates to:
  /// **'Netz Aus Modus'**
  String get fieldGridOffMode;

  /// Field: Fan mode
  ///
  /// In de, this message translates to:
  /// **'Lüfter Modus'**
  String get fieldFanMode;

  /// Field: Fan speed
  ///
  /// In de, this message translates to:
  /// **'Lüfter Geschwindigkeit'**
  String get fieldFanSpeed;

  /// Field: Smart mode
  ///
  /// In de, this message translates to:
  /// **'Smart Modus'**
  String get fieldSmartMode;

  /// Field: Timestamp
  ///
  /// In de, this message translates to:
  /// **'Zeitstempel'**
  String get fieldTimestamp;

  /// Field: Timezone
  ///
  /// In de, this message translates to:
  /// **'Zeitzone'**
  String get fieldTimezone;

  /// Field: Battery packs
  ///
  /// In de, this message translates to:
  /// **'Batteriepacks'**
  String get fieldBatteryPacks;

  /// Field: Solar input
  ///
  /// In de, this message translates to:
  /// **'Solar-Eingang'**
  String get fieldSolarInput;

  /// Field: Output power
  ///
  /// In de, this message translates to:
  /// **'Ausgabeleistung'**
  String get fieldOutputPower;

  /// Field: Input voltage
  ///
  /// In de, this message translates to:
  /// **'Eingangsspannung'**
  String get fieldInputVoltage;

  /// Field: DC string power with inverter name
  ///
  /// In de, this message translates to:
  /// **'{name} - DC-String-Leistung'**
  String fieldDcStringPower(String name);

  /// Field: DC string voltage with inverter name
  ///
  /// In de, this message translates to:
  /// **'{name} - DC-String-Spannung'**
  String fieldDcStringVoltage(String name);

  /// Field: DC input power with prefix
  ///
  /// In de, this message translates to:
  /// **'{prefix} - DC-Eingangsleistung'**
  String fieldDcInputPower(String prefix);

  /// Field: AC output power with prefix
  ///
  /// In de, this message translates to:
  /// **'{prefix} - AC-Ausgangsleistung'**
  String fieldAcOutputPower(String prefix);

  /// Field: All inverters
  ///
  /// In de, this message translates to:
  /// **'Alle Wechselrichter'**
  String get fieldAllInverters;

  /// Field: Lamp
  ///
  /// In de, this message translates to:
  /// **'Lampe'**
  String get fieldLamp;

  /// Field: Emergency power supply
  ///
  /// In de, this message translates to:
  /// **'Notstromversorgung'**
  String get fieldEmergencyPowerSupply;

  /// Field: Device lighting toggle description
  ///
  /// In de, this message translates to:
  /// **'Gerätebeleuchtung ein- oder ausschalten'**
  String get fieldDeviceLightingDescription;

  /// Field: Grid power mode description
  ///
  /// In de, this message translates to:
  /// **'Netzstrom-Modus für das Gerät'**
  String get fieldGridPowerModeDescription;

  /// Field: No inverter data available message
  ///
  /// In de, this message translates to:
  /// **'Keine Wechselrichter-Daten verfügbar'**
  String get fieldNoInverterData;

  /// Field: Inverter producing status
  ///
  /// In de, this message translates to:
  /// **'Produziert'**
  String get fieldStatusProducing;

  /// Field: Inverter reachable status
  ///
  /// In de, this message translates to:
  /// **'Erreichbar'**
  String get fieldStatusReachable;

  /// Field: Inverter not reachable status
  ///
  /// In de, this message translates to:
  /// **'Nicht erreichbar'**
  String get fieldStatusNotReachable;

  /// Field: AC frequency
  ///
  /// In de, this message translates to:
  /// **'AC Frequenz'**
  String get fieldAcFrequency;

  /// Field: Power (generic)
  ///
  /// In de, this message translates to:
  /// **'Leistung'**
  String get fieldPower;

  /// Field: Fallback inverter name with number
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter {num}'**
  String fieldInverterFallback(String num);

  /// Field: Fallback string name with number
  ///
  /// In de, this message translates to:
  /// **'String {num}'**
  String fieldStringFallback(String num);

  /// Error: Failed to load authentication configuration
  ///
  /// In de, this message translates to:
  /// **'Konnte Authentifizierungs-Konfiguration nicht laden: {error}'**
  String errorLoadingAuthConfig(String error);

  /// Error: Failed to load WiFi configuration
  ///
  /// In de, this message translates to:
  /// **'Konnte WiFi-Konfiguration nicht laden: {error}'**
  String errorLoadingWifiConfig(String error);

  /// Dialog: Firmware not supported title
  ///
  /// In de, this message translates to:
  /// **'Firmware nicht unterstützt'**
  String get firmwareNotSupported;

  /// Dialog: Firmware not supported message
  ///
  /// In de, this message translates to:
  /// **'Diese Funktion wird von Ihrer OpenDTU-Firmware nicht unterstützt.\n\nBitte installieren Sie die modifizierte Firmware mit REST-API-Unterstützung.'**
  String get firmwareNotSupportedMessage;

  /// Button: Download firmware
  ///
  /// In de, this message translates to:
  /// **'Firmware herunterladen'**
  String get downloadFirmware;

  /// Warning: No inverters found
  ///
  /// In de, this message translates to:
  /// **'Keine Wechselrichter gefunden'**
  String get noInvertersFound;

  /// Dialog: Toggle inverters title
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter schalten'**
  String get toggleInverters;

  /// Dialog: Toggle inverters prompt
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie alle Wechselrichter ein- oder ausschalten?'**
  String get toggleInvertersPrompt;

  /// Dialog: Select inverter to toggle title
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter auswählen'**
  String get selectInverterToToggle;

  /// Dialog: Inverter is currently on confirmation
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter ist aktuell AN. Ausschalten?'**
  String get inverterCurrentlyOn;

  /// Dialog: Inverter is currently off confirmation
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter ist aktuell AUS. Einschalten?'**
  String get inverterCurrentlyOff;

  /// Button: Turn off
  ///
  /// In de, this message translates to:
  /// **'Ausschalten'**
  String get turnOff;

  /// Button: Turn on
  ///
  /// In de, this message translates to:
  /// **'Einschalten'**
  String get turnOn;

  /// Loading: Turning on inverters
  ///
  /// In de, this message translates to:
  /// **'Schalte Wechselrichter ein...'**
  String get turningOnInverters;

  /// Loading: Turning off inverters
  ///
  /// In de, this message translates to:
  /// **'Schalte Wechselrichter aus...'**
  String get turningOffInverters;

  /// Success: Inverters turned on
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter eingeschaltet'**
  String get invertersTurnedOn;

  /// Success: Inverters turned off
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter ausgeschaltet'**
  String get invertersTurnedOff;

  /// Dialog: Restart device confirmation
  ///
  /// In de, this message translates to:
  /// **'Das Gerät wird neugestartet. Fortfahren?'**
  String get restartDeviceConfirm;

  /// Menu: Restart inverter
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter neustarten'**
  String get menuRestartInverter;

  /// Menu subtitle: Restart inverter
  ///
  /// In de, this message translates to:
  /// **'Startet einen Wechselrichter neu'**
  String get menuSubtitleRestartInverter;

  /// Dialog: Select inverter to restart
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter zum Neustarten auswählen'**
  String get selectInverterToRestart;

  /// Dialog: Select inverter to set power limit
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter für Leistungsbegrenzung auswählen'**
  String get selectInverterToSetLimit;

  /// Dialog: Restart inverter confirmation
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter neustarten?'**
  String get restartInverterConfirm;

  /// Loading: Restarting inverter
  ///
  /// In de, this message translates to:
  /// **'Starte Wechselrichter neu...'**
  String get restartingInverter;

  /// Success: Inverter restarted
  ///
  /// In de, this message translates to:
  /// **'Wechselrichter neu gestartet'**
  String get inverterRestarted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
