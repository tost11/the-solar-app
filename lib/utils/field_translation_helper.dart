import 'package:the_solar_app/generated/l10n/app_localizations.dart';

/// Helper function to get field translation by key
///
/// Maps translation key strings to their corresponding l10n getter methods.
/// Returns null if the key is not found (caller should fall back to hardcoded name).
String? getFieldTranslation(AppLocalizations l10n, String key) {
  switch (key) {
    // Power & Energy Fields
    case 'fieldDailyYield':
      return l10n.fieldDailyYield;
    case 'fieldTotalYield':
      return l10n.fieldTotalYield;
    case 'fieldCurrentPower':
      return l10n.fieldCurrentPower;
    case 'fieldAcPower':
      return l10n.fieldAcPower;
    case 'fieldDcPower':
      return l10n.fieldDcPower;
    case 'fieldActivePower':
      return l10n.fieldActivePower;
    case 'fieldReactivePower':
      return l10n.fieldReactivePower;
    case 'fieldApparentPower':
      return l10n.fieldApparentPower;
    case 'fieldPowerFactor':
      return l10n.fieldPowerFactor;
    case 'fieldDcTotalPower':
      return l10n.fieldDcTotalPower;
    case 'fieldPvVoltage':
      return l10n.fieldPvVoltage('{num}');
    case 'fieldPvCurrent':
      return l10n.fieldPvCurrent('{num}');
    case 'fieldPvPower':
      return l10n.fieldPvPower('{num}');
    case 'fieldPvTotalYield':
      return l10n.fieldPvTotalYield('{num}');
    case 'fieldPvDailyYield':
      return l10n.fieldPvDailyYield('{num}');
    case 'fieldTotalEnergyImport':
      return l10n.fieldTotalEnergyImport;
    case 'fieldTotalEnergyExport':
      return l10n.fieldTotalEnergyExport;
    case 'fieldTotalEnergy':
      return l10n.fieldTotalEnergy;
    case 'fieldOutputLimit':
      return l10n.fieldOutputLimit;
    case 'fieldInputLimit':
      return l10n.fieldInputLimit;

    // Voltage & Current Fields
    case 'fieldGridVoltage':
      return l10n.fieldGridVoltage;
    case 'fieldGridCurrent':
      return l10n.fieldGridCurrent;
    case 'fieldGridFrequency':
      return l10n.fieldGridFrequency;
    case 'fieldVoltagePhase1':
      return l10n.fieldVoltagePhase1;
    case 'fieldVoltagePhase2':
      return l10n.fieldVoltagePhase2;
    case 'fieldVoltagePhase3':
      return l10n.fieldVoltagePhase3;
    case 'fieldCurrentPhase1':
      return l10n.fieldCurrentPhase1;
    case 'fieldCurrentPhase2':
      return l10n.fieldCurrentPhase2;
    case 'fieldCurrentPhase3':
      return l10n.fieldCurrentPhase3;
    case 'fieldVoltageInstance':
      return l10n.fieldVoltageInstance('{instanceNum}');
    case 'fieldCurrentInstance':
      return l10n.fieldCurrentInstance('{instanceNum}');
    case 'fieldDcVoltage':
      return l10n.fieldDcVoltage;
    case 'fieldDcCurrent':
      return l10n.fieldDcCurrent;
    case 'fieldAcVoltage':
      return l10n.fieldAcVoltage;
    case 'fieldAcCurrent':
      return l10n.fieldAcCurrent;

    // Battery Fields
    case 'fieldBatteryLevel':
      return l10n.fieldBatteryLevel;
    case 'fieldBatteryPower':
      return l10n.fieldBatteryPower;
    case 'fieldBatterySoc':
      return l10n.fieldBatterySoc;
    case 'fieldBatteryState':
      return l10n.fieldBatteryState;
    case 'fieldChargeMaxLimit':
      return l10n.fieldChargeMaxLimit;
    case 'fieldDischargeMaxLimit':
      return l10n.fieldDischargeMaxLimit;
    case 'fieldPackState':
      return l10n.fieldPackState;
    case 'fieldCellVoltageMin':
      return l10n.fieldCellVoltageMin;
    case 'fieldCellVoltageMax':
      return l10n.fieldCellVoltageMax;
    case 'fieldCellTemperatureMax':
      return l10n.fieldCellTemperatureMax;
    case 'fieldBatteryPackEmpty':
      return l10n.fieldBatteryPackEmpty;
    case 'fieldBatteryPackNumber':
      return l10n.fieldBatteryPackNumber('{num}');
    case 'fieldBatteryStateIdle':
      return l10n.fieldBatteryStateIdle;
    case 'fieldBatteryStateCharging':
      return l10n.fieldBatteryStateCharging;
    case 'fieldBatteryStateDischarging':
      return l10n.fieldBatteryStateDischarging;
    case 'fieldBatteryStateUnknown':
      return l10n.fieldBatteryStateUnknown;
    case 'fieldBatteryType':
      return l10n.fieldBatteryType;

    // System & Device Fields
    case 'fieldTemperature':
      return l10n.fieldTemperature;
    case 'fieldUptime':
      return l10n.fieldUptime;
    case 'fieldLimitStatus':
      return l10n.fieldLimitStatus;
    case 'fieldPowerLimit':
      return l10n.fieldPowerLimit;
    case 'fieldModel':
      return l10n.fieldModel;
    case 'fieldRatedPower':
      return l10n.fieldRatedPower;
    case 'fieldFirmwareVersion':
      return l10n.fieldFirmwareVersion;
    case 'fieldSerialNumber':
      return l10n.fieldSerialNumber;
    case 'fieldArticleNumber':
      return l10n.fieldArticleNumber;
    case 'fieldManufacturer':
      return l10n.fieldManufacturer;
    case 'fieldAverageTemperature':
      return l10n.fieldAverageTemperature;
    case 'fieldMaxTemperature':
      return l10n.fieldMaxTemperature;
    case 'fieldMinTemperature':
      return l10n.fieldMinTemperature;
    case 'fieldWifiSignal':
      return l10n.fieldWifiSignal;
    case 'fieldWifiState':
      return l10n.fieldWifiState;

    // Dynamic/Parameterized Fields
    case 'fieldSwitchInstance':
      return l10n.fieldSwitchInstance('{instanceNum}');
    case 'fieldPowerInstance':
      return l10n.fieldPowerInstance('{instanceNum}');
    case 'fieldEnergyInstance':
      return l10n.fieldEnergyInstance('{instanceNum}');
    case 'fieldFrequencyInstance':
      return l10n.fieldFrequencyInstance('{instanceNum}');
    case 'fieldPowerFactorInstance':
      return l10n.fieldPowerFactorInstance('{instanceNum}');
    case 'fieldActivePowerInstance':
      return l10n.fieldActivePowerInstance('{instanceNum}');
    case 'fieldReactivePowerInstance':
      return l10n.fieldReactivePowerInstance('{instanceNum}');
    case 'fieldApparentPowerInstance':
      return l10n.fieldApparentPowerInstance('{instanceNum}');
    case 'fieldTemperatureInstance':
      return l10n.fieldTemperatureInstance('{instanceNum}');
    case 'fieldYieldInstance':
      return l10n.fieldYieldInstance('{instanceNum}');

    // Totals & Combined Fields
    case 'fieldTotalPower':
      return l10n.fieldTotalPower;
    case 'fieldTotalCurrent':
      return l10n.fieldTotalCurrent;
    case 'fieldTotalVoltage':
      return l10n.fieldTotalVoltage;
    case 'fieldActivePowerTotal':
      return l10n.fieldActivePowerTotal;
    case 'fieldReactivePowerTotal':
      return l10n.fieldReactivePowerTotal;
    case 'fieldApparentPowerTotal':
      return l10n.fieldApparentPowerTotal;
    case 'fieldEnergyTotal':
      return l10n.fieldEnergyTotal;
    case 'fieldCombinedPower':
      return l10n.fieldCombinedPower;

    // Phase Fields
    case 'fieldPowerPhase1':
      return l10n.fieldPowerPhase1;
    case 'fieldPowerPhase2':
      return l10n.fieldPowerPhase2;
    case 'fieldPowerPhase3':
      return l10n.fieldPowerPhase3;
    case 'fieldActivePowerPhase1':
      return l10n.fieldActivePowerPhase1;
    case 'fieldActivePowerPhase2':
      return l10n.fieldActivePowerPhase2;
    case 'fieldActivePowerPhase3':
      return l10n.fieldActivePowerPhase3;
    case 'fieldReactivePowerPhase1':
      return l10n.fieldReactivePowerPhase1;
    case 'fieldReactivePowerPhase2':
      return l10n.fieldReactivePowerPhase2;
    case 'fieldReactivePowerPhase3':
      return l10n.fieldReactivePowerPhase3;
    case 'fieldApparentPowerPhase1':
      return l10n.fieldApparentPowerPhase1;
    case 'fieldApparentPowerPhase2':
      return l10n.fieldApparentPowerPhase2;
    case 'fieldApparentPowerPhase3':
      return l10n.fieldApparentPowerPhase3;
    case 'fieldFrequencyPhase1':
      return l10n.fieldFrequencyPhase1;
    case 'fieldFrequencyPhase2':
      return l10n.fieldFrequencyPhase2;
    case 'fieldFrequencyPhase3':
      return l10n.fieldFrequencyPhase3;

    // Other Fields
    case 'fieldInverterType':
      return l10n.fieldInverterType;
    case 'fieldAccessModel':
      return l10n.fieldAccessModel;
    case 'fieldDtuSerialNumber':
      return l10n.fieldDtuSerialNumber;
    case 'fieldNetworkMode':
      return l10n.fieldNetworkMode;
    case 'fieldServerDomain':
      return l10n.fieldServerDomain;
    case 'fieldServerPort':
      return l10n.fieldServerPort;
    case 'fieldSendInterval':
      return l10n.fieldSendInterval;
    case 'fieldChannel':
      return l10n.fieldChannel;
    case 'fieldMeterKind':
      return l10n.fieldMeterKind;
    case 'fieldMeterInterface':
      return l10n.fieldMeterInterface;
    case 'fieldZeroExportEnabled':
      return l10n.fieldZeroExportEnabled;
    case 'fieldZeroExportAddress':
      return l10n.fieldZeroExportAddress;
    case 'fieldLockPasswordSet':
      return l10n.fieldLockPasswordSet;
    case 'fieldLockTimeMinutes':
      return l10n.fieldLockTimeMinutes;
    case 'fieldChipModel':
      return l10n.fieldChipModel;
    case 'fieldHeap':
      return l10n.fieldHeap;
    case 'fieldSketch':
      return l10n.fieldSketch;
    case 'fieldLittleFs':
      return l10n.fieldLittleFs;
    case 'fieldSocSet':
      return l10n.fieldSocSet;
    case 'fieldMinSoc':
      return l10n.fieldMinSoc;
    case 'fieldGridReverse':
      return l10n.fieldGridReverse;
    case 'fieldLampSwitch':
      return l10n.fieldLampSwitch;
    case 'fieldGridOffMode':
      return l10n.fieldGridOffMode;
    case 'fieldFanMode':
      return l10n.fieldFanMode;
    case 'fieldFanSpeed':
      return l10n.fieldFanSpeed;
    case 'fieldSmartMode':
      return l10n.fieldSmartMode;
    case 'fieldTimestamp':
      return l10n.fieldTimestamp;
    case 'fieldTimezone':
      return l10n.fieldTimezone;
    case 'fieldBatteryPacks':
      return l10n.fieldBatteryPacks;
    case 'fieldSolarInput':
      return l10n.fieldSolarInput;
    case 'fieldOutputPower':
      return l10n.fieldOutputPower;
    case 'fieldInputVoltage':
      return l10n.fieldInputVoltage;
    case 'fieldDcStringPower':
      return l10n.fieldDcStringPower('{name}');
    case 'fieldDcStringVoltage':
      return l10n.fieldDcStringVoltage('{name}');
    case 'fieldDcInputPower':
      return l10n.fieldDcInputPower('{prefix}');
    case 'fieldAcOutputPower':
      return l10n.fieldAcOutputPower('{prefix}');
    case 'fieldAllInverters':
      return l10n.fieldAllInverters;
    case 'fieldLamp':
      return l10n.fieldLamp;
    case 'fieldEmergencyPowerSupply':
      return l10n.fieldEmergencyPowerSupply;
    case 'fieldDeviceLightingDescription':
      return l10n.fieldDeviceLightingDescription;
    case 'fieldGridPowerModeDescription':
      return l10n.fieldGridPowerModeDescription;

    // OpenDTU-specific fields
    case 'fieldNoInverterData':
      return l10n.fieldNoInverterData;
    case 'fieldStatusProducing':
      return l10n.fieldStatusProducing;
    case 'fieldStatusReachable':
      return l10n.fieldStatusReachable;
    case 'fieldStatusNotReachable':
      return l10n.fieldStatusNotReachable;
    case 'fieldAcFrequency':
      return l10n.fieldAcFrequency;
    case 'fieldPower':
      return l10n.fieldPower;
    case 'fieldInverterFallback':
      return l10n.fieldInverterFallback('{num}');
    case 'fieldStringFallback':
      return l10n.fieldStringFallback('{num}');

    // OpenDTU Error & Dialog Messages
    case 'errorLoadingAuthConfig':
      return l10n.errorLoadingAuthConfig('{error}');
    case 'errorLoadingWifiConfig':
      return l10n.errorLoadingWifiConfig('{error}');
    case 'firmwareNotSupported':
      return l10n.firmwareNotSupported;
    case 'firmwareNotSupportedMessage':
      return l10n.firmwareNotSupportedMessage;
    case 'downloadFirmware':
      return l10n.downloadFirmware;
    case 'noInvertersFound':
      return l10n.noInvertersFound;
    case 'toggleInverters':
      return l10n.toggleInverters;
    case 'toggleInvertersPrompt':
      return l10n.toggleInvertersPrompt;
    case 'turnOff':
      return l10n.turnOff;
    case 'turnOn':
      return l10n.turnOn;
    case 'turningOnInverters':
      return l10n.turningOnInverters;
    case 'turningOffInverters':
      return l10n.turningOffInverters;
    case 'invertersTurnedOn':
      return l10n.invertersTurnedOn;
    case 'invertersTurnedOff':
      return l10n.invertersTurnedOff;
    case 'restartDeviceConfirm':
      return l10n.restartDeviceConfirm;
    case 'selectInverterToSetLimit':
      return l10n.selectInverterToSetLimit;

    default:
      return null;
  }
}

