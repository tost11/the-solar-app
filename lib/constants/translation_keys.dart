/// Type-safe translation keys for data fields and categories
///
/// This file contains compile-time constants for all translatable field names
/// and category display names used throughout the app. These keys map to the
/// corresponding entries in app_de.arb and app_en.arb files.

/// Translation keys for data field names
///
/// Usage:
/// ```dart
/// DeviceDataField(
///   name: 'Tagesertrag',  // Fallback
///   nameKey: FieldTranslationKeys.dailyYield,
///   type: DataFieldType.energy,
///   valueExtractor: (data) => data['dayEnergy'],
/// )
/// ```
class FieldTranslationKeys {
  // Private constructor to prevent instantiation
  FieldTranslationKeys._();

  // =============================================================================
  // Power & Energy Fields (20 keys)
  // =============================================================================

  /// Daily energy yield (Tagesertrag)
  static const String dailyYield = 'fieldDailyYield';

  /// Total energy yield (Gesamtertrag)
  static const String totalYield = 'fieldTotalYield';

  /// Current power (Aktuelle Leistung)
  static const String currentPower = 'fieldCurrentPower';

  /// AC power (AC Leistung)
  static const String acPower = 'fieldAcPower';

  /// DC power (DC Leistung)
  static const String dcPower = 'fieldDcPower';

  /// Active power (Wirkleistung)
  static const String activePower = 'fieldActivePower';

  /// Reactive power (Blindleistung)
  static const String reactivePower = 'fieldReactivePower';

  /// Apparent power (Scheinleistung)
  static const String apparentPower = 'fieldApparentPower';

  /// Power factor (Leistungsfaktor)
  static const String powerFactor = 'fieldPowerFactor';

  /// DC total power (DC Gesamtleistung)
  static const String dcTotalPower = 'fieldDcTotalPower';

  /// PV voltage (PV{num} Spannung) - parameterized with {num}
  static const String pvVoltage = 'fieldPvVoltage';

  /// PV current (PV{num} Strom) - parameterized with {num}
  static const String pvCurrent = 'fieldPvCurrent';

  /// PV power (PV{num} Leistung) - parameterized with {num}
  static const String pvPower = 'fieldPvPower';

  /// PV total yield (PV{num} Gesamtertrag) - parameterized with {num}
  static const String pvTotalYield = 'fieldPvTotalYield';

  /// PV daily yield (PV{num} Tagesertrag) - parameterized with {num}
  static const String pvDailyYield = 'fieldPvDailyYield';

  /// Total energy import (Gesamtenergie Bezug)
  static const String totalEnergyImport = 'fieldTotalEnergyImport';

  /// Total energy export (Gesamtenergie Einspeisung)
  static const String totalEnergyExport = 'fieldTotalEnergyExport';

  /// Total energy (Gesamtenergie)
  static const String totalEnergy = 'fieldTotalEnergy';

  /// Energy per minute import (Energie pro Minute Bezug)
  static const String energyPerMinuteImport = 'fieldEnergyPerMinuteImport';

  /// Energy per minute export (Energie pro Minute Einspeisung)
  static const String energyPerMinuteExport = 'fieldEnergyPerMinuteExport';

  /// Output limit (Ausgangsleistung Limit)
  static const String outputLimit = 'fieldOutputLimit';

  /// Input limit (Eingangsleistung Limit)
  static const String inputLimit = 'fieldInputLimit';

  /// Solar power (Leistung Solar)
  static const String solarPower = 'fieldSolarPower';

  /// Consumption (Verbrauch)
  static const String consumption = 'fieldConsumption';

  /// Grid import (Bezug Netz)
  static const String gridImport = 'fieldGridImport';

  /// Battery charge/discharge power (Batterie Lade/Entladeleistung)
  static const String batteryChargeDischargePower = 'fieldBatteryChargeDischargePower';

  /// Solar input power (Solar Eingangsleistung)
  static const String solarInputPower = 'fieldSolarInputPower';

