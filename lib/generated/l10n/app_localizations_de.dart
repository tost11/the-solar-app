// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'The Solar App';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get select => 'Auswählen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get close => 'Schließen';

  @override
  String get update => 'Aktualisieren';

  @override
  String get install => 'Installieren';

  @override
  String get preview => 'Vorschau';

  @override
  String get connected => 'Verbunden';

  @override
  String get notConnected => 'Nicht verbunden';

  @override
  String get connecting => 'Verbinde...';

  @override
  String get loadingDeviceData => 'Lade Gerätedaten...';

  @override
  String get connectionFailed => 'Verbindung fehlgeschlagen';

  @override
  String get disconnecting => 'Trenne Verbindung...';

  @override
  String get error => 'Fehler';

  @override
  String get deviceNotConnected => 'Gerät nicht verbunden';

  @override
  String get noResponseFromDevice => 'Keine Antwort vom Gerät';

  @override
  String get couldNotRetrieveData => 'Daten konnten nicht abgerufen werden';

  @override
  String get operationFailed => 'Vorgang fehlgeschlagen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get expertMode => 'Expertenmodus';

  @override
  String get expertModeDescription => 'Erweiterte Optionen anzeigen';

  @override
  String get permissions => 'Berechtigungen';

  @override
  String get permissionsDescription => 'App-Berechtigungen prüfen';

  @override
  String get language => 'Sprache';

  @override
  String get languageDescription => 'Sprache der Benutzeroberfläche';

  @override
  String get german => 'Deutsch';

  @override
  String get english => 'English';

  @override
  String get exitApp => 'App beenden';

  @override
  String get version => 'Version';

  @override
  String get tapForDetails => 'Tippen für Details';

  @override
  String get devices => 'Geräte';

  @override
  String get knownDevices => 'Bekannte Geräte';

  @override
  String get addDevice => 'Gerät hinzufügen';

  @override
  String get scanForDevices => 'Nach Geräten suchen';

  @override
  String get deviceName => 'Gerätename';

  @override
  String get deviceType => 'Gerätetyp';

  @override
  String get deviceInfo => 'Geräteinformationen';

  @override
  String get deviceSettings => 'Geräteeinstellungen';

  @override
  String get deleteDevice => 'Gerät löschen';

  @override
  String get deviceRole => 'Geräterolle';

  @override
  String get selectDeviceRole => 'Geräterolle auswählen';

  @override
  String get confirmation => 'Bestätigung';

  @override
  String get areYouSure => 'Sind Sie sicher?';

  @override
  String get deleteDeviceConfirm =>
      'Möchten Sie dieses Gerät wirklich löschen?';

  @override
  String get cannotBeUndone =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get deviceList => 'Geräteliste';

  @override
  String get deviceDetail => 'Gerätedetails';

  @override
  String get scanScreen => 'Geräte suchen';

  @override
  String get manualAdd => 'Manuell hinzufügen';

  @override
  String get scanning => 'Suche...';

  @override
  String get bluetoothDevices => 'Bluetooth-Geräte';

  @override
  String get networkDevices => 'Netzwerkgeräte';

  @override
  String get noDevicesFound => 'Keine Geräte gefunden';

  @override
  String devicesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Geräte gefunden',
      one: '1 Gerät gefunden',
      zero: 'Keine Geräte gefunden',
    );
    return '$_temp0';
  }

  @override
  String get connect => 'Verbinden';

  @override
  String get disconnect => 'Trennen';

  @override
  String get reconnect => 'Erneut verbinden';

  @override
  String get autoReconnect => 'Automatisch neu verbinden';

  @override
  String get power => 'Leistung';

  @override
  String get voltage => 'Spannung';

  @override
  String get current => 'Strom';

  @override
  String get battery => 'Batterie';

  @override
  String get batteryLevel => 'Batteriestand';

  @override
  String get outputLimit => 'Ausgangsgrenze';

  @override
  String get status => 'Status';

  @override
  String get temperature => 'Temperatur';

  @override
  String get energy => 'Energie';

  @override
  String get parameters => 'Parameter';

  @override
  String get configureParameters => 'Parameter konfigurieren';

  @override
  String get newParametersAvailable => 'Neue Parameter verfügbar';

  @override
  String get updateToNewVersion => 'Auf neue Version aktualisieren?';

  @override
  String get updateParameters => 'Parameter aktualisieren';

  @override
  String get directInstall => 'Direkt installieren';

  @override
  String get installOnDevice => 'Auf Gerät installieren';

  @override
  String get createFromTemplate => 'Aus Vorlage erstellen';

  @override
  String get scripts => 'Scripte';

  @override
  String get deleteScript => 'Script löschen?';

  @override
  String get installScript => 'Script installieren?';

  @override
  String get autostartEnabled => 'Autostart aktiviert';

  @override
  String get showAllScripts => 'Alle Scripte anzeigen';

  @override
  String get compatibilityInfo => 'Kompatibilitäts-Information';

  @override
  String get loading => 'Lädt...';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get all => 'Alle';

  @override
  String get none => 'Keine';

  @override
  String get enabled => 'Aktiviert';

  @override
  String get disabled => 'Deaktiviert';

  @override
  String get name => 'Name';

  @override
  String get value => 'Wert';

  @override
  String get description => 'Beschreibung';

  @override
  String get savedSuccessfully => 'Erfolgreich gespeichert';

  @override
  String get deletedSuccessfully => 'Erfolgreich gelöscht';

  @override
  String get updatedSuccessfully => 'Erfolgreich aktualisiert';

  @override
  String get installedSuccessfully => 'Erfolgreich installiert';

  @override
  String get connectedSuccessfully => 'Erfolgreich verbunden';

  @override
  String get disconnectedSuccessfully => 'Erfolgreich getrennt';

  @override
  String get noItemSelected => 'Kein Element ausgewählt';

  @override
  String get selectItemFromList => 'Wählen Sie ein Element aus der Liste';

  @override
  String errorWhileSaving(String error) {
    return 'Fehler beim Speichern: $error';
  }

  @override
  String errorWhileLoading(String error) {
    return 'Fehler beim Laden: $error';
  }

  @override
  String errorWhileToggling(String error) {
    return 'Fehler beim Umschalten: $error';
  }

  @override
  String errorWhileExecuting(String error) {
    return 'Fehler beim Ausführen: $error';
  }

  @override
  String errorWhileAdjusting(String error) {
    return 'Fehler beim Anpassen: $error';
  }

  @override
  String errorWhileRestarting(String error) {
    return 'Fehler beim Neustarten des Geräts: $error';
  }

  @override
  String errorWhileDisconnecting(String error) {
    return 'Fehler beim Trennen: $error';
  }

  @override
  String get errorWhileUploading => 'Fehler beim Hochladen des Codes';

  @override
  String errorWhileLoadingConfig(String error) {
    return 'Fehler beim Laden der Konfiguration: $error';
  }

  @override
  String errorCouldNotRetrieveScripts(String error) {
    return 'Konnte Scripts nicht laden: $error';
  }

  @override
  String get errorCouldNotRetrieveScriptCode =>
      'Konnte Script-Code nicht abrufen';

  @override
  String get errorCouldNotLoadLatestVersion =>
      'Konnte neueste Version nicht laden';

  @override
  String get validationFieldCannotBeEmpty => 'Feld darf nicht leer sein';

  @override
  String get validationDeviceNameCannotBeEmpty =>
      'Gerätename darf nicht leer sein';

  @override
  String get validationUsernameCannotBeEmpty =>
      'Benutzername darf nicht leer sein';

  @override
  String get validationMqttServerCannotBeEmpty =>
      'MQTT-Server darf nicht leer sein';

  @override
  String get validationEnterIpOrHostname =>
      'Bitte IP-Adresse oder Hostname eingeben';

  @override
  String get validationEnterSecurePassword =>
      'Geben Sie ein sicheres Passwort ein';

  @override
  String get formUsername => 'Benutzername';

  @override
  String get formPassword => 'Passwort';

  @override
  String get formSsid => 'SSID';

  @override
  String get formPort => 'Port';

  @override
  String get formHostname => 'Hostname';

  @override
  String get formIpAddress => 'IP-Adresse';

  @override
  String get formManufacturer => 'Hersteller';

  @override
  String get formEnterUsername => 'Benutzername eingeben';

  @override
  String get formEnterPassword => 'Passwort eingeben';

  @override
  String get formEnterPort => 'Geben Sie die Port-Nummer ein';

  @override
  String get formEnterSsid => 'Geben Sie den SSID ein';

  @override
  String get formEnterWifiPassword => 'WiFi-Passwort';

  @override
  String get formSelectOrEnterWifiNetwork =>
      'WiFi-Netzwerkname eingeben oder auswählen';

  @override
  String get formProtocolPort => 'Protokoll-Port (z.B. Modbus)';

  @override
  String get formAdditionalPortHelper =>
      'Zusätzlicher Port für Protokollkommunikation';

  @override
  String get messageDeviceNameSaved => 'Gerätename gespeichert';

  @override
  String get messageDeviceSaved => 'Gerät gespeichert';

  @override
  String get messageDeviceRestarting => 'Gerät wird neu gestartet';

  @override
  String get messagePowerLimitSet => 'Leistungslimit erfolgreich gesetzt';

  @override
  String get messageMqttEnabled => 'MQTT-Verbindung wurde aktiviert';

  @override
  String get messageMqttDisabled => 'MQTT-Verbindung wurde deaktiviert';

  @override
  String get messageAuthSaved => 'Authentifizierung gespeichert';

  @override
  String get messageNetworkSaved => 'Netzwerk gespeichert';

  @override
  String get messageIntervalSaved => 'Intervall gespeichert';

  @override
  String get messageSaving => 'Wird gespeichert...';

  @override
  String get statusDeviceNotFound => 'Gerät nicht gefunden';

  @override
  String get statusConnectionError => 'Verbindungsfehler';

  @override
  String get statusNoInvertersFound => 'Keine Wechselrichter gefunden';

  @override
  String get statusNoScriptsFound => 'Keine Scripts gefunden';

  @override
  String get statusDeviceAlreadyInSystem => 'Gerät bereits im System';

  @override
  String get statusDeviceRemoved => 'Gerät entfernt';

  @override
  String get statusDeviceHasNoRoleConfig =>
      'Gerät hat keine Rollen-Konfiguration';

  @override
  String get statusDeviceHasNoConfigurableRoles =>
      'Gerät hat keine konfigurierbaren Rollen';

  @override
  String get screenDeviceSettings => 'Geräteeinstellungen';

  @override
  String get screenAuthentication => 'Authentifizierung';

  @override
  String get screenMqttConfig => 'MQTT Konfiguration';

  @override
  String get screenWifiConfig => 'WiFi konfigurieren';

  @override
  String get screenGeneralSettings => 'Allgemeine Einstellungen';

  @override
  String get screenManualDeviceAdd => 'Gerät manuell hinzufügen';

  @override
  String get screenNetworkConfig => 'Netzwerkverbindung';

  @override
  String get screenAccessPointConfig => 'Access Point Konfiguration';

  @override
  String get screenUpdateParameters => 'Parameter aktualisieren';

  @override
  String get screenAutomation => 'Automatisierung';

  @override
  String get actionSaveNetwork => 'Netzwerk speichern';

  @override
  String get actionSaveAuth => 'Authentifizierung speichern';

  @override
  String get actionSaveInterval => 'Intervall speichern';

  @override
  String get actionSetupNetwork => 'Netzwerkverbindung einrichten';

  @override
  String get actionSetupAccessPoint => 'WiFi Access Point einrichten';

  @override
  String get actionSetupAuth => 'Benutzername und Passwort einrichten';

  @override
  String get actionLimitOutput => 'Ausgangsleistung begrenzen';

  @override
  String get actionToggleInverters => 'Wechselrichter ein-/ausschalten';

  @override
  String get actionTogglesAllInverters => 'Schaltet alle Wechselrichter';

  @override
  String get actionRestart => 'Neu starten';

  @override
  String get helpDeviceSettingsDescription =>
      'Konfigurieren Sie den Namen und die Authentifizierung für dieses Gerät.';

  @override
  String get helpMqttDescription =>
      'Verbinden Sie Ihr Gerät mit einem MQTT-Broker für Home Automation Integration.';

  @override
  String get helpEnableOrDisableMqtt =>
      'Aktiviert oder deaktiviert die MQTT-Verbindung';

  @override
  String get helpEnableOrDisableAp =>
      'Aktiviert oder deaktiviert den Access Point';

  @override
  String get helpApWarning =>
      'Warnung: Wenn deaktiviert, ist möglicherweise keine Interaktion mit dem Gerät mehr möglich. Vorsichtig verwenden!';

  @override
  String get helpOpenNetwork => 'Netzwerk ohne Passwort (nicht empfohlen)';

  @override
  String get helpUpdateIntervalDescription =>
      'Zeitintervall zwischen Datenabrufen vom Gerät';

  @override
  String get helpIntervalDefault => 'Standard: 30 Sekunden (Bereich: 1-300)';

  @override
  String get helpAuthDescription =>
      'Benutzername und Passwort für die Geräteauthentifizierung';

  @override
  String get wifiEnableAccessPoint => 'Access Point aktivieren';

  @override
  String get wifiOpenNetwork => 'Offenes Netzwerk';

  @override
  String get wifiConfigureWifi => 'WiFi konfigurieren';

  @override
  String get wifiSsidLabel => 'SSID';

  @override
  String get wifiPasswordLabel => 'Passwort';

  @override
  String get wifiSelectNetwork => 'Netzwerk auswählen';

  @override
  String get wifiEnterNetworkName => 'Netzwerkname eingeben';

  @override
  String get wifiApMode => 'Access Point Modus';

  @override
  String get wifiStationMode => 'Station Modus';

  @override
  String get wifiScanNetworks => 'Netzwerke scannen';

  @override
  String get wifiNoNetworksFound => 'Keine Netzwerke gefunden';

  @override
  String get wifiConnectionStrength => 'Verbindungsstärke';

  @override
  String get mqttConfiguration => 'MQTT Konfiguration';

  @override
  String get mqttEnable => 'MQTT aktivieren';

  @override
  String get mqttServer => 'MQTT Server';

  @override
  String get mqttPort => 'MQTT Port';

  @override
  String get mqttTopic => 'MQTT Topic';

  @override
  String get mqttUsername => 'MQTT Benutzername';

  @override
  String get mqttPassword => 'MQTT Passwort';

  @override
  String get mqttQos => 'QoS Level';

  @override
  String get authTitle => 'Authentifizierung';

  @override
  String get authUsername => 'Benutzername';

  @override
  String get authPassword => 'Passwort';

  @override
  String get authUsernameCannotBeChanged =>
      'Benutzername kann nicht geändert werden';

  @override
  String get authRequired => 'Authentifizierung erforderlich';

  @override
  String get networkIpAddress => 'IP-Adresse';

  @override
  String get networkHostname => 'Hostname';

  @override
  String get networkPort => 'Port';

  @override
  String get networkSubnet => 'Subnetz';

  @override
  String get networkGateway => 'Gateway';

  @override
  String get networkDns => 'DNS Server';

  @override
  String get menuSetupNetwork => 'Netzwerkverbindung einrichten';

  @override
  String get menuSetupAccessPoint => 'WiFi Access Point einrichten';

  @override
  String get menuSetupAuth => 'Benutzername und Passwort einrichten';

  @override
  String get menuLimitPower => 'Ausgangsleistung begrenzen';

  @override
  String get menuLampAndEmergency => 'Lampe und Notstromsteckdose';

  @override
  String get menuToggleInverters => 'Schaltet alle Wechselrichter';

  @override
  String get menuConfigureDevice => 'Gerät konfigurieren';

  @override
  String get intervalUpdateInterval => 'Aktualisierungsintervall';

  @override
  String get intervalSeconds => 'Sekunden';

  @override
  String get intervalEnterInterval => 'Intervall (Sekunden)';

  @override
  String intervalDefaultRange(int defaultValue, int min, int max) {
    return 'Standard: $defaultValue Sekunden (Bereich: $min-$max)';
  }

  @override
  String get intervalDescription =>
      'Zeitintervall zwischen Datenabrufen vom Gerät';

  @override
  String get systemGrid => 'Netz';

  @override
  String get systemConsumer => 'Verbraucher';

  @override
  String get systemAdditionalLoad => 'Zusätzliche Last';

  @override
  String get systemInverter => 'Wechselrichter';

  @override
  String get systemBattery => 'Batterie';

  @override
  String get systemSolarPanels => 'Solarmodule';

  @override
  String get deviceOff => 'Aus';

  @override
  String get deviceOn => 'Ein';

  @override
  String get deviceAuto => 'Automatisch';

  @override
  String get deviceManual => 'Manuell';

  @override
  String get deviceResetToDefaults => 'Auf Standardwerte zurücksetzen';

  @override
  String get deviceFactoryReset => 'Werkseinstellungen';

  @override
  String powerRange(int min, int max) {
    return 'Bereich: $min - $max W';
  }

  @override
  String get powerLimit => 'Leistungsgrenze';

  @override
  String get powerOutput => 'Ausgangsleistung';

  @override
  String get powerInput => 'Eingangsleistung';

  @override
  String get powerConsumption => 'Verbrauch';

  @override
  String get tabDevices => 'Geräte';

  @override
  String get tabNetwork => 'Netzwerk';

  @override
  String get tabBluetooth => 'Bluetooth';

  @override
  String get tabSystems => 'Systeme';

  @override
  String get tabSettings => 'Einstellungen';

  @override
  String get miscRange => 'Bereich';

  @override
  String get miscDefault => 'Standard';

  @override
  String get miscOptional => 'Optional';

  @override
  String get miscRequired => 'Erforderlich';

  @override
  String get actionRemoveDevice => 'Gerät entfernen';

  @override
  String confirmRemoveDevice(String deviceName) {
    return 'Möchten Sie \"$deviceName\" wirklich entfernen?';
  }

  @override
  String get actionRemove => 'Entfernen';

  @override
  String errorWhileRemoving(String error) {
    return 'Fehler beim Entfernen: $error';
  }

  @override
  String get actionCreateNewSystem => 'Neues System erstellen';

  @override
  String get formSystemName => 'System-Name';

  @override
  String get actionCreate => 'Erstellen';

  @override
  String get screenMyDevices => 'Meine Geräte';

  @override
  String get screenSystems => 'Systeme';

  @override
  String get actionLiveCharts => 'Live-Diagramme';

  @override
  String get actionMoreFunctions => 'Weitere Funktionen';

  @override
  String get emptyStateNoDevices => 'Keine Geräte';

  @override
  String get emptyStateAddFirstDevice => 'Fügen Sie Ihr erstes Gerät hinzu';

  @override
  String get actionAddDevice => 'Gerät hinzufügen';

  @override
  String get labelDevice => 'Gerät';

  @override
  String get emptyStateNoDeviceSelected => 'Kein Gerät ausgewählt';

  @override
  String get actionAddSystem => 'System hinzufügen';

  @override
  String get labelPermissions => 'Berechtigungen';

  @override
  String get errorNoWifiLanConnection =>
      'Netzwerk-Scan ist nur über WiFi oder LAN möglich.\n\nBitte verbinden Sie sich mit einem WiFi-Netzwerk oder LAN und versuchen Sie es erneut.';

  @override
  String get titleNoWifiLanConnection => 'Keine WiFi/LAN-Verbindung';

  @override
  String errorNoPrivateNetwork(String ips) {
    return 'Keine privaten Netzwerke gefunden.\n\nGefundene IPs: $ips\n\nStellen Sie sicher, dass Sie mit einem lokalen Netzwerk verbunden sind.';
  }

  @override
  String get titleNoPrivateNetwork => 'Kein privates Netzwerk';

  @override
  String get errorNetworkScan => 'Netzwerk-Scan Fehler';

  @override
  String get errorNotConnectedToWifi =>
      'Nicht mit WiFi verbunden. Bitte WiFi aktivieren.';

  @override
  String errorNetworkScanWithDetails(String error) {
    return 'Netzwerk-Scan Fehler: $error';
  }

  @override
  String warningPublicNetwork(String currentIp) {
    return 'Ihre aktuelle IP-Adresse scheint nicht in einem privaten Netzwerk zu sein.\n\nAktuelle IP: $currentIp\n\nDas Scannen von öffentlichen IP-Bereichen ist möglicherweise nicht sinnvoll. Stellen Sie sicher, dass Sie mit einem lokalen WiFi-Netzwerk verbunden sind.\n\nMöchten Sie trotzdem fortfahren?';
  }

  @override
  String get titleWarningPublicNetwork => 'Warnung: Öffentliches Netzwerk';

  @override
  String get actionOkContinue => 'OK, Fortfahren';

  @override
  String messageIpUpdated(
    String oldIp,
    String oldPort,
    String newIp,
    String newPort,
  ) {
    return 'IP-Adresse wurde von $oldIp:$oldPort auf $newIp:$newPort aktualisiert';
  }

  @override
  String messageIpAddressUpdated(String oldIp, String newIp) {
    return 'IP-Adresse wurde von $oldIp auf $newIp aktualisiert';
  }

  @override
  String messagePortUpdated(String oldPort, String newPort) {
    return 'Port wurde von $oldPort auf $newPort aktualisiert';
  }

  @override
  String get messageSavingDevice => 'Gerät wird gespeichert...';

  @override
  String get messageConnectingToDevice => 'Verbinde zu Gerät...';

  @override
  String get labelDeviceKnown => 'Gerät bekannt';

  @override
  String get labelKnownNewAddress => 'Bekannt (neue Adresse)';

  @override
  String get labelFound => 'Gefunden';

  @override
  String get labelKnownDevices => 'Bekannte Geräte';

  @override
  String get labelTested => 'Geprüft';

  @override
  String get labelRemaining => 'Verbleibend';

  @override
  String get labelKnown => 'Bekannt';

  @override
  String get labelLeft => 'Übrig';

  @override
  String get actionUpdateIp => 'IP Aktualisieren';

  @override
  String get actionAddDevices => 'Geräte hinzufügen';

  @override
  String get actionInspectDevice => 'Gerät inspizieren';

  @override
  String get actionChooseRole => 'Rolle wählen';

  @override
  String get actionCreateSystem => 'System erstellen';

  @override
  String get actionDeleteSystem => 'System löschen';

  @override
  String get messageDeviceHasNoRoleConfig =>
      'Gerät hat keine Rollen-Konfiguration';

  @override
  String get messageDeviceHasNoConfigurableRoles =>
      'Gerät hat keine konfigurierbaren Rollen';

  @override
  String get messageDeviceAlreadyInSystem => 'Gerät bereits im System';

  @override
  String messageDeviceAddedWithRoles(String name, String roles) {
    return 'Gerät \"$name\" hinzugefügt mit Rolle(n): $roles';
  }

  @override
  String get messageDeviceRemoved => 'Gerät entfernt';

  @override
  String get messageNoDevicesInSystem => 'Keine Geräte im System';

  @override
  String get messageAddDevicesToSeeMetrics =>
      'Fügen Sie Geräte hinzu, um Metriken zu sehen.';

  @override
  String get messageNoActiveDevicesWithData => 'Keine aktiven Geräte mit Daten';

  @override
  String get messageNoSystems => 'Keine Systeme';

  @override
  String get messageCreateYourFirstSystem => 'Erstellen Sie Ihr erstes System';

  @override
  String confirmRemoveDeviceWithRoles(String name, int count, String roles) {
    return 'Möchten Sie \"$name\" mit $count Rolle(n) ($roles) aus diesem System entfernen?';
  }

  @override
  String confirmRemoveUnknownDeviceWithRoles(int count, String roles) {
    return 'Möchten Sie dieses Gerät mit $count Rolle(n) ($roles) aus dem System entfernen?';
  }

  @override
  String confirmDeleteSystem(String name) {
    return 'Möchten Sie \"$name\" wirklich löschen?';
  }

  @override
  String screenEditSystem(String name) {
    return '$name bearbeiten';
  }

  @override
  String get screenCreateNewSystem => 'Neues System erstellen';

  @override
  String labelRoles(String roles) {
    return 'Rollen: $roles';
  }

  @override
  String labelDevicesCount(int count) {
    return '$count Geräte';
  }

  @override
  String labelDevicesWithCount(int count) {
    return 'Geräte ($count)';
  }

  @override
  String statusDeviceNotFoundWithSn(String sn) {
    return 'Gerät $sn nicht gefunden';
  }

  @override
  String get systemSolarProduction => 'Solar-Produktion';

  @override
  String get systemSolarToGrid => 'Solar ins Netz';

  @override
  String get active => 'aktiv';

  @override
  String get errorNoWifiLanConnectionTitle => 'Keine WiFi/LAN-Verbindung';

  @override
  String get errorNoPrivateNetworkTitle => 'Kein privates Netzwerk';

  @override
  String messageDevicesFoundInNetwork(int count) {
    return '$count Geräte im Netzwerk gefunden';
  }

  @override
  String get errorNetworkScanError => 'Netzwerk-Scan Fehler';

  @override
  String errorNetworkScanFailed(String error) {
    return 'Netzwerk-Scan Fehler: $error';
  }

  @override
  String get warningPublicNetworkTitle => 'Warnung: Öffentliches Netzwerk';

  @override
  String get actionContinueAnyway => 'OK, Fortfahren';

  @override
  String messageIpOnlyUpdated(String oldIp, String newIp) {
    return 'IP-Adresse wurde von $oldIp auf $newIp aktualisiert';
  }

  @override
  String get labelKnownDevice => 'Gerät bekannt';

  @override
  String get device => 'Gerät';

  @override
  String get actionUpdate => 'Aktualisieren';

  @override
  String get startScanToFindDevices =>
      'Starten Sie einen Scan um Geräte zu finden';

  @override
  String get messageSearchingForKnownDevices =>
      'Suche nach bekannten Geräten...';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get network => 'Netzwerk';

  @override
  String get labelBluetoothDevices => 'Bluetooth-Geräte';

  @override
  String get helpScanForNearbyDevices =>
      'Scannen Sie nach Geräten in der Nähe (Zendure, Shelly)';

  @override
  String get messageScanning => 'Scannt...';

  @override
  String get actionBluetoothScan => 'Bluetooth-Scan';

  @override
  String get labelNetworkDevices => 'Netzwerk-Geräte';

  @override
  String get helpScanLocalNetwork =>
      'Scannen Sie Ihr lokales Netzwerk nach Geräten';

  @override
  String get actionNetworkScan => 'Netzwerk-Scan';

  @override
  String get actionManual => 'Manuell';

  @override
  String get remove => 'Entfernen';

  @override
  String get create => 'Erstellen';

  @override
  String get screenDeviceInfo => 'Geräteinformationen';

  @override
  String get messageNoInformationAvailable => 'Keine Informationen verfügbar';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get screenLiveGraphs => 'Live-Diagramme';

  @override
  String get screenAppInfo => 'App-Informationen';

  @override
  String get screenPowerLimit => 'Leistungslimit einstellen';

  @override
  String get screenAdvancedPowerSettings => 'Erweiterte Leistungseinstellungen';

  @override
  String screenPortConfiguration(String portName) {
    return '$portName';
  }

  @override
  String get screenPercentagePowerLimit => 'Leistungsbegrenzung';

  @override
  String get screenOnlineMonitoring => 'Online-Monitoring konfigurieren';

  @override
  String get screenBatterySoc => 'Batterie-Limits einstellen';

  @override
  String get screenPower => 'Leistung einstellen';

  @override
  String get screenZendureWifiMqtt => 'MQTT Konfiguration';

  @override
  String get screenOpenDtuOnlineMonitoring => 'Online-Monitoring';

  @override
  String get validationSsidRequired => 'SSID darf nicht leer sein';

  @override
  String get validationPasswordRequired => 'Passwort darf nicht leer sein';

  @override
  String get validationPortRequired => 'Port darf nicht leer sein';

  @override
  String get validationPortRange =>
      'Port muss eine Zahl zwischen 1 und 65535 sein';

  @override
  String get validationUsernameRequired => 'Benutzername darf nicht leer sein';

  @override
  String get validationPasswordEmpty => 'Passwort darf nicht leer sein';

  @override
  String get validationMinSocLessThanMax =>
      'Minimum SOC muss kleiner als Maximum SOC sein';

  @override
  String get validationPrimaryServerRequired =>
      'Primärer Server URL ist erforderlich';

  @override
  String get validationPrimaryUrlInvalid =>
      'Ungültige primäre Server URL (kein Protokoll http:// oder https:// verwenden)';

  @override
  String get validationSystemIdRequired => 'System-ID ist erforderlich';

  @override
  String get validationTokenRequired => 'Token/Passwort ist erforderlich';

  @override
  String get validationSecondaryUrlInvalid =>
      'Ungültige sekundäre Server URL (kein Protokoll http:// oder https:// verwenden)';

  @override
  String get validationPrimaryPortInvalid =>
      'Ungültiger primärer Port (1-65535)';

  @override
  String get validationSecondaryPortInvalid =>
      'Ungültiger sekundärer Port (1-65535)';

  @override
  String get validationUploadIntervalRange =>
      'Upload-Intervall muss zwischen 1 und 3600 Sekunden liegen';

  @override
  String get validationServerAIpRequired =>
      'Server A: IP-Adresse oder Domain muss angegeben werden';

  @override
  String get validationServerAIpInvalid => 'Server A: Ungültige IP-Adresse';

  @override
  String get validationServerAPortRange =>
      'Server A: Port muss zwischen 1 und 65534 liegen';

  @override
  String get validationServerBIpRequired =>
      'Server B: IP-Adresse oder Domain muss angegeben werden';

  @override
  String get validationServerBIpInvalid => 'Server B: Ungültige IP-Adresse';

  @override
  String get validationServerBPortRange =>
      'Server B: Port muss zwischen 1 und 65534 liegen';

  @override
  String get messageCopiedToClipboard => 'In Zwischenablage kopiert';

  @override
  String get messageWifiConfigSent =>
      'WiFi-Konfiguration erfolgreich gesendet!';

  @override
  String messagePortConfigured(String portName) {
    return '$portName erfolgreich konfiguriert';
  }

  @override
  String messagePowerLimitSetWithValue(String value) {
    return 'Leistungseinstellungen erfolgreich gesetzt: $value W';
  }

  @override
  String messagePowerPercentageSet(String percentage) {
    return 'Leistungsbegrenzung auf $percentage% gesetzt';
  }

  @override
  String messageBatteryLimitsSet(String min, String max) {
    return 'Batterie-Limits erfolgreich gesetzt: Min $min%, Max $max%';
  }

  @override
  String get messageOnlineMonitoringConfigured =>
      'Online-Monitoring erfolgreich konfiguriert';

  @override
  String messageSettingUpdated(String settingName) {
    return '$settingName wurde aktualisiert';
  }

  @override
  String get messageAuthEnabled => 'Authentifizierung wurde aktiviert';

  @override
  String get messageAuthDisabled => 'Authentifizierung wurde deaktiviert';

  @override
  String errorWhileSending(String error) {
    return 'Fehler beim Senden: $error';
  }

  @override
  String errorConfiguringPort(String error) {
    return 'Fehler beim Konfigurieren des Ports: $error';
  }

  @override
  String errorSettingPowerLimit(String error) {
    return 'Fehler beim Setzen der Einstellungen: $error';
  }

  @override
  String errorSettingPercentageLimit(String error) {
    return 'Fehler beim Setzen der Leistungsbegrenzung: $error';
  }

  @override
  String errorSettingBatteryLimits(String error) {
    return 'Fehler beim Setzen der Batterie-Limits: $error';
  }

  @override
  String errorConfiguringOnlineMonitoring(String error) {
    return 'Fehler beim Konfigurieren des Online-Monitorings: $error';
  }

  @override
  String errorChangingSetting(String error) {
    return 'Fehler beim Ändern der Einstellung: $error';
  }

  @override
  String errorSavingAuth(String error) {
    return 'Fehler beim Speichern der Authentifizierung: $error';
  }

  @override
  String get sectionNetworkSetup => 'Netzwerk einrichten';

  @override
  String get sectionMqttConfig => 'MQTT Konfiguration';

  @override
  String get sectionNote => 'Hinweis';

  @override
  String get sectionLimitType => 'Limit-Typ';

  @override
  String get sectionCurrentValue => 'Aktueller Wert';

  @override
  String get sectionAdjustLimit => 'Limit anpassen';

  @override
  String get sectionCurrentSettings => 'Aktuelle Einstellungen';

  @override
  String get sectionMaxInverterPower => 'Max Wechselrichter Leistung';

  @override
  String get sectionPreciseInput => 'Präzise Eingabe';

  @override
  String get sectionGridFeedback => 'Netzrückspeisung';

  @override
  String get sectionGridStandard => 'Netzstandard';

  @override
  String get sectionPortNumber => 'Port-Nummer';

  @override
  String get sectionPercentageLimit => 'Leistungsbegrenzung in Prozent';

  @override
  String get sectionWattLimit => 'Leistungsbegrenzung in Watt';

  @override
  String get sectionDeviceInfo => 'Geräteinformationen';

  @override
  String get sectionOnlineMonitoring => 'Online-Monitoring';

  @override
  String get sectionPrimaryServer => 'Primärer Server';

  @override
  String get sectionSecondaryServer => 'Sekundärer Server';

  @override
  String get sectionCredentials => 'Zugangsdaten';

  @override
  String get sectionServerA => 'Server A (Hauptserver)';

  @override
  String get sectionServerB => 'Server B (Sekundärserver)';

  @override
  String get sectionGeneralSettings => 'Allgemeine Einstellungen';

  @override
  String get sectionCurrentValues => 'Aktuelle Werte';

  @override
  String get sectionMinSoc => 'Minimum SOC';

  @override
  String get sectionMaxSoc => 'Maximum SOC';

  @override
  String get sectionAuthConfig => 'Authentifizierung konfigurieren';

  @override
  String get sectionUsername => 'Benutzername';

  @override
  String get sectionPassword => 'Passwort';

  @override
  String get buttonCopy => 'Kopieren';

  @override
  String get buttonConfigureWifi => 'WiFi konfigurieren';

  @override
  String get buttonSavePowerLimit => 'Leistungsbegrenzung speichern';

  @override
  String get buttonDeactivate => 'Deaktivieren';

  @override
  String get segmentDisabled => 'Deaktiviert';

  @override
  String get segmentAllowed => 'Erlaubt';

  @override
  String get segmentForbidden => 'Verboten';

  @override
  String get segmentGermany => 'Deutschland';

  @override
  String get segmentFrance => 'Frankreich';

  @override
  String get segmentAustria => 'Österreich';

  @override
  String get labelMaxInverterPower => 'Max Wechselrichter Leistung';

  @override
  String get labelGridFeedback => 'Rückspeisung';

  @override
  String get labelGridStandard => 'Netzstandard';

  @override
  String get labelPowerInWatts => 'Leistung in Watt';

  @override
  String get labelPercent => 'Prozent';

  @override
  String get labelWatt => 'Watt';

  @override
  String get labelMinimum => 'Minimum';

  @override
  String get labelMaximum => 'Maximum';

  @override
  String get labelMinSoc => 'Min SOC';

  @override
  String get labelMaxSoc => 'Max SOC';

  @override
  String labelProtocol(String required) {
    return 'Protokoll$required';
  }

  @override
  String labelServerUrl(String required) {
    return 'Server-URL$required';
  }

  @override
  String get labelPortField => 'Port';

  @override
  String get labelSystemId => 'System-ID *';

  @override
  String get labelToken => 'Token/Passwort *';

  @override
  String get labelUploadInterval => 'Upload-Intervall (Sekunden)';

  @override
  String get labelIpAddress => 'IP-Adresse';

  @override
  String get labelDomain => 'Domain';

  @override
  String get labelUsername => 'Benutzername';

  @override
  String get labelPassword => 'Passwort';

  @override
  String get labelRequiredField => 'Erforderlich';

  @override
  String get labelOptionalField => 'Optional';

  @override
  String get labelInputLimit => 'Input (Netz → Gerät)';

  @override
  String get labelOutputLimit => 'Output (Gerät → Netz)';

  @override
  String get labelUnknown => 'Unbekannt';

  @override
  String get helpConnectDeviceToWifi =>
      'Verbinden Sie Ihr Gerät mit Ihrem WLAN-Netzwerk,';

  @override
  String get helpWifiSetupInstructions =>
      '• Stellen Sie sicher, dass Ihr Gerät eingeschaltet ist\n• Das WLAN-Passwort wird sicher übertragen\n• Nach erfolgreicher Konfiguration kann es einige Sekunden dauern, bis das Gerät verbunden ist';

  @override
  String get helpMqttExplanation =>
      'Dies ist für die offizielle App Web-Kommunikation, nicht für lokales MQTT. Bei alten Versionen war es der einzige Weg, um Daten zu bekommen. Nur ändern, wenn Sie wissen, was Sie tun!';

  @override
  String get helpMqttServerExample => 'z.B. broker.example.com:1883';

  @override
  String get helpPleaseWait => 'Bitte warten Sie einen Moment';

  @override
  String get helpInputNotAvailable => 'Input-Limit ist nicht verfügbar';

  @override
  String helpPowerRange(String maxValue) {
    return 'Bereich: 0 - $maxValue W';
  }

  @override
  String get helpWattValue => 'Wert zwischen 1 und 100';

  @override
  String helpMaxWatt(String maxWatt) {
    return 'Max: $maxWatt W (entspricht 100%)';
  }

  @override
  String get helpWattRounding =>
      'Watt-Werte werden auf volle Prozentschritte gerundet';

  @override
  String helpNominalPower(String maxWatt) {
    return 'Nennleistung: $maxWatt W';
  }

  @override
  String helpCurrentLimit(String watt, String percentage) {
    return 'Aktuelle Begrenzung: $watt W ($percentage%)';
  }

  @override
  String get helpGridFeedbackDescription =>
      'Bestimmt, ob Energie ins Netz eingespeist werden darf';

  @override
  String get helpGridStandardDescription =>
      'Netzanschluss-Standard für Ihr Land';

  @override
  String get helpPortRange => 'Port muss zwischen 1 und 65535 liegen';

  @override
  String get helpPortWarning =>
      '• Stellen Sie sicher, dass der Port nicht von anderen Diensten verwendet wird\n• Nach der Konfiguration wird das Gerät möglicherweise neu gestartet\n• Standard-Ports sollten nur geändert werden, wenn notwendig';

  @override
  String helpCurrentPercentageLimit(String limit) {
    return 'Aktuelle Begrenzung: $limit%';
  }

  @override
  String get helpServerUrlFormat => 'Ohne http:// oder https://';

  @override
  String helpDefaultPort(String port) {
    return 'Standard: $port';
  }

  @override
  String get helpDefaultPortNote =>
      'Standard-Ports werden nicht in URL angezeigt';

  @override
  String get helpConfigureOnlineMonitoring =>
      'Konfigurieren Sie die Server für das Online-Monitoring';

  @override
  String get helpOnlineMonitoringInstructions =>
      '• Geben Sie die URL des Monitoring-Servers ein\n• Tragen Sie Ihre Zugangsdaten ein\n• Optional können Sie einen zweiten Server konfigurieren\n• Das Upload-Intervall bestimmt, wie oft Daten gesendet werden\n• Nach der Konfiguration werden Daten automatisch hochgeladen';

  @override
  String get helpServerExampleIp => 'z.B. 192.168.1.100';

  @override
  String get helpServerExampleDomain => 'z.B. monitoring.example.com';

  @override
  String get helpPortExample => 'z.B. 10000';

  @override
  String get helpSystemIdExample => 'z.B. 1234';

  @override
  String get helpUploadIntervalExample => 'z.B. 30';

  @override
  String get helpProtocolExample => 'z.B. solar.pihost.org';

  @override
  String get helpOnlineMonitoringDescription =>
      '• Stellen Sie sicher, dass die Server-URLs korrekt sind\n• Optional: Sekundärer Server als Backup\n• Upload-Intervall: 1-3600 Sekunden\n• Änderungen werden sofort übernommen';

  @override
  String get helpManageDeviceSettings =>
      'Verwalten Sie die grundlegenden Einstellungen Ihres Geräts.';

  @override
  String get helpNoSettingsAvailable => 'Keine Einstellungen verfügbar';

  @override
  String get helpSettingsApplyImmediately =>
      'Änderungen werden sofort auf das Gerät übertragen. Einstellungen mit Bestätigungsanforderung zeigen einen Dialog vor der Änderung an.';

  @override
  String get helpConfirmationRequired => 'Bestätigung erforderlich';

  @override
  String get helpProtectDevice =>
      'Schützen Sie Ihr Gerät mit Benutzername und Passwort.';

  @override
  String get helpAuthToggle =>
      'Aktiviert oder deaktiviert die Passwortabfrage für das Gerät';

  @override
  String get helpUsernameCannotChange =>
      'Benutzername kann nicht geändert werden';

  @override
  String get helpEnterSecurePassword => 'Geben Sie ein sicheres Passwort ein';

  @override
  String get helpAuthWarning =>
      'Warnung: Wenn die Authentifizierung deaktiviert ist, kann jeder im Netzwerk auf das Gerät zugreifen.';

  @override
  String get dialogWifiConfigSending => 'WiFi-Konfiguration wird gesendet...';

  @override
  String get dialogSettingChanging => 'Einstellung wird geändert...';

  @override
  String dialogPowerLimitSetting(String percentage) {
    return 'Setze Leistungsbegrenzung auf $percentage%...';
  }

  @override
  String dialogConfirmToggleSetting(String settingName, String action) {
    return '$settingName $action?';
  }

  @override
  String dialogConfirmToggleMessage(String settingName, String action) {
    return 'Möchten Sie $settingName wirklich $action?';
  }

  @override
  String get dialogActionEnable => 'aktivieren';

  @override
  String get dialogActionDisable => 'deaktivieren';

  @override
  String get dialogDisableAuthTitle => 'Authentifizierung deaktivieren?';

  @override
  String get dialogDisableAuthMessage =>
      'Möchten Sie die Authentifizierung wirklich deaktivieren? Das Gerät wird danach ohne Passwortschutz zugänglich sein.';

  @override
  String get infoNoGraphFields =>
      'Dieses Gerät hat keine sichtbaren Diagrammfelder.';

  @override
  String get infoDataRange =>
      'Datenbereich: Letzte 5 Minuten | Aktualisierung: alle 5 Sekunden';

  @override
  String get infoWattRoundingNote =>
      'Watt-Werte werden auf volle Prozentschritte gerundet';

  @override
  String get shellyScriptsScreenTitle => 'Scripts & Automationen';

  @override
  String get shellyScriptDetailTitle => 'Script-Details';

  @override
  String get shellyScriptConfigTitle => 'Parameter konfigurieren';

  @override
  String get shellyScriptLibraryTitle => 'Script-Vorlagen';

  @override
  String get shellyScriptPreviewTitle => 'Code-Vorschau';

  @override
  String get shellyScriptUpdateTitle => 'Parameter aktualisieren';

  @override
  String get statusActivated => 'Aktiviert';

  @override
  String get statusDeactivated => 'Deaktiviert';

  @override
  String get statusRunning => 'Läuft';

  @override
  String get statusStopped => 'Gestoppt';

  @override
  String get shellyScriptsConfigureParams => 'Parameter konfigurieren';

  @override
  String get shellyScriptsDirectInstall => 'Direkt installieren';

  @override
  String get shellyScriptsRepairScript =>
      'Script reparieren (fehlgeschlagenes Update)';

  @override
  String get shellyScriptsUpgradeVersion => 'Auf neue Version aktualisieren';

  @override
  String get shellyScriptsLoadingCode => 'Lade Script-Code...';

  @override
  String get shellyScriptsLoadingCurrent => 'Lade aktuelles Script...';

  @override
  String get shellyScriptsStoppingScript => 'Stoppe Script...';

  @override
  String get shellyScriptsPreparingUpdate => 'Bereite Update vor...';

  @override
  String get shellyScriptsUpdatingScript => 'Aktualisiere Script...';

  @override
  String get shellyScriptsFinalizingUpdate => 'Finalisiere Update...';

  @override
  String get shellyScriptsDeletingScript => 'Lösche Script...';

  @override
  String get shellyScriptsActivatingScript => 'Aktiviere Script...';

  @override
  String get shellyScriptsDeactivatingScript => 'Deaktiviere Script...';

  @override
  String get shellyScriptsStartingScript => 'Starte Script...';

  @override
  String get shellyScriptsStartScript => 'Script starten';

  @override
  String get shellyScriptsStopScript => 'Script stoppen';

  @override
  String get shellyScriptsCreatingScript => 'Erstelle Script auf Gerät...';

  @override
  String get shellyScriptsUploadingCode => 'Lade Script-Code hoch...';

  @override
  String get shellyScriptsFinalizingInstall => 'Finalisiere Installation...';

  @override
  String get shellyScriptsSearchingDevices => 'Suche Geräte...';

  @override
  String shellyScriptsScriptUpdated(String version) {
    return 'Script erfolgreich auf Version $version aktualisiert';
  }

  @override
  String get shellyScriptsScriptDeleted => 'Script gelöscht';

  @override
  String get shellyScriptsScriptActivated => 'Script aktiviert';

  @override
  String get shellyScriptsScriptDeactivated => 'Script deaktiviert';

  @override
  String get shellyScriptsScriptStarted => 'Script gestartet';

  @override
  String get shellyScriptsScriptStopped => 'Script gestoppt';

  @override
  String get shellyScriptsScriptInstalled =>
      'Script erfolgreich installiert und gestartet';

  @override
  String get shellyScriptsParamsUpdated => 'Parameter erfolgreich aktualisiert';

  @override
  String get shellyScriptsErrorLoadingCode =>
      'Konnte Script-Code nicht abrufen';

  @override
  String get shellyScriptsErrorNoMetadata =>
      'Konnte Template-Metadaten nicht extrahieren';

  @override
  String get shellyScriptsErrorNoTemplateId => 'Template-ID fehlt in Metadaten';

  @override
  String shellyScriptsErrorTemplateNotFound(String templateId) {
    return 'Vorlage nicht gefunden: $templateId';
  }

  @override
  String shellyScriptsErrorUpdatingStaging(String error) {
    return 'Fehler beim Aktualisieren: $error\nScript bleibt im Staging-Status (0.0.0).';
  }

  @override
  String get shellyScriptsErrorNoScriptId =>
      'Fehler: Konnte Script-ID nicht abrufen';

  @override
  String shellyScriptsErrorUploadingCode(String error) {
    return 'Fehler beim Hochladen: $error\nScript bleibt im Staging-Status (0.0.0).';
  }

  @override
  String get shellyScriptsErrorCodeUploadFailed =>
      'Fehler beim Hochladen des Codes';

  @override
  String shellyScriptsErrorInstalling(String error) {
    return 'Fehler beim Installieren des Scripts: $error';
  }

  @override
  String shellyScriptsErrorLoadingTemplates(String error) {
    return 'Fehler beim Laden der Vorlagen: $error';
  }

  @override
  String get shellyScriptsErrorSectionTitle => 'Fehler';

  @override
  String get shellyScriptErrorCrashed => 'Absturz';

  @override
  String get shellyScriptErrorSyntax => 'Syntaxfehler';

  @override
  String get shellyScriptErrorReference => 'Referenzfehler';

  @override
  String get shellyScriptErrorType => 'Typfehler';

  @override
  String get shellyScriptErrorMemory => 'Speicher voll';

  @override
  String get shellyScriptErrorCodespace => 'Code-Speicher voll';

  @override
  String get shellyScriptErrorInternal => 'Interner Fehler';

  @override
  String get shellyScriptErrorNotImplemented => 'Nicht implementiert';

  @override
  String get shellyScriptErrorFileRead => 'Datei-Lesefehler';

  @override
  String get shellyScriptErrorBadArgs => 'Ungültige Parameter';

  @override
  String shellyScriptsValidationRequired(String label) {
    return '$label ist erforderlich';
  }

  @override
  String shellyScriptsValidationMustBeNumber(String label) {
    return '$label muss eine Zahl sein';
  }

  @override
  String shellyScriptsValidationMinValue(String label, String min) {
    return '$label muss mindestens $min sein';
  }

  @override
  String shellyScriptsValidationMaxValue(String label, String max) {
    return '$label darf höchstens $max sein';
  }

  @override
  String get shellyScriptsValidationPortRange =>
      'Port muss zwischen 1 und 65535 liegen';

  @override
  String get shellyScriptsValidationFieldRequired =>
      'Dieses Feld ist erforderlich';

  @override
  String get shellyScriptsValidationInvalidValue => 'Ungültiger Wert';

  @override
  String get shellyScriptsDialogNewParamsTitle => 'Neue Parameter verfügbar';

  @override
  String shellyScriptsDialogNewParamsMessage(
    String version,
    String params,
    String currentVersion,
    String newVersion,
  ) {
    return 'Die neue Version $version enthält neue Parameter, die konfiguriert werden müssen:\n\n$params\n\nAktuelle Version: $currentVersion\nNeue Version: $newVersion';
  }

  @override
  String get shellyScriptsDialogUpgradeTitle =>
      'Auf neue Version aktualisieren?';

  @override
  String shellyScriptsDialogUpgradeMessage(String version) {
    return 'Möchten Sie das Script auf Version $version aktualisieren?\n\nDiese Operation wird das Script kurzzeitig stoppen und neu starten.';
  }

  @override
  String get shellyScriptsDialogDeleteTitle => 'Script löschen?';

  @override
  String shellyScriptsDialogDeleteMessage(String name) {
    return 'Möchten Sie das Script \"$name\" wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String get shellyScriptsDialogInstallTitle => 'Script installieren?';

  @override
  String shellyScriptsDialogInstallMessage(String name) {
    return 'Möchten Sie das Script \"$name\" ohne Vorschau installieren?';
  }

  @override
  String get shellyScriptsDialogInstallConfirmTitle =>
      'Script auf Gerät installieren?';

  @override
  String shellyScriptsDialogInstallConfirmMessage(String name) {
    return 'Möchten Sie das Script \"$name\" wirklich auf Ihrem Shelly-Gerät installieren?';
  }

  @override
  String get shellyScriptsDialogUpdateParamsTitle => 'Parameter aktualisieren?';

  @override
  String get shellyScriptsDialogUpdateParamsMessage =>
      'Möchten Sie die Parameter wirklich aktualisieren? Das Script wird mit den neuen Werten neu generiert.';

  @override
  String get shellyScriptsDialogCompatibilityTitle =>
      'Kompatibilitäts-Information';

  @override
  String get shellyScriptsInfoAutomation => 'Automatisierung';

  @override
  String get shellyScriptsInfoFailed => 'Fehlgeschlagen';

  @override
  String shellyScriptsInfoVersion(String version, String id) {
    return 'Version: $version • ID: $id';
  }

  @override
  String shellyScriptsInfoScriptId(String id) {
    return 'Script ID: $id';
  }

  @override
  String shellyScriptsInfoVersionUpdating(String version) {
    return 'Version: $version (wird aktualisiert)';
  }

  @override
  String get shellyScriptsHelpEditTip =>
      'Tippen Sie auf Bearbeiten um ein Script zu öffnen.';

  @override
  String get shellyScriptsEmptyStateTitle => 'Keine Scripts verfügbar';

  @override
  String get shellyScriptsEmptyStateMessage =>
      'Auf diesem Gerät sind aktuell keine Scripts konfiguriert.';

  @override
  String get shellyScriptsInfoTitle => 'Hinweise:';

  @override
  String get shellyScriptsInfoContent =>
      '• Aktiviert: Script läuft automatisch bei Events\n• Läuft: Script wird gerade ausgeführt\n• Status wird alle 10 Sekunden aktualisiert\n• Bearbeiten: Öffnet Detailansicht mit Steuerung';

  @override
  String get shellyScriptsFabCreateFromTemplate => 'Aus Vorlage erstellen';

  @override
  String get shellyScriptsStatusTitle => 'Status';

  @override
  String get shellyScriptsAutostartTitle => 'Autostart aktiviert';

  @override
  String get shellyScriptsAutostartSubtitle =>
      'Script startet automatisch bei konfigurierten Events';

  @override
  String get shellyScriptsControlTitle => 'Steuerung:';

  @override
  String get shellyScriptsControlInfo =>
      '• Autostart: Script läuft automatisch bei Events\n• Start/Stop: Manuelles Starten/Stoppen des Scripts\n• Status wird automatisch aktualisiert';

  @override
  String get shellyScriptsConfigInfoText =>
      'Füllen Sie alle Parameter aus und tippen Sie auf \"Vorschau\", um den generierten Script-Code zu sehen.';

  @override
  String get shellyScriptsPreviewSubtitle =>
      'Prüfen Sie den generierten Code vor der Installation';

  @override
  String get shellyScriptsPreviewInfoText =>
      'Das Script wird auf Ihrem Shelly-Gerät installiert, aktiviert und automatisch gestartet.';

  @override
  String get shellyScriptsUpdateInfoText =>
      'Aktualisieren Sie die Parameter. Das Script wird mit den neuen Werten neu generiert und hochgeladen.';

  @override
  String get shellyScriptsSearchPlaceholder => 'Vorlagen durchsuchen...';

  @override
  String get shellyScriptsShowAllToggle => 'Alle Scripte anzeigen';

  @override
  String get shellyScriptsCurrentDevice => 'Aktuelles Gerät:';

  @override
  String get shellyScriptsCompatibleDevices => 'Kompatible Geräte:';

  @override
  String get shellyScriptsAllDevices => 'Alle Geräte';

  @override
  String get shellyScriptsNotCompatibleWarning =>
      'Nicht für dieses Gerät vorgesehen';

  @override
  String shellyScriptsVersionDisplay(String version) {
    return 'Version $version';
  }

  @override
  String shellyScriptsAuthorCredit(String author) {
    return 'von $author';
  }

  @override
  String shellyScriptsRequiresDevices(String devices) {
    return 'Benötigt: $devices';
  }

  @override
  String shellyScriptsParamCount(int count) {
    return '$count Parameter';
  }

  @override
  String get shellyScriptsFilterAll => 'Alle';

  @override
  String get shellyScriptsEmptyLibrary => 'Keine Vorlagen gefunden';

  @override
  String get shellyScriptsUnknownModel => 'Unbekannt';

  @override
  String get shellyScriptsNoDevicesFound => 'Keine passenden Geräte gefunden';

  @override
  String shellyScriptsAutoFilledFrom(String deviceName) {
    return 'Auto-ausgefüllt von: $deviceName';
  }

  @override
  String shellyScriptsSelectDeviceCount(int count) {
    return 'Gerät auswählen ($count gefunden)';
  }

  @override
  String shellyScriptsSourceProperty(String sourceProperty) {
    return 'Quelle: $sourceProperty';
  }

  @override
  String shellyScriptsFilterProperty(String filter) {
    return 'Filter: $filter';
  }

  @override
  String get shellyScriptsNoDevicesFoundHelper => '(keine Geräte gefunden)';

  @override
  String get shellyScriptsAutoFilledHelper => '(automatisch ausgefüllt)';

  @override
  String shellyScriptsDevicesFoundHelper(int count) {
    return '($count Geräte gefunden)';
  }

  @override
  String shellyScriptsSelectDeviceModal(String label) {
    return 'Gerät auswählen für \"$label\"';
  }

  @override
  String get shellyScriptsParamRequired => '(erforderlich)';

  @override
  String get unknownUpdating => 'Unknown (wird aktualisiert)';

  @override
  String get wifiConfigurationCompleted => 'WiFi-Konfiguration abgeschlossen';

  @override
  String get accessPointConfigured => 'Access Point erfolgreich konfiguriert';

  @override
  String get powerLimitSet => 'Leistungslimit erfolgreich gesetzt';

  @override
  String get deviceRestarting => 'Gerät wird neu gestartet';

  @override
  String errorLoadingConfiguration(String error) {
    return 'Fehler beim Laden der Konfiguration: $error';
  }

  @override
  String errorRestartingDevice(String error) {
    return 'Fehler beim Neustarten des Geräts: $error';
  }

  @override
  String get errorUnknownFirmware =>
      'Nicht möglich da die aktuelle Firmware unbekannt ist, in einem Moment noch mal versuchen (warte noch auf Daten)';

  @override
  String get loadingDeviceInfo => 'Lade Geräteinformationen...';

  @override
  String get loadingConfiguration => 'Lade aktuelle Konfiguration...';

  @override
  String get menuDeviceInfo => 'Geräteinformationen';

  @override
  String get menuConfigureWifi => 'WiFi konfigurieren';

  @override
  String get menuSetupApWifi => 'AP WiFi einrichten';

  @override
  String get menuConfigurePassword => 'Passwort konfigurieren';

  @override
  String get menuSetupWlan => 'WLAN-Verbindung einrichten';

  @override
  String get menuOnlineMonitoring => 'Online-Monitoring konfigurieren';

  @override
  String get menuGeneralSettings => 'Allgemeine Einstellungen';

  @override
  String get menuInverterPowerLimit => 'Wechselrichterleistung begrenzen';

  @override
  String get menuOutputPowerLimit => 'Ausgangsleistung begrenzen';

  @override
  String get menuRestartOpendtu => 'OpenDTU neu starten';

  @override
  String get menuConfigureRpcPort => 'RPC UDP Port konfigurieren';

  @override
  String get menuSubtitleSetupNetwork => 'Netzwerkverbindung einrichten';

  @override
  String get menuSubtitleSetupAccessPoint => 'AP WiFi einrichten';

  @override
  String get menuSubtitleMqttSetup => 'MQTT-Broker Verbindung einrichten';

  @override
  String get menuSubtitleToggleAllInverters => 'Schaltet alle Wechselrichter';

  @override
  String get deviceFallbackName => 'Gerät';

  @override
  String get labelPort => 'Port';

  @override
  String get labelPowerInput => 'Input (Netz → Gerät)';

  @override
  String get labelPowerOutput => 'Output (Gerät → Netz)';

  @override
  String get hintHostnameOrIp => 'Hostname oder IP-Adresse';

  @override
  String get helpDevicePoweredOn =>
      '• Stellen Sie sicher, dass Ihr Gerät eingeschaltet ist';

  @override
  String get helpStrongPassword =>
      '• Ein starkes Passwort schützt Ihr Netzwerk';

  @override
  String get helpMqttPorts =>
      '• Standard MQTT-Port ist 1883 (unverschlüsselt) oder 8883 (TLS)';

  @override
  String get helpMqttAuthRecommended =>
      '• Die Authentifizierung ist optional, wird aber empfohlen';

  @override
  String get helpMqttAutoConnect =>
      '• Nach der Konfiguration verbindet sich das Gerät automatisch';

  @override
  String get infoConfigureAccessPoint =>
      'Konfigurieren Sie den WiFi Access Point Ihres Geräts';

  @override
  String get infoMqttAuthToggle =>
      'Aktiviert Benutzername und Passwort für MQTT';

  @override
  String get infoMqttDisabled =>
      'MQTT ist deaktiviert. Das Gerät wird nicht mit einem MQTT-Broker verbunden sein.';

  @override
  String get noRoleSupport => 'Keine Rollen-Unterstützung';

  @override
  String get noDetailsAvailable => 'Keine Details verfügbar';

  @override
  String get onlineMonitoringConfigured =>
      'Online-Monitoring erfolgreich konfiguriert';

  @override
  String get authenticationConfigured =>
      'Authentifizierung erfolgreich konfiguriert';

  @override
  String get mqttConfigurationUpdated =>
      'MQTT-Konfiguration erfolgreich aktualisiert';

  @override
  String get fieldDailyYield => 'Tagesertrag';

  @override
  String get fieldTotalYield => 'Gesamtertrag';

  @override
  String get fieldCurrentPower => 'Aktuelle Leistung';

  @override
  String get fieldAcPower => 'AC Leistung';

  @override
  String get fieldDcPower => 'DC Leistung';

  @override
  String get fieldActivePower => 'Wirkleistung';

  @override
  String get fieldReactivePower => 'Blindleistung';

  @override
  String get fieldApparentPower => 'Scheinleistung';

  @override
  String get fieldPowerFactor => 'Leistungsfaktor';

  @override
  String get fieldDcTotalPower => 'DC Gesamtleistung';

  @override
  String fieldPvVoltage(String num) {
    return 'PV$num Spannung';
  }

  @override
  String fieldPvCurrent(String num) {
    return 'PV$num Strom';
  }

  @override
  String fieldPvPower(String num) {
    return 'PV$num Leistung';
  }

  @override
  String fieldPvTotalYield(String num) {
    return 'PV$num Gesamtertrag';
  }

  @override
  String fieldPvDailyYield(String num) {
    return 'PV$num Tagesertrag';
  }

  @override
  String get fieldTotalEnergyImport => 'Gesamtenergie Bezug';

  @override
  String get fieldTotalEnergyExport => 'Gesamtenergie Einspeisung';

  @override
  String get fieldTotalEnergy => 'Gesamtenergie';

  @override
  String get fieldEnergyPerMinuteImport => 'Energie pro Minute (Bezug)';

  @override
  String get fieldEnergyPerMinuteExport => 'Energie pro Minute (Einspeisung)';

  @override
  String get fieldOutputLimit => 'Ausgangsleistung Limit';

  @override
  String get fieldInputLimit => 'Eingangsleistung Limit';

  @override
  String get fieldGridVoltage => 'Netzspannung';

  @override
  String get fieldGridCurrent => 'Netzstrom';

  @override
  String get fieldGridFrequency => 'Netzfrequenz';

  @override
  String get fieldVoltagePhase1 => 'Spannung Phase 1';

  @override
  String get fieldVoltagePhase2 => 'Spannung Phase 2';

  @override
  String get fieldVoltagePhase3 => 'Spannung Phase 3';

  @override
  String get fieldCurrentPhase1 => 'Strom Phase 1';

  @override
  String get fieldCurrentPhase2 => 'Strom Phase 2';

  @override
  String get fieldCurrentPhase3 => 'Strom Phase 3';

  @override
  String fieldVoltageInstance(String instanceNum) {
    return 'Spannung $instanceNum';
  }

  @override
  String fieldCurrentInstance(String instanceNum) {
    return 'Strom $instanceNum';
  }

  @override
  String get fieldDcVoltage => 'DC Spannung';

  @override
  String get fieldDcCurrent => 'DC Strom';

  @override
  String get fieldAcVoltage => 'AC Spannung';

  @override
  String get fieldAcCurrent => 'AC Strom';

  @override
  String get fieldBatteryLevel => 'Batterie Level';

  @override
  String get fieldBatteryPower => 'Batterie Leistung';

  @override
  String get fieldBatterySoc => 'Batterie SOC';

  @override
  String get fieldBatteryState => 'Batterie Status';

  @override
  String get fieldChargeMaxLimit => 'Maximale Ladeleistung';

  @override
  String get fieldDischargeMaxLimit => 'Maximale Entladeleistung';

  @override
  String get fieldPackState => 'Pack Status';

  @override
  String get fieldCellVoltageMin => 'Zellspannung Min';

  @override
  String get fieldCellVoltageMax => 'Zellspannung Max';

  @override
  String get fieldCellTemperatureMax => 'Zelltemperatur Max';

  @override
  String get fieldBatteryPackEmpty => 'Keine Batteriepack-Daten verfügbar';

  @override
  String fieldBatteryPackNumber(String num) {
    return 'Batterie #$num';
  }

  @override
  String get fieldBatteryStateIdle => 'Idle';

  @override
  String get fieldBatteryStateCharging => 'Lädt';

  @override
  String get fieldBatteryStateDischarging => 'Entlädt';

  @override
  String get fieldBatteryStateUnknown => 'Unbekannt';

  @override
  String get fieldBatteryType => 'Typ';

  @override
  String get fieldTemperature => 'Temperatur';

  @override
  String get fieldUptime => 'Betriebszeit';

  @override
  String get fieldLimitStatus => 'Limit-Status';

  @override
  String get fieldPowerLimit => 'Leistungslimit';

  @override
  String get fieldModel => 'Modell';

  @override
  String get fieldRatedPower => 'Nennleistung';

  @override
  String get fieldFirmwareVersion => 'Firmware Version';

  @override
  String get fieldSerialNumber => 'Seriennummer';

  @override
  String get fieldArticleNumber => 'Artikelnummer';

  @override
  String get fieldManufacturer => 'Hersteller';

  @override
  String get fieldAverageTemperature => 'Durchschnittstemperatur';

  @override
  String get fieldMaxTemperature => 'Max. Temperatur';

  @override
  String get fieldMinTemperature => 'Min. Temperatur';

  @override
  String get fieldWifiSignal => 'WiFi Signal';

  @override
  String get fieldWifiState => 'WiFi Status';

  @override
  String fieldSwitchInstance(String instanceNum) {
    return 'Switch $instanceNum';
  }

  @override
  String fieldPowerInstance(String instanceNum) {
    return 'Leistung $instanceNum';
  }

  @override
  String fieldEnergyInstance(String instanceNum) {
    return 'Energie $instanceNum';
  }

  @override
  String fieldFrequencyInstance(String instanceNum) {
    return 'Frequenz $instanceNum';
  }

  @override
  String fieldPowerFactorInstance(String instanceNum) {
    return 'Leistungsfaktor $instanceNum';
  }

  @override
  String fieldActivePowerInstance(String instanceNum) {
    return 'Wirkleistung $instanceNum';
  }

  @override
  String fieldReactivePowerInstance(String instanceNum) {
    return 'Blindleistung $instanceNum';
  }

  @override
  String fieldApparentPowerInstance(String instanceNum) {
    return 'Scheinleistung $instanceNum';
  }

  @override
  String fieldTemperatureInstance(String instanceNum) {
    return 'Temperatur $instanceNum';
  }

  @override
  String fieldStatusInstance(String instanceNum) {
    return 'Status $instanceNum';
  }

  @override
  String fieldYieldInstance(String instanceNum) {
    return 'Ertrag $instanceNum';
  }

  @override
  String get fieldTotalPower => 'Gesamtleistung';

  @override
  String get fieldTotalCurrent => 'Gesamtstrom';

  @override
  String get fieldTotalVoltage => 'Gesamtspannung';

  @override
  String get fieldActivePowerTotal => 'Wirkleistung Gesamt';

  @override
  String get fieldReactivePowerTotal => 'Blindleistung Gesamt';

  @override
  String get fieldApparentPowerTotal => 'Scheinleistung Gesamt';

  @override
  String get fieldEnergyTotal => 'Energie Gesamt';

  @override
  String get fieldCombinedPower => 'Kombinierte Leistung';

  @override
  String get fieldPowerPhase1 => 'Leistung Phase 1';

  @override
  String get fieldPowerPhase2 => 'Leistung Phase 2';

  @override
  String get fieldPowerPhase3 => 'Leistung Phase 3';

  @override
  String get fieldActivePowerPhase1 => 'Wirkleistung Phase 1';

  @override
  String get fieldActivePowerPhase2 => 'Wirkleistung Phase 2';

  @override
  String get fieldActivePowerPhase3 => 'Wirkleistung Phase 3';

  @override
  String get fieldReactivePowerPhase1 => 'Blindleistung Phase 1';

  @override
  String get fieldReactivePowerPhase2 => 'Blindleistung Phase 2';

  @override
  String get fieldReactivePowerPhase3 => 'Blindleistung Phase 3';

  @override
  String get fieldApparentPowerPhase1 => 'Scheinleistung Phase 1';

  @override
  String get fieldApparentPowerPhase2 => 'Scheinleistung Phase 2';

  @override
  String get fieldApparentPowerPhase3 => 'Scheinleistung Phase 3';

  @override
  String get fieldFrequencyPhase1 => 'Frequenz Phase 1';

  @override
  String get fieldFrequencyPhase2 => 'Frequenz Phase 2';

  @override
  String get fieldFrequencyPhase3 => 'Frequenz Phase 3';

  @override
  String get fieldInverterType => 'Inverter Typ';

  @override
  String get fieldAccessModel => 'Zugriffsmodus';

  @override
  String get fieldDtuSerialNumber => 'DTU Seriennummer';

  @override
  String get fieldNetworkMode => 'Netzwerkmodus';

  @override
  String get fieldServerDomain => 'Server Domain';

  @override
  String get fieldServerPort => 'Server Port';

  @override
  String get fieldSendInterval => 'Sendeintervall';

  @override
  String get fieldChannel => 'Kanal';

  @override
  String get fieldMeterKind => 'Zähler Art';

  @override
  String get fieldMeterInterface => 'Zähler Schnittstelle';

  @override
  String get fieldZeroExportEnabled => 'Nulleinspeisung aktiviert';

  @override
  String get fieldZeroExportAddress => 'Nulleinspeisung Adresse';

  @override
  String get fieldLockPasswordSet => 'Sperrpasswort gesetzt';

  @override
  String get fieldLockTimeMinutes => 'Sperrzeit Minuten';

  @override
  String get fieldInverter => 'Wechselrichter';

  @override
  String get fieldInverterToggleDescription =>
      'Wechselrichter ein- oder ausschalten';

  @override
  String get fieldNumberOfInverters => 'Anzahl Wechselrichter';

  @override
  String get fieldCurrentPvPower => 'Aktuelle Leistung PV';

  @override
  String get fieldMonthlyYield => 'Monatsertrag';

  @override
  String get fieldYearlyYield => 'Jahresertrag';

  @override
  String get fieldVoltage => 'Spannung';

  @override
  String get fieldCurrent => 'Strom';

  @override
  String get fieldBatteryCycles => 'Zyklen';

  @override
  String get fieldBatteryCapacityGross => 'Kapazität (brutto)';

  @override
  String get fieldBatteryCapacityNet => 'Kapazität (netto)';

  @override
  String get fieldTotalConsumption => 'Gesamtverbrauch';

  @override
  String get fieldConsumptionFromPv => 'Verbrauch aus PV';

  @override
  String get fieldConsumptionFromGrid => 'Verbrauch aus Netz';

  @override
  String get fieldConsumptionFromBattery => 'Verbrauch aus Batterie';

  @override
  String get fieldFrequency => 'Frequenz';

  @override
  String get fieldMaxInverterPower => 'Max. Wechselrichterleistung';

  @override
  String get fieldInverterGenerationPower =>
      'Wechselrichter-Erzeugungsleistung';

  @override
  String get fieldIsolationResistance => 'Isolationswiderstand';

  @override
  String get categoryPv1 => 'PV1';

  @override
  String get categoryPv2 => 'PV2';

  @override
  String get categoryPv3 => 'PV3';

  @override
  String get categoryPv4 => 'PV4';

  @override
  String get categoryAcGrid => 'AC (Netz)';

  @override
  String get categoryAcTotal => 'AC Gesamt';

  @override
  String get categoryPhase1 => 'Phase 1';

  @override
  String get categoryPhase2 => 'Phase 2';

  @override
  String get categoryPhase3 => 'Phase 3';

  @override
  String get categoryTotals => 'Summen';

  @override
  String get categoryAcPhase1 => 'AC Phase 1';

  @override
  String get categoryAcPhase2 => 'AC Phase 2';

  @override
  String get categoryAcPhase3 => 'AC Phase 3';

  @override
  String get categoryDcString1 => 'DC String 1';

  @override
  String get categoryDcString2 => 'DC String 2';

  @override
  String get categoryDcString3 => 'DC String 3';

  @override
  String get categorySystem => 'System';

  @override
  String get categoryDeviceInfo => 'Geräteinformationen';

  @override
  String get categoryBattery => 'Batterie';

  @override
  String get categoryInverter => 'Wechselrichter';

  @override
  String get categoryMemory => 'Speicher';

  @override
  String get categoryStorage => 'Lagerung';

  @override
  String get categoryPowerMeter => 'Stromzähler';

  @override
  String get categoryHomeConsumption => 'Hausverbrauch';

  @override
  String categoryMeasurementInstance(String instanceNum) {
    return 'Messung $instanceNum';
  }

  @override
  String categorySwitchInstance(String instanceNum) {
    return 'Switch $instanceNum';
  }

  @override
  String categoryPmMeasurementInstance(String instanceNum) {
    return 'PM Messung $instanceNum';
  }

  @override
  String categoryInverterInstance(String instanceNum) {
    return 'Wechselrichter $instanceNum';
  }

  @override
  String categoryStringInstance(String instanceNum) {
    return 'String $instanceNum';
  }

  @override
  String get categoryEm1Combined => 'Kombiniert';

  @override
  String get categoryPm1Combined => 'PM Kombiniert';

  @override
  String get categorySwitchCombined => 'Switch Kombiniert';

  @override
  String get categoryPowerMeterPhase1 => 'Stromzähler Phase 1';

  @override
  String get categoryPowerMeterPhase2 => 'Stromzähler Phase 2';

  @override
  String get categoryPowerMeterPhase3 => 'Stromzähler Phase 3';

  @override
  String get fieldSolarPower => 'Leistung Solar';

  @override
  String get fieldConsumption => 'Verbrauch';

  @override
  String get fieldGridImport => 'Bezug Netz';

  @override
  String get fieldBatteryChargeDischargePower =>
      'Batterie Lade/Entladeleistung';

  @override
  String get fieldSolarInputPower => 'Solar Eingangsleistung';

  @override
  String get fieldHomeOutputPower => 'Ausgang Haus';

  @override
  String get fieldAcMode => 'AC Modus';

  @override
  String get fieldPackCount => 'Pack Anzahl';

  @override
  String get menuWifiConfiguration => 'WiFi konfigurieren';

  @override
  String get menuOnlineMonitoringConfiguration =>
      'Online-Monitoring konfigurieren';

  @override
  String get menuRestartDevice => 'Gerät neustarten';

  @override
  String get menuAccessPointConfiguration => 'Access Point konfigurieren';

  @override
  String get menuPowerLimit => 'Leistungsbegrenzung';

  @override
  String get menuAuthentication => 'Authentifizierung';

  @override
  String get menuAutomation => 'Automatisierung';

  @override
  String get menuPowerSettings => 'Leistungseinstellungen';

  @override
  String get menuBatteryLimits => 'Batterie-Limits';

  @override
  String get menuAdvancedPowerSettings => 'Erweiterte Leistungseinstellungen';

  @override
  String get menuPortConfiguration => 'Port konfigurieren';

  @override
  String get menuSubtitleGeneralSettings =>
      'Grundlegende Geräteeinstellungen verwalten';

  @override
  String get menuSubtitleWifiConfiguration => 'Netzwerkverbindung einrichten';

  @override
  String get menuSubtitleOnlineMonitoring =>
      'Server für Datenübertragung einrichten';

  @override
  String get menuSubtitleRestartDevice => 'Startet das Gerät neu';

  @override
  String get menuSubtitleAccessPoint => 'WiFi Access Point einrichten';

  @override
  String get menuSubtitlePowerLimit => 'Ausgangsleistung begrenzen';

  @override
  String get menuSubtitleAuthentication => 'Zugangsdaten konfigurieren';

  @override
  String get menuSubtitleDeviceInfo => 'Geräteinformationen anzeigen';

  @override
  String get menuSubtitlePowerSettings => 'Leistungsparameter einstellen';

  @override
  String get menuSubtitleBatteryLimits => 'Batterie-Grenzwerte konfigurieren';

  @override
  String get menuSubtitleAdvancedPowerSettings =>
      'Erweiterte Leistungsoptionen';

  @override
  String get menuSubtitlePortConfiguration => 'RPC UDP Port konfigurieren';

  @override
  String get menuSubtitleAutomation => 'Shelly Scripts verwalten';

  @override
  String get menuPercentagePowerLimit => 'Leistungslimit (Prozent)';

  @override
  String get menuSubtitlePercentagePowerLimit =>
      'Wechselrichterleistung begrenzen';

  @override
  String get menuInverterToggle => 'Wechselrichter ein-/ausschalten';

  @override
  String get menuSubtitleInverterToggle => 'Schaltet alle Wechselrichter';

  @override
  String get menuMqttConfiguration => 'MQTT konfigurieren';

  @override
  String get menuSubtitleMqttConfiguration =>
      'MQTT-Broker Verbindung einrichten';

  @override
  String get fieldChipModel => 'Chip Modell';

  @override
  String get fieldHeap => 'Heap';

  @override
  String get fieldSketch => 'Sketch';

  @override
  String get fieldLittleFs => 'LittleFS';

  @override
  String get fieldSocSet => 'SOC Set';

  @override
  String get fieldMinSoc => 'Min SOC';

  @override
  String get fieldGridReverse => 'Netz Rückspeisung';

  @override
  String get fieldLampSwitch => 'Lampe Schalter';

  @override
  String get fieldGridOffMode => 'Netz Aus Modus';

  @override
  String get fieldFanMode => 'Lüfter Modus';

  @override
  String get fieldFanSpeed => 'Lüfter Geschwindigkeit';

  @override
  String get fieldSmartMode => 'Smart Modus';

  @override
  String get fieldTimestamp => 'Zeitstempel';

  @override
  String get fieldTimezone => 'Zeitzone';

  @override
  String get fieldBatteryPacks => 'Batteriepacks';

  @override
  String get fieldSolarInput => 'Solar-Eingang';

  @override
  String get fieldOutputPower => 'Ausgabeleistung';

  @override
  String get fieldInputVoltage => 'Eingangsspannung';

  @override
  String fieldDcStringPower(String name) {
    return '$name - DC-String-Leistung';
  }

  @override
  String fieldDcStringVoltage(String name) {
    return '$name - DC-String-Spannung';
  }

  @override
  String fieldDcInputPower(String prefix) {
    return '$prefix - DC-Eingangsleistung';
  }

  @override
  String fieldAcOutputPower(String prefix) {
    return '$prefix - AC-Ausgangsleistung';
  }

  @override
  String get fieldAllInverters => 'Alle Wechselrichter';

  @override
  String get fieldLamp => 'Lampe';

  @override
  String get fieldEmergencyPowerSupply => 'Notstromversorgung';

  @override
  String get fieldDeviceLightingDescription =>
      'Gerätebeleuchtung ein- oder ausschalten';

  @override
  String get fieldGridPowerModeDescription => 'Netzstrom-Modus für das Gerät';

  @override
  String get fieldNoInverterData => 'Keine Wechselrichter-Daten verfügbar';

  @override
  String get fieldStatusProducing => 'Produziert';

  @override
  String get fieldStatusReachable => 'Erreichbar';

  @override
  String get fieldStatusNotReachable => 'Nicht erreichbar';

  @override
  String get fieldAcFrequency => 'AC Frequenz';

  @override
  String get fieldPower => 'Leistung';

  @override
  String fieldInverterFallback(String num) {
    return 'Wechselrichter $num';
  }

  @override
  String fieldStringFallback(String num) {
    return 'String $num';
  }

  @override
  String errorLoadingAuthConfig(String error) {
    return 'Konnte Authentifizierungs-Konfiguration nicht laden: $error';
  }

  @override
  String errorLoadingWifiConfig(String error) {
    return 'Konnte WiFi-Konfiguration nicht laden: $error';
  }

  @override
  String get firmwareNotSupported => 'Firmware nicht unterstützt';

  @override
  String get firmwareNotSupportedMessage =>
      'Diese Funktion wird von Ihrer OpenDTU-Firmware nicht unterstützt.\n\nBitte installieren Sie die modifizierte Firmware mit REST-API-Unterstützung.';

  @override
  String get downloadFirmware => 'Firmware herunterladen';

  @override
  String get noInvertersFound => 'Keine Wechselrichter gefunden';

  @override
  String get toggleInverters => 'Wechselrichter schalten';

  @override
  String get toggleInvertersPrompt =>
      'Möchten Sie alle Wechselrichter ein- oder ausschalten?';

  @override
  String get selectInverterToToggle => 'Wechselrichter auswählen';

  @override
  String get inverterCurrentlyOn =>
      'Wechselrichter ist aktuell AN. Ausschalten?';

  @override
  String get inverterCurrentlyOff =>
      'Wechselrichter ist aktuell AUS. Einschalten?';

  @override
  String get turnOff => 'Ausschalten';

  @override
  String get turnOn => 'Einschalten';

  @override
  String get turningOnInverters => 'Schalte Wechselrichter ein...';

  @override
  String get turningOffInverters => 'Schalte Wechselrichter aus...';

  @override
  String get invertersTurnedOn => 'Wechselrichter eingeschaltet';

  @override
  String get invertersTurnedOff => 'Wechselrichter ausgeschaltet';

  @override
  String get restartDeviceConfirm => 'Das Gerät wird neugestartet. Fortfahren?';

  @override
  String get menuRestartInverter => 'Wechselrichter neustarten';

  @override
  String get menuSubtitleRestartInverter => 'Startet einen Wechselrichter neu';

  @override
  String get selectInverterToRestart =>
      'Wechselrichter zum Neustarten auswählen';

  @override
  String get selectInverterToSetLimit =>
      'Wechselrichter für Leistungsbegrenzung auswählen';

  @override
  String get restartInverterConfirm => 'Wechselrichter neustarten?';

  @override
  String get restartingInverter => 'Starte Wechselrichter neu...';

  @override
  String get inverterRestarted => 'Wechselrichter neu gestartet';
}