/// Helper function to get category translation by key
///
/// Maps translation key strings to their corresponding l10n getter methods.
/// Returns null if the key is not found (caller should fall back to hardcoded name).
String? getCategoryTranslation(AppLocalizations l10n, String key) {
  switch (key) {
    // PV String Categories
    case 'categoryPv1':
      return l10n.categoryPv1;
    case 'categoryPv2':
      return l10n.categoryPv2;
    case 'categoryPv3':
      return l10n.categoryPv3;
    case 'categoryPv4':
      return l10n.categoryPv4;

    // AC/Grid Categories
    case 'categoryAcGrid':
      return l10n.categoryAcGrid;
    case 'categoryAcTotal':
      return l10n.categoryAcTotal;
    case 'categoryPhase1':
      return l10n.categoryPhase1;
    case 'categoryPhase2':
      return l10n.categoryPhase2;
    case 'categoryPhase3':
      return l10n.categoryPhase3;
    case 'categoryTotals':
      return l10n.categoryTotals;

    // AC Phases Detailed Categories
    case 'categoryAcPhase1':
      return l10n.categoryAcPhase1;
    case 'categoryAcPhase2':
      return l10n.categoryAcPhase2;
    case 'categoryAcPhase3':
      return l10n.categoryAcPhase3;

    // DC String Categories
    case 'categoryDcString1':
      return l10n.categoryDcString1;
    case 'categoryDcString2':
      return l10n.categoryDcString2;
    case 'categoryDcString3':
      return l10n.categoryDcString3;

    // System Categories
    case 'categorySystem':
      return l10n.categorySystem;
    case 'categoryDeviceInfo':
      return l10n.categoryDeviceInfo;
    case 'categoryBattery':
      return l10n.categoryBattery;
    case 'categoryInverter':
      return l10n.categoryInverter;

    // Storage Categories
    case 'categoryMemory':
      return l10n.categoryMemory;
    case 'categoryStorage':
      return l10n.categoryStorage;

    // Power/Energy Categories
    case 'categoryPowerMeter':
      return l10n.categoryPowerMeter;
    case 'categoryHomeConsumption':
      return l10n.categoryHomeConsumption;

    // Dynamic/Parameterized Categories
    case 'categoryMeasurementInstance':
      return l10n.categoryMeasurementInstance('{instanceNum}');
    case 'categorySwitchInstance':
      return l10n.categorySwitchInstance('{instanceNum}');
    case 'categoryPmMeasurementInstance':
      return l10n.categoryPmMeasurementInstance('{instanceNum}');
    case 'categoryInverterInstance':
      return l10n.categoryInverterInstance('{instanceNum}');
    case 'categoryStringInstance':
      return l10n.categoryStringInstance('{num}');

    // Combined Categories
    case 'categoryEm1Combined':
      return l10n.categoryEm1Combined;
    case 'categoryPm1Combined':
      return l10n.categoryPm1Combined;
    case 'categorySwitchCombined':
      return l10n.categorySwitchCombined;

    // Power Meter Phase Categories
    case 'categoryPowerMeterPhase1':
      return l10n.categoryPowerMeterPhase1;
    case 'categoryPowerMeterPhase2':
      return l10n.categoryPowerMeterPhase2;
    case 'categoryPowerMeterPhase3':
      return l10n.categoryPowerMeterPhase3;

    default:
      return null;
  }
}