  /// Home output power (Ausgang Haus)
  static const String homeOutputPower = 'fieldHomeOutputPower';

  /// AC mode (AC Modus)
  static const String acMode = 'fieldAcMode';

  /// Pack count (Pack Anzahl)
  static const String packCount = 'fieldPackCount';

  // =============================================================================
  // Voltage & Current Fields (15 keys)
  // =============================================================================

  /// Grid voltage (Netzspannung)
  static const String gridVoltage = 'fieldGridVoltage';

  /// Grid current (Netzstrom)
  static const String gridCurrent = 'fieldGridCurrent';

  /// Grid frequency (Netzfrequenz)
  static const String gridFrequency = 'fieldGridFrequency';

  /// Voltage phase 1 (Spannung Phase 1)
  static const String voltagePhase1 = 'fieldVoltagePhase1';

  /// Voltage phase 2 (Spannung Phase 2)
  static const String voltagePhase2 = 'fieldVoltagePhase2';

  /// Voltage phase 3 (Spannung Phase 3)
  static const String voltagePhase3 = 'fieldVoltagePhase3';

  /// Current phase 1 (Strom Phase 1)
  static const String currentPhase1 = 'fieldCurrentPhase1';

  /// Current phase 2 (Strom Phase 2)
  static const String currentPhase2 = 'fieldCurrentPhase2';

  /// Current phase 3 (Strom Phase 3)
  static const String currentPhase3 = 'fieldCurrentPhase3';

  /// Voltage instance (Spannung {instanceNum}) - parameterized
  static const String voltageInstance = 'fieldVoltageInstance';

  /// Current instance (Strom {instanceNum}) - parameterized
  static const String currentInstance = 'fieldCurrentInstance';

  /// DC voltage (DC Spannung)
  static const String dcVoltage = 'fieldDcVoltage';

  /// DC current (DC Strom)
  static const String dcCurrent = 'fieldDcCurrent';

  /// AC voltage (AC Spannung)
  static const String acVoltage = 'fieldAcVoltage';

  /// AC current (AC Strom)
  static const String acCurrent = 'fieldAcCurrent';

  // =============================================================================
  // Battery Fields (17 keys)
  // =============================================================================

  /// Battery level (Batterie Level)
  static const String batteryLevel = 'fieldBatteryLevel';

  /// Battery power (Batterie Leistung)
  static const String batteryPower = 'fieldBatteryPower';

  /// Battery state of charge (Batterie SOC)
  static const String batterySoc = 'fieldBatterySoc';

  /// Battery state (Batterie Status)
  static const String batteryState = 'fieldBatteryState';

  /// Charge max limit (Maximale Ladeleistung)
  static const String chargeMaxLimit = 'fieldChargeMaxLimit';

  /// Discharge max limit (Maximale Entladeleistung)
  static const String dischargeMaxLimit = 'fieldDischargeMaxLimit';

  /// Pack state (Pack Status)
  static const String packState = 'fieldPackState';

  /// Cell voltage min (Zellspannung Min)
  static const String cellVoltageMin = 'fieldCellVoltageMin';

  /// Cell voltage max (Zellspannung Max)
  static const String cellVoltageMax = 'fieldCellVoltageMax';

  /// Cell temperature max (Zelltemperatur Max)
  static const String cellTemperatureMax = 'fieldCellTemperatureMax';

  /// Battery pack empty message (Keine Batteriepack-Daten verfügbar)
  static const String batteryPackEmpty = 'fieldBatteryPackEmpty';

  /// Battery pack number (Batterie #{num}) - parameterized
  static const String batteryPackNumber = 'fieldBatteryPackNumber';

  /// Battery state idle (Idle)
  static const String batteryStateIdle = 'fieldBatteryStateIdle';

  /// Battery state charging (Lädt)
  static const String batteryStateCharging = 'fieldBatteryStateCharging';

  /// Battery state discharging (Entlädt)
  static const String batteryStateDischarging = 'fieldBatteryStateDischarging';

  /// Battery state unknown (Unbekannt)
  static const String batteryStateUnknown = 'fieldBatteryStateUnknown';