/// Helper function to get menu translation by key
///
/// Maps translation key strings to their corresponding l10n getter methods.
/// Returns null if the key is not found.
String? getMenuTranslation(AppLocalizations l10n, String key) {
  switch (key) {
    case "menuGeneralSettings":
      return l10n.menuGeneralSettings;
    case "menuWifiConfiguration":
      return l10n.menuWifiConfiguration;
    case "menuOnlineMonitoringConfiguration":
      return l10n.menuOnlineMonitoringConfiguration;
    case "menuRestartDevice":
      return l10n.menuRestartDevice;
    case "menuAccessPointConfiguration":
      return l10n.menuAccessPointConfiguration;
    case "menuPowerLimit":
      return l10n.menuPowerLimit;
    case "menuAuthentication":
      return l10n.menuAuthentication;
    case "menuDeviceInfo":
      return l10n.menuDeviceInfo;
    case "menuAutomation":
      return l10n.menuAutomation;
    case "menuPowerSettings":
      return l10n.menuPowerSettings;
    case "menuBatteryLimits":
      return l10n.menuBatteryLimits;
    case "menuAdvancedPowerSettings":
      return l10n.menuAdvancedPowerSettings;
    case "menuPortConfiguration":
      return l10n.menuPortConfiguration;
    case "menuPercentagePowerLimit":
      return l10n.menuPercentagePowerLimit;
    case "menuInverterToggle":
      return l10n.menuInverterToggle;
    case "menuRestartInverter":
      return l10n.menuRestartInverter;
    case "menuMqttConfiguration":
      return l10n.menuMqttConfiguration;
    case "menuSubtitleGeneralSettings":
      return l10n.menuSubtitleGeneralSettings;
    case "menuSubtitleWifiConfiguration":
      return l10n.menuSubtitleWifiConfiguration;
    case "menuSubtitleOnlineMonitoring":
      return l10n.menuSubtitleOnlineMonitoring;
    case "menuSubtitleRestartDevice":
      return l10n.menuSubtitleRestartDevice;
    case "menuSubtitleAccessPoint":
      return l10n.menuSubtitleAccessPoint;
    case "menuSubtitlePowerLimit":
      return l10n.menuSubtitlePowerLimit;
    case "menuSubtitleAuthentication":
      return l10n.menuSubtitleAuthentication;
    case "menuSubtitleDeviceInfo":
      return l10n.menuSubtitleDeviceInfo;
    case "menuSubtitlePowerSettings":
      return l10n.menuSubtitlePowerSettings;
    case "menuSubtitleBatteryLimits":
      return l10n.menuSubtitleBatteryLimits;
    case "menuSubtitleAdvancedPowerSettings":
      return l10n.menuSubtitleAdvancedPowerSettings;
    case "menuSubtitlePortConfiguration":
      return l10n.menuSubtitlePortConfiguration;
    case "menuSubtitleAutomation":
      return l10n.menuSubtitleAutomation;
    case "menuSubtitlePercentagePowerLimit":
      return l10n.menuSubtitlePercentagePowerLimit;
    case "menuSubtitleInverterToggle":
      return l10n.menuSubtitleInverterToggle;
    case "menuSubtitleRestartInverter":
      return l10n.menuSubtitleRestartInverter;
    case "menuSubtitleMqttConfiguration":
      return l10n.menuSubtitleMqttConfiguration;
    default:
      return null;
  }
}