  /// Battery type (Typ)
  static const String batteryType = 'fieldBatteryType';

  // =============================================================================
  // System & Device Fields (15 keys)
  // =============================================================================

  /// Temperature (Temperatur)
  static const String temperature = 'fieldTemperature';

  /// Uptime (Betriebszeit)
  static const String uptime = 'fieldUptime';

  /// Limit status (Limit-Status)
  static const String limitStatus = 'fieldLimitStatus';

  /// Power limit (Leistungslimit)
  static const String powerLimit = 'fieldPowerLimit';

  /// Model (Modell)
  static const String model = 'fieldModel';

  /// Rated power (Nennleistung)
  static const String ratedPower = 'fieldRatedPower';

  /// Firmware version (Firmware Version)
  static const String firmwareVersion = 'fieldFirmwareVersion';

  /// Serial number (Seriennummer)
  static const String serialNumber = 'fieldSerialNumber';

  /// Article number (Artikelnummer)
  static const String articleNumber = 'fieldArticleNumber';

  /// Manufacturer (Hersteller)
  static const String manufacturer = 'fieldManufacturer';

  /// Average temperature (Durchschnittstemperatur)
  static const String averageTemperature = 'fieldAverageTemperature';

  /// Max temperature (Max. Temperatur)
  static const String maxTemperature = 'fieldMaxTemperature';

  /// Min temperature (Min. Temperatur)
  static const String minTemperature = 'fieldMinTemperature';

  /// WiFi signal (WiFi Signal)
  static const String wifiSignal = 'fieldWifiSignal';

  /// WiFi state (WiFi Status)
  static const String wifiState = 'fieldWifiState';

  // =============================================================================
  // Dynamic/Parameterized Fields (10 keys)
  // =============================================================================

  /// Switch instance (Switch {instanceNum}) - parameterized
  static const String switchInstance = 'fieldSwitchInstance';

  /// Power instance (Leistung {instanceNum}) - parameterized
  static const String powerInstance = 'fieldPowerInstance';

  /// Energy instance (Energie {instanceNum}) - parameterized
  static const String energyInstance = 'fieldEnergyInstance';

  /// Frequency instance (Frequenz {instanceNum}) - parameterized
  static const String frequencyInstance = 'fieldFrequencyInstance';

  /// Power factor instance (Leistungsfaktor {instanceNum}) - parameterized
  static const String powerFactorInstance = 'fieldPowerFactorInstance';

  /// Active power instance (Wirkleistung {instanceNum}) - parameterized
  static const String activePowerInstance = 'fieldActivePowerInstance';

  /// Reactive power instance (Blindleistung {instanceNum}) - parameterized
  static const String reactivePowerInstance = 'fieldReactivePowerInstance';

  /// Apparent power instance (Scheinleistung {instanceNum}) - parameterized
  static const String apparentPowerInstance = 'fieldApparentPowerInstance';

  /// Temperature instance (Temperatur {instanceNum}) - parameterized
  static const String temperatureInstance = 'fieldTemperatureInstance';

  /// Status instance (Status {instanceNum}) - parameterized
  static const String statusInstance = 'fieldStatusInstance';

  /// Yield instance (Ertrag {instanceNum}) - parameterized
  static const String yieldInstance = 'fieldYieldInstance';

  // =============================================================================
  // Totals & Combined Fields (8 keys)
  // =============================================================================

  /// Total power (Gesamtleistung)
  static const String totalPower = 'fieldTotalPower';

  /// Total current (Gesamtstrom)
  static const String totalCurrent = 'fieldTotalCurrent';

  /// Total voltage (Gesamtspannung)
  static const String totalVoltage = 'fieldTotalVoltage';

  /// Active power total (Wirkleistung Gesamt)
  static const String activePowerTotal = 'fieldActivePowerTotal';

  /// Reactive power total (Blindleistung Gesamt)
  static const String reactivePowerTotal = 'fieldReactivePowerTotal';

  /// Apparent power total (Scheinleistung Gesamt)
  static const String apparentPowerTotal = 'fieldApparentPowerTotal';

  /// Energy total (Energie Gesamt)
  static const String energyTotal = 'fieldEnergyTotal';

  /// Combined power (Kombinierte Leistung)
  static const String combinedPower = 'fieldCombinedPower';

  // =============================================================================
  // Phase Fields (15 keys)
  // =============================================================================

  /// Power phase 1 (Leistung Phase 1)
  static const String powerPhase1 = 'fieldPowerPhase1';

  /// Power phase 2 (Leistung Phase 2)
  static const String powerPhase2 = 'fieldPowerPhase2';

  /// Power phase 3 (Leistung Phase 3)
  static const String powerPhase3 = 'fieldPowerPhase3';

  /// Active power phase 1 (Wirkleistung Phase 1)
  static const String activePowerPhase1 = 'fieldActivePowerPhase1';

  /// Active power phase 2 (Wirkleistung Phase 2)
  static const String activePowerPhase2 = 'fieldActivePowerPhase2';

  /// Active power phase 3 (Wirkleistung Phase 3)
  static const String activePowerPhase3 = 'fieldActivePowerPhase3';

  /// Reactive power phase 1 (Blindleistung Phase 1)
  static const String reactivePowerPhase1 = 'fieldReactivePowerPhase1';

  /// Reactive power phase 2 (Blindleistung Phase 2)
  static const String reactivePowerPhase2 = 'fieldReactivePowerPhase2';

  /// Reactive power phase 3 (Blindleistung Phase 3)
  static const String reactivePowerPhase3 = 'fieldReactivePowerPhase3';

  /// Apparent power phase 1 (Scheinleistung Phase 1)
  static const String apparentPowerPhase1 = 'fieldApparentPowerPhase1';

  /// Apparent power phase 2 (Scheinleistung Phase 2)
  static const String apparentPowerPhase2 = 'fieldApparentPowerPhase2';

  /// Apparent power phase 3 (Scheinleistung Phase 3)
  static const String apparentPowerPhase3 = 'fieldApparentPowerPhase3';

  /// Frequency phase 1 (Frequenz Phase 1)
  static const String frequencyPhase1 = 'fieldFrequencyPhase1';

  /// Frequency phase 2 (Frequenz Phase 2)
  static const String frequencyPhase2 = 'fieldFrequencyPhase2';

  /// Frequency phase 3 (Frequenz Phase 3)
  static const String frequencyPhase3 = 'fieldFrequencyPhase3';

  // =============================================================================
  // Other Fields (14 keys)
  // =============================================================================

  /// Inverter type (Inverter Typ)
  static const String inverterType = 'fieldInverterType';

  /// Access model (Zugriffsmodus)
  static const String accessModel = 'fieldAccessModel';

  /// DTU serial number (DTU Seriennummer)
  static const String dtuSerialNumber = 'fieldDtuSerialNumber';

  /// Network mode (Netzwerkmodus)
  static const String networkMode = 'fieldNetworkMode';

  /// Server domain (Server Domain)
  static const String serverDomain = 'fieldServerDomain';

  /// Server port (Server Port)
  static const String serverPort = 'fieldServerPort';

  /// Send interval (Sendeintervall)
  static const String sendInterval = 'fieldSendInterval';

  /// Channel (Kanal)
  static const String channel = 'fieldChannel';

  /// Meter kind (Zähler Art)
  static const String meterKind = 'fieldMeterKind';

  /// Meter interface (Zähler Schnittstelle)
  static const String meterInterface = 'fieldMeterInterface';

  /// Zero export enabled (Nulleinspeisung aktiviert)
  static const String zeroExportEnabled = 'fieldZeroExportEnabled';

  /// Zero export address (Nulleinspeisung Adresse)
  static const String zeroExportAddress = 'fieldZeroExportAddress';

  /// Lock password set (Sperrpasswort gesetzt)
  static const String lockPasswordSet = 'fieldLockPasswordSet';

  /// Lock time minutes (Sperrzeit Minuten)
  static const String lockTimeMinutes = 'fieldLockTimeMinutes';

  /// Inverter (Wechselrichter)
  static const String inverter = 'fieldInverter';

  /// Inverter toggle description (Wechselrichter ein- oder ausschalten)
  static const String inverterToggleDescription = 'fieldInverterToggleDescription';

  /// Number of inverters (Anzahl Wechselrichter)
  static const String numberOfInverters = 'fieldNumberOfInverters';

  /// Current PV power (Aktuelle Leistung PV)
  static const String currentPvPower = 'fieldCurrentPvPower';

  /// Monthly yield (Monatsertrag)
  static const String monthlyYield = 'fieldMonthlyYield';

  /// Yearly yield (Jahresertrag)
  static const String yearlyYield = 'fieldYearlyYield';

  /// Voltage (Spannung) - generic voltage field
  static const String voltage = 'fieldVoltage';

  /// Current (Strom) - generic current field
  static const String current = 'fieldCurrent';

  /// Battery cycles (Zyklen)
  static const String batteryCycles = 'fieldBatteryCycles';

  /// Battery capacity gross (Kapazität (brutto))
  static const String batteryCapacityGross = 'fieldBatteryCapacityGross';

  /// Battery capacity net (Kapazität (netto))
  static const String batteryCapacityNet = 'fieldBatteryCapacityNet';

  /// Total consumption (Gesamtverbrauch)
  static const String totalConsumption = 'fieldTotalConsumption';

  /// Consumption from PV (Verbrauch aus PV)
  static const String consumptionFromPv = 'fieldConsumptionFromPv';

  /// Consumption from grid (Verbrauch aus Netz)
  static const String consumptionFromGrid = 'fieldConsumptionFromGrid';

  /// Consumption from battery (Verbrauch aus Batterie)
  static const String consumptionFromBattery = 'fieldConsumptionFromBattery';

  /// Frequency (Frequenz) - generic frequency field
  static const String frequency = 'fieldFrequency';

  /// Max inverter power (Max. Wechselrichterleistung)
  static const String maxInverterPower = 'fieldMaxInverterPower';

  /// Inverter generation power (Wechselrichter-Erzeugungsleistung)
  static const String inverterGenerationPower = 'fieldInverterGenerationPower';

  /// Isolation resistance (Isolationswiderstand)
  static const String isolationResistance = 'fieldIsolationResistance';

  /// Chip model (Chip Modell)
  static const String chipModel = 'fieldChipModel';

  /// Heap memory (Heap Speicher)
  static const String heap = 'fieldHeap';

  /// Sketch memory (Sketch Speicher)
  static const String sketch = 'fieldSketch';

  /// LittleFS filesystem (LittleFS Dateisystem)
  static const String littleFs = 'fieldLittleFs';

  /// SOC set target (SOC Ziel)
  static const String socSet = 'fieldSocSet';

  /// Minimum SOC (Min SOC)
  static const String minSoc = 'fieldMinSoc';

  /// Grid reverse mode (Netz Rückspeisung)
  static const String gridReverse = 'fieldGridReverse';

  /// Lamp switch (Lampe Schalter)
  static const String lampSwitch = 'fieldLampSwitch';

  /// Grid off mode (Netz Aus Modus)
  static const String gridOffMode = 'fieldGridOffMode';

  /// Fan mode (Lüfter Modus)
  static const String fanMode = 'fieldFanMode';

  /// Fan speed (Lüfter Geschwindigkeit)
  static const String fanSpeed = 'fieldFanSpeed';

  /// Smart mode (Smart Modus)
  static const String smartMode = 'fieldSmartMode';

  /// Timestamp (Zeitstempel)
  static const String timestamp = 'fieldTimestamp';

  /// Timezone (Zeitzone)
  static const String timezone = 'fieldTimezone';

  /// Battery packs section (Batteriepacks)
  static const String batteryPacks = 'fieldBatteryPacks';

  /// Solar input (Solar Eingang)
  static const String solarInput = 'fieldSolarInput';

  /// Output power (Ausgabeleistung)
  static const String outputPower = 'fieldOutputPower';

  /// Input voltage (Eingangsspannung)
  static const String inputVoltage = 'fieldInputVoltage';

  /// DC string power (DC-String-Leistung)
  static const String dcStringPower = 'fieldDcStringPower';

  /// DC string voltage (DC-String-Spannung)
  static const String dcStringVoltage = 'fieldDcStringVoltage';

  /// DC input power (DC-Eingangsleistung)
  static const String dcInputPower = 'fieldDcInputPower';

  /// AC output power (AC-Ausgangsleistung)
  static const String acOutputPower = 'fieldAcOutputPower';

  /// All inverters (Alle Wechselrichter)
  static const String allInverters = 'fieldAllInverters';

  /// Lamp setting (Lampe)
  static const String lamp = 'fieldLamp';

  /// Emergency power supply (Notstromversorgung)
  static const String emergencyPowerSupply = 'fieldEmergencyPowerSupply';

  /// Device lighting description (Gerätebeleuchtung ein- oder ausschalten)
  static const String deviceLightingDescription = 'fieldDeviceLightingDescription';

  /// Grid power mode description (Netzstrom-Modus für das Gerät)
  static const String gridPowerModeDescription = 'fieldGridPowerModeDescription';

  // =============================================================================
  // OpenDTU-specific fields (9 keys)
  // =============================================================================

  /// No inverter data available (Keine Wechselrichter-Daten verfügbar)
  static const String noInverterData = 'fieldNoInverterData';

  /// Producing status (Produziert)
  static const String statusProducing = 'fieldStatusProducing';

  /// Reachable status (Erreichbar)
  static const String statusReachable = 'fieldStatusReachable';

  /// Not reachable status (Nicht erreichbar)
  static const String statusNotReachable = 'fieldStatusNotReachable';

  /// AC frequency (AC Frequenz)
  static const String acFrequency = 'fieldAcFrequency';

  /// Power label generic (Leistung)
  static const String power = 'fieldPower';

  /// Inverter fallback name (Wechselrichter {num})
  static const String inverterFallback = 'fieldInverterFallback';

  /// String fallback name (String {num})
  static const String stringFallback = 'fieldStringFallback';

  // =============================================================================
  // OpenDTU Error & Dialog Messages (13 keys)
  // =============================================================================

  /// Error loading auth config
  static const String errorLoadingAuthConfig = 'errorLoadingAuthConfig';

  /// Error loading WiFi config
  static const String errorLoadingWifiConfig = 'errorLoadingWifiConfig';

  /// Firmware not supported title
  static const String firmwareNotSupported = 'firmwareNotSupported';

  /// Firmware not supported message
  static const String firmwareNotSupportedMessage = 'firmwareNotSupportedMessage';

  /// Download firmware button
  static const String downloadFirmware = 'downloadFirmware';

  /// No inverters found warning
  static const String noInvertersFound = 'noInvertersFound';

  /// Toggle inverters dialog title
  static const String toggleInverters = 'toggleInverters';

  /// Toggle inverters prompt text
  static const String toggleInvertersPrompt = 'toggleInvertersPrompt';

  /// Turn off button
  static const String turnOff = 'turnOff';

  /// Turn on button
  static const String turnOn = 'turnOn';

  /// Turning on inverters loading message
  static const String turningOnInverters = 'turningOnInverters';

  /// Turning off inverters loading message
  static const String turningOffInverters = 'turningOffInverters';

  /// Inverters turned on success message
  static const String invertersTurnedOn = 'invertersTurnedOn';

  /// Inverters turned off success message
  static const String invertersTurnedOff = 'invertersTurnedOff';

  /// Restart device confirmation dialog
  static const String restartDeviceConfirm = 'restartDeviceConfirm';

  /// Select inverter to restart dialog
  static const String selectInverterToRestart = 'selectInverterToRestart';

  /// Select inverter to set power limit dialog
  static const String selectInverterToSetLimit = 'selectInverterToSetLimit';

  /// Restart inverter confirmation dialog
  static const String restartInverterConfirm = 'restartInverterConfirm';

  /// Restarting inverter loading message
  static const String restartingInverter = 'restartingInverter';

  /// Inverter restarted success message
  static const String inverterRestarted = 'inverterRestarted';
}

/// Translation keys for category display names
///
/// Usage:
/// ```dart
/// const DeviceCategoryConfig(
///   category: 'pv1',
///   displayName: 'PV1',  // Fallback
///   displayNameKey: CategoryTranslationKeys.pv1,
///   layout: CategoryLayout.standard,
/// )
/// ```
class CategoryTranslationKeys {
  // Private constructor to prevent instantiation
  CategoryTranslationKeys._();

  // =============================================================================
  // PV String Categories (4 keys)
  // =============================================================================

  /// PV1 string category
  static const String pv1 = 'categoryPv1';

  /// PV2 string category
  static const String pv2 = 'categoryPv2';

  /// PV3 string category
  static const String pv3 = 'categoryPv3';

  /// PV4 string category
  static const String pv4 = 'categoryPv4';

  // =============================================================================
  // AC/Grid Categories (6 keys)
  // =============================================================================

  /// AC (Grid) category (AC Netz)
  static const String acGrid = 'categoryAcGrid';

  /// AC total category (AC Gesamt)
  static const String acTotal = 'categoryAcTotal';

  /// Phase 1 category
  static const String phase1 = 'categoryPhase1';

  /// Phase 2 category
  static const String phase2 = 'categoryPhase2';

  /// Phase 3 category
  static const String phase3 = 'categoryPhase3';

  /// Totals category (Summen)
  static const String totals = 'categoryTotals';

  // =============================================================================
  // AC Phases Detailed Categories (3 keys)
  // =============================================================================

  /// AC phase 1 category (AC Phase 1)
  static const String acPhase1 = 'categoryAcPhase1';

  /// AC phase 2 category (AC Phase 2)
  static const String acPhase2 = 'categoryAcPhase2';

  /// AC phase 3 category (AC Phase 3)
  static const String acPhase3 = 'categoryAcPhase3';

  // =============================================================================
  // DC String Categories (3 keys)
  // =============================================================================

  /// DC string 1 category (DC String 1)
  static const String dcString1 = 'categoryDcString1';

  /// DC string 2 category (DC String 2)
  static const String dcString2 = 'categoryDcString2';

  /// DC string 3 category (DC String 3)
  static const String dcString3 = 'categoryDcString3';

  // =============================================================================
  // System Categories (4 keys)
  // =============================================================================

  /// System category
  static const String system = 'categorySystem';

  /// Device info category (Geräteinformationen)
  static const String deviceInfo = 'categoryDeviceInfo';

  /// Battery category (Batterie)
  static const String battery = 'categoryBattery';

  /// Inverter category (Wechselrichter)
  static const String inverter = 'categoryInverter';

  // =============================================================================
  // Storage Categories (2 keys)
  // =============================================================================

  /// Memory category (Speicher)
  static const String memory = 'categoryMemory';

  /// Storage category (Lagerung)
  static const String storage = 'categoryStorage';

  // =============================================================================
  // Power/Energy Categories (2 keys)
  // =============================================================================

  /// Power meter category (Stromzähler)
  static const String powerMeter = 'categoryPowerMeter';

  /// Home consumption category (Hausverbrauch)
  static const String homeConsumption = 'categoryHomeConsumption';

  // =============================================================================
  // Dynamic/Parameterized Categories (5 keys)
  // =============================================================================

  /// Measurement instance (Messung {instanceNum}) - parameterized
  static const String measurementInstance = 'categoryMeasurementInstance';

  /// Switch instance (Switch {instanceNum}) - parameterized
  static const String switchInstance = 'categorySwitchInstance';

  /// PM measurement instance (PM Messung {instanceNum}) - parameterized
  static const String pmMeasurementInstance = 'categoryPmMeasurementInstance';

  /// Inverter instance (Wechselrichter {instanceNum}) - parameterized
  static const String inverterInstance = 'categoryInverterInstance';

  /// String instance (String {instanceNum}) - parameterized
  static const String stringInstance = 'categoryStringInstance';

  // =============================================================================
  // Combined Categories (3 keys)
  // =============================================================================

  /// EM1 combined category (Kombiniert)
  static const String em1Combined = 'categoryEm1Combined';

  /// PM1 combined category (PM Kombiniert)
  static const String pm1Combined = 'categoryPm1Combined';

  /// Switch combined category (Switch Kombiniert)
  static const String switchCombined = 'categorySwitchCombined';

  // =============================================================================
  // Power Meter Phase Categories (3 keys)
  // =============================================================================

  /// Power meter phase 1 (Stromzähler Phase 1)
  static const String powerMeterPhase1 = 'categoryPowerMeterPhase1';

  /// Power meter phase 2 (Stromzähler Phase 2)
  static const String powerMeterPhase2 = 'categoryPowerMeterPhase2';

  /// Power meter phase 3 (Stromzähler Phase 3)
  static const String powerMeterPhase3 = 'categoryPowerMeterPhase3';
}

/// Translation keys for menu item names
class MenuTranslationKeys {
  MenuTranslationKeys._();

  // Configuration menus
  static const String generalSettings = 'menuGeneralSettings';
  static const String wifiConfiguration = 'menuWifiConfiguration';
  static const String onlineMonitoringConfiguration = 'menuOnlineMonitoringConfiguration';
  static const String restartDevice = 'menuRestartDevice';
  static const String accessPointConfiguration = 'menuAccessPointConfiguration';
  static const String powerLimit = 'menuPowerLimit';
  static const String authentication = 'menuAuthentication';
  static const String deviceInfo = 'menuDeviceInfo';
  static const String automation = 'menuAutomation';
  static const String powerSettings = 'menuPowerSettings';
  static const String batteryLimits = 'menuBatteryLimits';
  static const String advancedPowerSettings = 'menuAdvancedPowerSettings';
  static const String portConfiguration = 'menuPortConfiguration';
  static const String percentagePowerLimit = 'menuPercentagePowerLimit';
  static const String inverterToggle = 'menuInverterToggle';
  static const String restartInverter = 'menuRestartInverter';
  static const String mqttConfiguration = 'menuMqttConfiguration';
}

/// Translation keys for menu item subtitles
class MenuSubtitleKeys {
  MenuSubtitleKeys._();

  static const String generalSettingsSubtitle = 'menuSubtitleGeneralSettings';
  static const String wifiConfigurationSubtitle = 'menuSubtitleWifiConfiguration';
  static const String onlineMonitoringSubtitle = 'menuSubtitleOnlineMonitoring';
  static const String restartDeviceSubtitle = 'menuSubtitleRestartDevice';
  static const String accessPointSubtitle = 'menuSubtitleAccessPoint';
  static const String powerLimitSubtitle = 'menuSubtitlePowerLimit';
  static const String authenticationSubtitle = 'menuSubtitleAuthentication';
  static const String deviceInfoSubtitle = 'menuSubtitleDeviceInfo';
  static const String powerSettingsSubtitle = 'menuSubtitlePowerSettings';
  static const String batteryLimitsSubtitle = 'menuSubtitleBatteryLimits';
  static const String advancedPowerSettingsSubtitle = 'menuSubtitleAdvancedPowerSettings';
  static const String portConfigurationSubtitle = 'menuSubtitlePortConfiguration';
  static const String automationSubtitle = 'menuSubtitleAutomation';
  static const String percentagePowerLimitSubtitle = 'menuSubtitlePercentagePowerLimit';
  static const String inverterToggleSubtitle = 'menuSubtitleInverterToggle';
  static const String restartInverterSubtitle = 'menuSubtitleRestartInverter';
  static const String mqttConfigurationSubtitle = 'menuSubtitleMqttConfiguration';
}
