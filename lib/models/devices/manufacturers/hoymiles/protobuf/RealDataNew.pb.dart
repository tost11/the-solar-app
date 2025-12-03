//
//  Generated code. Do not modify.
//  source: RealDataNew.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class MeterMO extends $pb.GeneratedMessage {
  factory MeterMO({
    $core.int? deviceType,
    $fixnum.Int64? serialNumber,
    $core.int? phaseTotalPower,
    $core.int? phaseAPower,
    $core.int? phaseBPower,
    $core.int? phaseCPower,
    $core.int? powerFactorTotal,
    $core.int? energyTotalPower,
    $core.int? energyPhaseA,
    $core.int? energyPhaseB,
    $core.int? energyPhaseC,
    $core.int? energyTotalConsumed,
    $core.int? energyPhaseAConsumed,
    $core.int? energyPhaseBConsumed,
    $core.int? energyPhaseCConsumed,
    $core.int? faultCode,
    $core.int? voltagePhaseA,
    $core.int? voltagePhaseB,
    $core.int? voltagePhaseC,
    $core.int? currentPhaseA,
    $core.int? currentPhaseB,
    $core.int? currentPhaseC,
    $core.int? powerFactorPhaseA,
    $core.int? powerFactorPhaseB,
    $core.int? powerFactorPhaseC,
  }) {
    final $result = create();
    if (deviceType != null) {
      $result.deviceType = deviceType;
    }
    if (serialNumber != null) {
      $result.serialNumber = serialNumber;
    }
    if (phaseTotalPower != null) {
      $result.phaseTotalPower = phaseTotalPower;
    }
    if (phaseAPower != null) {
      $result.phaseAPower = phaseAPower;
    }
    if (phaseBPower != null) {
      $result.phaseBPower = phaseBPower;
    }
    if (phaseCPower != null) {
      $result.phaseCPower = phaseCPower;
    }
    if (powerFactorTotal != null) {
      $result.powerFactorTotal = powerFactorTotal;
    }
    if (energyTotalPower != null) {
      $result.energyTotalPower = energyTotalPower;
    }
    if (energyPhaseA != null) {
      $result.energyPhaseA = energyPhaseA;
    }
    if (energyPhaseB != null) {
      $result.energyPhaseB = energyPhaseB;
    }
    if (energyPhaseC != null) {
      $result.energyPhaseC = energyPhaseC;
    }
    if (energyTotalConsumed != null) {
      $result.energyTotalConsumed = energyTotalConsumed;
    }
    if (energyPhaseAConsumed != null) {
      $result.energyPhaseAConsumed = energyPhaseAConsumed;
    }
    if (energyPhaseBConsumed != null) {
      $result.energyPhaseBConsumed = energyPhaseBConsumed;
    }
    if (energyPhaseCConsumed != null) {
      $result.energyPhaseCConsumed = energyPhaseCConsumed;
    }
    if (faultCode != null) {
      $result.faultCode = faultCode;
    }
    if (voltagePhaseA != null) {
      $result.voltagePhaseA = voltagePhaseA;
    }
    if (voltagePhaseB != null) {
      $result.voltagePhaseB = voltagePhaseB;
    }
    if (voltagePhaseC != null) {
      $result.voltagePhaseC = voltagePhaseC;
    }
    if (currentPhaseA != null) {
      $result.currentPhaseA = currentPhaseA;
    }
    if (currentPhaseB != null) {
      $result.currentPhaseB = currentPhaseB;
    }
    if (currentPhaseC != null) {
      $result.currentPhaseC = currentPhaseC;
    }
    if (powerFactorPhaseA != null) {
      $result.powerFactorPhaseA = powerFactorPhaseA;
    }
    if (powerFactorPhaseB != null) {
      $result.powerFactorPhaseB = powerFactorPhaseB;
    }
    if (powerFactorPhaseC != null) {
      $result.powerFactorPhaseC = powerFactorPhaseC;
    }
    return $result;
  }
  MeterMO._() : super();
  factory MeterMO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MeterMO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MeterMO', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'deviceType', $pb.PbFieldType.O3)
    ..aInt64(2, _omitFieldNames ? '' : 'serialNumber')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'phaseTotalPower', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'phaseAPower', $pb.PbFieldType.O3, protoName: 'phase_A_power')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'phaseBPower', $pb.PbFieldType.O3, protoName: 'phase_B_power')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'phaseCPower', $pb.PbFieldType.O3, protoName: 'phase_C_power')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'powerFactorTotal', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'energyTotalPower', $pb.PbFieldType.O3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'energyPhaseA', $pb.PbFieldType.O3, protoName: 'energy_phase_A')
    ..a<$core.int>(10, _omitFieldNames ? '' : 'energyPhaseB', $pb.PbFieldType.O3, protoName: 'energy_phase_B')
    ..a<$core.int>(11, _omitFieldNames ? '' : 'energyPhaseC', $pb.PbFieldType.O3, protoName: 'energy_phase_C')
    ..a<$core.int>(12, _omitFieldNames ? '' : 'energyTotalConsumed', $pb.PbFieldType.O3)
    ..a<$core.int>(13, _omitFieldNames ? '' : 'energyPhaseAConsumed', $pb.PbFieldType.O3, protoName: 'energy_phase_A_consumed')
    ..a<$core.int>(14, _omitFieldNames ? '' : 'energyPhaseBConsumed', $pb.PbFieldType.O3, protoName: 'energy_phase_B_consumed')
    ..a<$core.int>(15, _omitFieldNames ? '' : 'energyPhaseCConsumed', $pb.PbFieldType.O3, protoName: 'energy_phase_C_consumed')
    ..a<$core.int>(16, _omitFieldNames ? '' : 'faultCode', $pb.PbFieldType.O3)
    ..a<$core.int>(17, _omitFieldNames ? '' : 'voltagePhaseA', $pb.PbFieldType.O3, protoName: 'voltage_phase_A')
    ..a<$core.int>(18, _omitFieldNames ? '' : 'voltagePhaseB', $pb.PbFieldType.O3, protoName: 'voltage_phase_B')
    ..a<$core.int>(19, _omitFieldNames ? '' : 'voltagePhaseC', $pb.PbFieldType.O3, protoName: 'voltage_phase_C')
    ..a<$core.int>(20, _omitFieldNames ? '' : 'currentPhaseA', $pb.PbFieldType.O3, protoName: 'current_phase_A')
    ..a<$core.int>(21, _omitFieldNames ? '' : 'currentPhaseB', $pb.PbFieldType.O3, protoName: 'current_phase_B')
    ..a<$core.int>(22, _omitFieldNames ? '' : 'currentPhaseC', $pb.PbFieldType.O3, protoName: 'current_phase_C')
    ..a<$core.int>(23, _omitFieldNames ? '' : 'powerFactorPhaseA', $pb.PbFieldType.O3, protoName: 'power_factor_phase_A')
    ..a<$core.int>(24, _omitFieldNames ? '' : 'powerFactorPhaseB', $pb.PbFieldType.O3, protoName: 'power_factor_phase_B')
    ..a<$core.int>(25, _omitFieldNames ? '' : 'powerFactorPhaseC', $pb.PbFieldType.O3, protoName: 'power_factor_phase_C')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MeterMO clone() => MeterMO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MeterMO copyWith(void Function(MeterMO) updates) => super.copyWith((message) => updates(message as MeterMO)) as MeterMO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MeterMO create() => MeterMO._();
  MeterMO createEmptyInstance() => create();
  static $pb.PbList<MeterMO> createRepeated() => $pb.PbList<MeterMO>();
  @$core.pragma('dart2js:noInline')
  static MeterMO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MeterMO>(create);
  static MeterMO? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get deviceType => $_getIZ(0);
  @$pb.TagNumber(1)
  set deviceType($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeviceType() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceType() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get serialNumber => $_getI64(1);
  @$pb.TagNumber(2)
  set serialNumber($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSerialNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearSerialNumber() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get phaseTotalPower => $_getIZ(2);
  @$pb.TagNumber(3)
  set phaseTotalPower($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPhaseTotalPower() => $_has(2);
  @$pb.TagNumber(3)
  void clearPhaseTotalPower() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get phaseAPower => $_getIZ(3);
  @$pb.TagNumber(4)
  set phaseAPower($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPhaseAPower() => $_has(3);
  @$pb.TagNumber(4)
  void clearPhaseAPower() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get phaseBPower => $_getIZ(4);
  @$pb.TagNumber(5)
  set phaseBPower($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPhaseBPower() => $_has(4);
  @$pb.TagNumber(5)
  void clearPhaseBPower() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get phaseCPower => $_getIZ(5);
  @$pb.TagNumber(6)
  set phaseCPower($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasPhaseCPower() => $_has(5);
  @$pb.TagNumber(6)
  void clearPhaseCPower() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get powerFactorTotal => $_getIZ(6);
  @$pb.TagNumber(7)
  set powerFactorTotal($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasPowerFactorTotal() => $_has(6);
  @$pb.TagNumber(7)
  void clearPowerFactorTotal() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get energyTotalPower => $_getIZ(7);
  @$pb.TagNumber(8)
  set energyTotalPower($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasEnergyTotalPower() => $_has(7);
  @$pb.TagNumber(8)
  void clearEnergyTotalPower() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get energyPhaseA => $_getIZ(8);
  @$pb.TagNumber(9)
  set energyPhaseA($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasEnergyPhaseA() => $_has(8);
  @$pb.TagNumber(9)
  void clearEnergyPhaseA() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get energyPhaseB => $_getIZ(9);
  @$pb.TagNumber(10)
  set energyPhaseB($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasEnergyPhaseB() => $_has(9);
  @$pb.TagNumber(10)
  void clearEnergyPhaseB() => clearField(10);

  @$pb.TagNumber(11)
  $core.int get energyPhaseC => $_getIZ(10);
  @$pb.TagNumber(11)
  set energyPhaseC($core.int v) { $_setSignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasEnergyPhaseC() => $_has(10);
  @$pb.TagNumber(11)
  void clearEnergyPhaseC() => clearField(11);

  @$pb.TagNumber(12)
  $core.int get energyTotalConsumed => $_getIZ(11);
  @$pb.TagNumber(12)
  set energyTotalConsumed($core.int v) { $_setSignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasEnergyTotalConsumed() => $_has(11);
  @$pb.TagNumber(12)
  void clearEnergyTotalConsumed() => clearField(12);

  @$pb.TagNumber(13)
  $core.int get energyPhaseAConsumed => $_getIZ(12);
  @$pb.TagNumber(13)
  set energyPhaseAConsumed($core.int v) { $_setSignedInt32(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasEnergyPhaseAConsumed() => $_has(12);
  @$pb.TagNumber(13)
  void clearEnergyPhaseAConsumed() => clearField(13);

  @$pb.TagNumber(14)
  $core.int get energyPhaseBConsumed => $_getIZ(13);
  @$pb.TagNumber(14)
  set energyPhaseBConsumed($core.int v) { $_setSignedInt32(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasEnergyPhaseBConsumed() => $_has(13);
  @$pb.TagNumber(14)
  void clearEnergyPhaseBConsumed() => clearField(14);

  @$pb.TagNumber(15)
  $core.int get energyPhaseCConsumed => $_getIZ(14);
  @$pb.TagNumber(15)
  set energyPhaseCConsumed($core.int v) { $_setSignedInt32(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasEnergyPhaseCConsumed() => $_has(14);
  @$pb.TagNumber(15)
  void clearEnergyPhaseCConsumed() => clearField(15);

  @$pb.TagNumber(16)
  $core.int get faultCode => $_getIZ(15);
  @$pb.TagNumber(16)
  set faultCode($core.int v) { $_setSignedInt32(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasFaultCode() => $_has(15);
  @$pb.TagNumber(16)
  void clearFaultCode() => clearField(16);

  @$pb.TagNumber(17)
  $core.int get voltagePhaseA => $_getIZ(16);
  @$pb.TagNumber(17)
  set voltagePhaseA($core.int v) { $_setSignedInt32(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasVoltagePhaseA() => $_has(16);
  @$pb.TagNumber(17)
  void clearVoltagePhaseA() => clearField(17);

  @$pb.TagNumber(18)
  $core.int get voltagePhaseB => $_getIZ(17);
  @$pb.TagNumber(18)
  set voltagePhaseB($core.int v) { $_setSignedInt32(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasVoltagePhaseB() => $_has(17);
  @$pb.TagNumber(18)
  void clearVoltagePhaseB() => clearField(18);

  @$pb.TagNumber(19)
  $core.int get voltagePhaseC => $_getIZ(18);
  @$pb.TagNumber(19)
  set voltagePhaseC($core.int v) { $_setSignedInt32(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasVoltagePhaseC() => $_has(18);
  @$pb.TagNumber(19)
  void clearVoltagePhaseC() => clearField(19);

  @$pb.TagNumber(20)
  $core.int get currentPhaseA => $_getIZ(19);
  @$pb.TagNumber(20)
  set currentPhaseA($core.int v) { $_setSignedInt32(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasCurrentPhaseA() => $_has(19);
  @$pb.TagNumber(20)
  void clearCurrentPhaseA() => clearField(20);

  @$pb.TagNumber(21)
  $core.int get currentPhaseB => $_getIZ(20);
  @$pb.TagNumber(21)
  set currentPhaseB($core.int v) { $_setSignedInt32(20, v); }
  @$pb.TagNumber(21)
  $core.bool hasCurrentPhaseB() => $_has(20);
  @$pb.TagNumber(21)
  void clearCurrentPhaseB() => clearField(21);

  @$pb.TagNumber(22)
  $core.int get currentPhaseC => $_getIZ(21);
  @$pb.TagNumber(22)
  set currentPhaseC($core.int v) { $_setSignedInt32(21, v); }
  @$pb.TagNumber(22)
  $core.bool hasCurrentPhaseC() => $_has(21);
  @$pb.TagNumber(22)
  void clearCurrentPhaseC() => clearField(22);

  @$pb.TagNumber(23)
  $core.int get powerFactorPhaseA => $_getIZ(22);
  @$pb.TagNumber(23)
  set powerFactorPhaseA($core.int v) { $_setSignedInt32(22, v); }
  @$pb.TagNumber(23)
  $core.bool hasPowerFactorPhaseA() => $_has(22);
  @$pb.TagNumber(23)
  void clearPowerFactorPhaseA() => clearField(23);

  @$pb.TagNumber(24)
  $core.int get powerFactorPhaseB => $_getIZ(23);
  @$pb.TagNumber(24)
  set powerFactorPhaseB($core.int v) { $_setSignedInt32(23, v); }
  @$pb.TagNumber(24)
  $core.bool hasPowerFactorPhaseB() => $_has(23);
  @$pb.TagNumber(24)
  void clearPowerFactorPhaseB() => clearField(24);

  @$pb.TagNumber(25)
  $core.int get powerFactorPhaseC => $_getIZ(24);
  @$pb.TagNumber(25)
  set powerFactorPhaseC($core.int v) { $_setSignedInt32(24, v); }
  @$pb.TagNumber(25)
  $core.bool hasPowerFactorPhaseC() => $_has(24);
  @$pb.TagNumber(25)
  void clearPowerFactorPhaseC() => clearField(25);
}

class RpMO extends $pb.GeneratedMessage {
  factory RpMO({
    $fixnum.Int64? serialNumber,
    $core.int? signature,
    $core.int? channel,
    $core.int? pvNumber,
    $core.int? linkStatus,
  }) {
    final $result = create();
    if (serialNumber != null) {
      $result.serialNumber = serialNumber;
    }
    if (signature != null) {
      $result.signature = signature;
    }
    if (channel != null) {
      $result.channel = channel;
    }
    if (pvNumber != null) {
      $result.pvNumber = pvNumber;
    }
    if (linkStatus != null) {
      $result.linkStatus = linkStatus;
    }
    return $result;
  }
  RpMO._() : super();
  factory RpMO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RpMO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RpMO', createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'serialNumber')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'signature', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'channel', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'pvNumber', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'linkStatus', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RpMO clone() => RpMO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RpMO copyWith(void Function(RpMO) updates) => super.copyWith((message) => updates(message as RpMO)) as RpMO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RpMO create() => RpMO._();
  RpMO createEmptyInstance() => create();
  static $pb.PbList<RpMO> createRepeated() => $pb.PbList<RpMO>();
  @$core.pragma('dart2js:noInline')
  static RpMO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RpMO>(create);
  static RpMO? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get serialNumber => $_getI64(0);
  @$pb.TagNumber(1)
  set serialNumber($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSerialNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSerialNumber() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get signature => $_getIZ(1);
  @$pb.TagNumber(2)
  set signature($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignature() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get channel => $_getIZ(2);
  @$pb.TagNumber(3)
  set channel($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasChannel() => $_has(2);
  @$pb.TagNumber(3)
  void clearChannel() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get pvNumber => $_getIZ(3);
  @$pb.TagNumber(4)
  set pvNumber($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPvNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearPvNumber() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get linkStatus => $_getIZ(4);
  @$pb.TagNumber(5)
  set linkStatus($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasLinkStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearLinkStatus() => clearField(5);
}

class RSDMO extends $pb.GeneratedMessage {
  factory RSDMO({
    $fixnum.Int64? serialNumber,
    $core.int? firmwareVersion,
    $core.int? voltage,
    $core.int? power,
    $core.int? temperature,
    $core.int? warningNumber,
    $core.int? crcChecksum,
    $core.int? linkStatus,
  }) {
    final $result = create();
    if (serialNumber != null) {
      $result.serialNumber = serialNumber;
    }
    if (firmwareVersion != null) {
      $result.firmwareVersion = firmwareVersion;
    }
    if (voltage != null) {
      $result.voltage = voltage;
    }
    if (power != null) {
      $result.power = power;
    }
    if (temperature != null) {
      $result.temperature = temperature;
    }
    if (warningNumber != null) {
      $result.warningNumber = warningNumber;
    }
    if (crcChecksum != null) {
      $result.crcChecksum = crcChecksum;
    }
    if (linkStatus != null) {
      $result.linkStatus = linkStatus;
    }
    return $result;
  }
  RSDMO._() : super();
  factory RSDMO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RSDMO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RSDMO', createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'serialNumber')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'firmwareVersion', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'voltage', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'power', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'temperature', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'warningNumber', $pb.PbFieldType.O3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'crcChecksum', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'linkStatus', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RSDMO clone() => RSDMO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RSDMO copyWith(void Function(RSDMO) updates) => super.copyWith((message) => updates(message as RSDMO)) as RSDMO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RSDMO create() => RSDMO._();
  RSDMO createEmptyInstance() => create();
  static $pb.PbList<RSDMO> createRepeated() => $pb.PbList<RSDMO>();
  @$core.pragma('dart2js:noInline')
  static RSDMO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RSDMO>(create);
  static RSDMO? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get serialNumber => $_getI64(0);
  @$pb.TagNumber(1)
  set serialNumber($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSerialNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSerialNumber() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get firmwareVersion => $_getIZ(1);
  @$pb.TagNumber(2)
  set firmwareVersion($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFirmwareVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearFirmwareVersion() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get voltage => $_getIZ(2);
  @$pb.TagNumber(3)
  set voltage($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasVoltage() => $_has(2);
  @$pb.TagNumber(3)
  void clearVoltage() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get power => $_getIZ(3);
  @$pb.TagNumber(4)
  set power($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPower() => $_has(3);
  @$pb.TagNumber(4)
  void clearPower() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get temperature => $_getIZ(4);
  @$pb.TagNumber(5)
  set temperature($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTemperature() => $_has(4);
  @$pb.TagNumber(5)
  void clearTemperature() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get warningNumber => $_getIZ(5);
  @$pb.TagNumber(6)
  set warningNumber($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasWarningNumber() => $_has(5);
  @$pb.TagNumber(6)
  void clearWarningNumber() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get crcChecksum => $_getIZ(6);
  @$pb.TagNumber(7)
  set crcChecksum($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCrcChecksum() => $_has(6);
  @$pb.TagNumber(7)
  void clearCrcChecksum() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get linkStatus => $_getIZ(7);
  @$pb.TagNumber(8)
  set linkStatus($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasLinkStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearLinkStatus() => clearField(8);
}

class SGSMO extends $pb.GeneratedMessage {
  factory SGSMO({
    $fixnum.Int64? serialNumber,
    $core.int? firmwareVersion,
    $core.int? voltage,
    $core.int? frequency,
    $core.int? activePower,
    $core.int? reactivePower,
    $core.int? current,
    $core.int? powerFactor,
    $core.int? temperature,
    $core.int? warningNumber,
    $core.int? crcChecksum,
    $core.int? linkStatus,
    $core.int? powerLimit,
    $core.int? modulationIndexSignal,
  }) {
    final $result = create();
    if (serialNumber != null) {
      $result.serialNumber = serialNumber;
    }
    if (firmwareVersion != null) {
      $result.firmwareVersion = firmwareVersion;
    }
    if (voltage != null) {
      $result.voltage = voltage;
    }
    if (frequency != null) {
      $result.frequency = frequency;
    }
    if (activePower != null) {
      $result.activePower = activePower;
    }
    if (reactivePower != null) {
      $result.reactivePower = reactivePower;
    }
    if (current != null) {
      $result.current = current;
    }
    if (powerFactor != null) {
      $result.powerFactor = powerFactor;
    }
    if (temperature != null) {
      $result.temperature = temperature;
    }
    if (warningNumber != null) {
      $result.warningNumber = warningNumber;
    }
    if (crcChecksum != null) {
      $result.crcChecksum = crcChecksum;
    }
    if (linkStatus != null) {
      $result.linkStatus = linkStatus;
    }
    if (powerLimit != null) {
      $result.powerLimit = powerLimit;
    }
    if (modulationIndexSignal != null) {
      $result.modulationIndexSignal = modulationIndexSignal;
    }
    return $result;
  }
  SGSMO._() : super();
  factory SGSMO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SGSMO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SGSMO', createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'serialNumber')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'firmwareVersion', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'voltage', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'frequency', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'activePower', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'reactivePower', $pb.PbFieldType.O3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'current', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'powerFactor', $pb.PbFieldType.O3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'temperature', $pb.PbFieldType.O3)
    ..a<$core.int>(10, _omitFieldNames ? '' : 'warningNumber', $pb.PbFieldType.O3)
    ..a<$core.int>(11, _omitFieldNames ? '' : 'crcChecksum', $pb.PbFieldType.O3)
    ..a<$core.int>(12, _omitFieldNames ? '' : 'linkStatus', $pb.PbFieldType.O3)
    ..a<$core.int>(13, _omitFieldNames ? '' : 'powerLimit', $pb.PbFieldType.O3)
    ..a<$core.int>(20, _omitFieldNames ? '' : 'modulationIndexSignal', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SGSMO clone() => SGSMO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SGSMO copyWith(void Function(SGSMO) updates) => super.copyWith((message) => updates(message as SGSMO)) as SGSMO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SGSMO create() => SGSMO._();
  SGSMO createEmptyInstance() => create();
  static $pb.PbList<SGSMO> createRepeated() => $pb.PbList<SGSMO>();
  @$core.pragma('dart2js:noInline')
  static SGSMO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SGSMO>(create);
  static SGSMO? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get serialNumber => $_getI64(0);
  @$pb.TagNumber(1)
  set serialNumber($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSerialNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSerialNumber() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get firmwareVersion => $_getIZ(1);
  @$pb.TagNumber(2)
  set firmwareVersion($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFirmwareVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearFirmwareVersion() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get voltage => $_getIZ(2);
  @$pb.TagNumber(3)
  set voltage($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasVoltage() => $_has(2);
  @$pb.TagNumber(3)
  void clearVoltage() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get frequency => $_getIZ(3);
  @$pb.TagNumber(4)
  set frequency($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFrequency() => $_has(3);
  @$pb.TagNumber(4)
  void clearFrequency() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get activePower => $_getIZ(4);
  @$pb.TagNumber(5)
  set activePower($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasActivePower() => $_has(4);
  @$pb.TagNumber(5)
  void clearActivePower() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get reactivePower => $_getIZ(5);
  @$pb.TagNumber(6)
  set reactivePower($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasReactivePower() => $_has(5);
  @$pb.TagNumber(6)
  void clearReactivePower() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get current => $_getIZ(6);
  @$pb.TagNumber(7)
  set current($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCurrent() => $_has(6);
  @$pb.TagNumber(7)
  void clearCurrent() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get powerFactor => $_getIZ(7);
  @$pb.TagNumber(8)
  set powerFactor($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasPowerFactor() => $_has(7);
  @$pb.TagNumber(8)
  void clearPowerFactor() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get temperature => $_getIZ(8);
  @$pb.TagNumber(9)
  set temperature($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasTemperature() => $_has(8);
  @$pb.TagNumber(9)
  void clearTemperature() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get warningNumber => $_getIZ(9);
  @$pb.TagNumber(10)
  set warningNumber($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasWarningNumber() => $_has(9);
  @$pb.TagNumber(10)
  void clearWarningNumber() => clearField(10);

  @$pb.TagNumber(11)
  $core.int get crcChecksum => $_getIZ(10);
  @$pb.TagNumber(11)
  set crcChecksum($core.int v) { $_setSignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasCrcChecksum() => $_has(10);
  @$pb.TagNumber(11)
  void clearCrcChecksum() => clearField(11);

  @$pb.TagNumber(12)
  $core.int get linkStatus => $_getIZ(11);
  @$pb.TagNumber(12)
  set linkStatus($core.int v) { $_setSignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasLinkStatus() => $_has(11);
  @$pb.TagNumber(12)
  void clearLinkStatus() => clearField(12);

  @$pb.TagNumber(13)
  $core.int get powerLimit => $_getIZ(12);
  @$pb.TagNumber(13)
  set powerLimit($core.int v) { $_setSignedInt32(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasPowerLimit() => $_has(12);
  @$pb.TagNumber(13)
  void clearPowerLimit() => clearField(13);

  @$pb.TagNumber(20)
  $core.int get modulationIndexSignal => $_getIZ(13);
  @$pb.TagNumber(20)
  set modulationIndexSignal($core.int v) { $_setSignedInt32(13, v); }
  @$pb.TagNumber(20)
  $core.bool hasModulationIndexSignal() => $_has(13);
  @$pb.TagNumber(20)
  void clearModulationIndexSignal() => clearField(20);
}

class TGSMO extends $pb.GeneratedMessage {
  factory TGSMO({
    $fixnum.Int64? serialNumber,
    $core.int? firmwareVersion,
    $core.int? voltagePhaseA,
    $core.int? voltagePhaseB,
    $core.int? voltagePhaseC,
    $core.int? voltageLineAB,
    $core.int? voltageLineBC,
    $core.int? voltageLineCA,
    $core.int? frequency,
    $core.int? activePower,
    $core.int? reactivePower,
    $core.int? currentPhaseA,
    $core.int? currentPhaseB,
    $core.int? currentPhaseC,
    $core.int? powerFactor,
    $core.int? temperature,
    $core.int? warningNumber,
    $core.int? crcChecksum,
    $core.int? linkStatus,
    $core.int? modulationIndexSignal,
  }) {
    final $result = create();
    if (serialNumber != null) {
      $result.serialNumber = serialNumber;
    }
    if (firmwareVersion != null) {
      $result.firmwareVersion = firmwareVersion;
    }
    if (voltagePhaseA != null) {
      $result.voltagePhaseA = voltagePhaseA;
    }
    if (voltagePhaseB != null) {
      $result.voltagePhaseB = voltagePhaseB;
    }
    if (voltagePhaseC != null) {
      $result.voltagePhaseC = voltagePhaseC;
    }
    if (voltageLineAB != null) {
      $result.voltageLineAB = voltageLineAB;
    }
    if (voltageLineBC != null) {
      $result.voltageLineBC = voltageLineBC;
    }
    if (voltageLineCA != null) {
      $result.voltageLineCA = voltageLineCA;
    }
    if (frequency != null) {
      $result.frequency = frequency;
    }
    if (activePower != null) {
      $result.activePower = activePower;
    }
    if (reactivePower != null) {
      $result.reactivePower = reactivePower;
    }
    if (currentPhaseA != null) {
      $result.currentPhaseA = currentPhaseA;
    }
    if (currentPhaseB != null) {
      $result.currentPhaseB = currentPhaseB;
    }
    if (currentPhaseC != null) {
      $result.currentPhaseC = currentPhaseC;
    }
    if (powerFactor != null) {
      $result.powerFactor = powerFactor;
    }
    if (temperature != null) {
      $result.temperature = temperature;
    }
    if (warningNumber != null) {
      $result.warningNumber = warningNumber;
    }
    if (crcChecksum != null) {
      $result.crcChecksum = crcChecksum;
    }
    if (linkStatus != null) {
      $result.linkStatus = linkStatus;
    }
    if (modulationIndexSignal != null) {
      $result.modulationIndexSignal = modulationIndexSignal;
    }
    return $result;
  }
  TGSMO._() : super();
  factory TGSMO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TGSMO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TGSMO', createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'serialNumber')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'firmwareVersion', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'voltagePhaseA', $pb.PbFieldType.O3, protoName: 'voltage_phase_A')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'voltagePhaseB', $pb.PbFieldType.O3, protoName: 'voltage_phase_B')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'voltagePhaseC', $pb.PbFieldType.O3, protoName: 'voltage_phase_C')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'voltageLineAB', $pb.PbFieldType.O3, protoName: 'voltage_line_AB')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'voltageLineBC', $pb.PbFieldType.O3, protoName: 'voltage_line_BC')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'voltageLineCA', $pb.PbFieldType.O3, protoName: 'voltage_line_CA')
    ..a<$core.int>(9, _omitFieldNames ? '' : 'frequency', $pb.PbFieldType.O3)
    ..a<$core.int>(10, _omitFieldNames ? '' : 'activePower', $pb.PbFieldType.O3)
    ..a<$core.int>(11, _omitFieldNames ? '' : 'reactivePower', $pb.PbFieldType.O3)
    ..a<$core.int>(12, _omitFieldNames ? '' : 'currentPhaseA', $pb.PbFieldType.O3, protoName: 'current_phase_A')
    ..a<$core.int>(13, _omitFieldNames ? '' : 'currentPhaseB', $pb.PbFieldType.O3, protoName: 'current_phase_B')
    ..a<$core.int>(14, _omitFieldNames ? '' : 'currentPhaseC', $pb.PbFieldType.O3, protoName: 'current_phase_C')
    ..a<$core.int>(15, _omitFieldNames ? '' : 'powerFactor', $pb.PbFieldType.O3)
    ..a<$core.int>(16, _omitFieldNames ? '' : 'temperature', $pb.PbFieldType.O3)
    ..a<$core.int>(17, _omitFieldNames ? '' : 'warningNumber', $pb.PbFieldType.O3)
    ..a<$core.int>(18, _omitFieldNames ? '' : 'crcChecksum', $pb.PbFieldType.O3)
    ..a<$core.int>(19, _omitFieldNames ? '' : 'linkStatus', $pb.PbFieldType.O3)
    ..a<$core.int>(20, _omitFieldNames ? '' : 'modulationIndexSignal', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TGSMO clone() => TGSMO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TGSMO copyWith(void Function(TGSMO) updates) => super.copyWith((message) => updates(message as TGSMO)) as TGSMO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TGSMO create() => TGSMO._();
  TGSMO createEmptyInstance() => create();
  static $pb.PbList<TGSMO> createRepeated() => $pb.PbList<TGSMO>();
  @$core.pragma('dart2js:noInline')
  static TGSMO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TGSMO>(create);
  static TGSMO? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get serialNumber => $_getI64(0);
  @$pb.TagNumber(1)
  set serialNumber($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSerialNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSerialNumber() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get firmwareVersion => $_getIZ(1);
  @$pb.TagNumber(2)
  set firmwareVersion($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFirmwareVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearFirmwareVersion() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get voltagePhaseA => $_getIZ(2);
  @$pb.TagNumber(3)
  set voltagePhaseA($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasVoltagePhaseA() => $_has(2);
  @$pb.TagNumber(3)
  void clearVoltagePhaseA() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get voltagePhaseB => $_getIZ(3);
  @$pb.TagNumber(4)
  set voltagePhaseB($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasVoltagePhaseB() => $_has(3);
  @$pb.TagNumber(4)
  void clearVoltagePhaseB() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get voltagePhaseC => $_getIZ(4);
  @$pb.TagNumber(5)
  set voltagePhaseC($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasVoltagePhaseC() => $_has(4);
  @$pb.TagNumber(5)
  void clearVoltagePhaseC() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get voltageLineAB => $_getIZ(5);
  @$pb.TagNumber(6)
  set voltageLineAB($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasVoltageLineAB() => $_has(5);
  @$pb.TagNumber(6)
  void clearVoltageLineAB() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get voltageLineBC => $_getIZ(6);
  @$pb.TagNumber(7)
  set voltageLineBC($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasVoltageLineBC() => $_has(6);
  @$pb.TagNumber(7)
  void clearVoltageLineBC() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get voltageLineCA => $_getIZ(7);
  @$pb.TagNumber(8)
  set voltageLineCA($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasVoltageLineCA() => $_has(7);
  @$pb.TagNumber(8)
  void clearVoltageLineCA() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get frequency => $_getIZ(8);
  @$pb.TagNumber(9)
  set frequency($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasFrequency() => $_has(8);
  @$pb.TagNumber(9)
  void clearFrequency() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get activePower => $_getIZ(9);
  @$pb.TagNumber(10)
  set activePower($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasActivePower() => $_has(9);
  @$pb.TagNumber(10)
  void clearActivePower() => clearField(10);

  @$pb.TagNumber(11)
  $core.int get reactivePower => $_getIZ(10);
  @$pb.TagNumber(11)
  set reactivePower($core.int v) { $_setSignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasReactivePower() => $_has(10);
  @$pb.TagNumber(11)
  void clearReactivePower() => clearField(11);

  @$pb.TagNumber(12)
  $core.int get currentPhaseA => $_getIZ(11);
  @$pb.TagNumber(12)
  set currentPhaseA($core.int v) { $_setSignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasCurrentPhaseA() => $_has(11);
  @$pb.TagNumber(12)
  void clearCurrentPhaseA() => clearField(12);

  @$pb.TagNumber(13)
  $core.int get currentPhaseB => $_getIZ(12);
  @$pb.TagNumber(13)
  set currentPhaseB($core.int v) { $_setSignedInt32(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasCurrentPhaseB() => $_has(12);
  @$pb.TagNumber(13)
  void clearCurrentPhaseB() => clearField(13);

  @$pb.TagNumber(14)
  $core.int get currentPhaseC => $_getIZ(13);
  @$pb.TagNumber(14)
  set currentPhaseC($core.int v) { $_setSignedInt32(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasCurrentPhaseC() => $_has(13);
  @$pb.TagNumber(14)
  void clearCurrentPhaseC() => clearField(14);

  @$pb.TagNumber(15)
  $core.int get powerFactor => $_getIZ(14);
  @$pb.TagNumber(15)
  set powerFactor($core.int v) { $_setSignedInt32(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasPowerFactor() => $_has(14);
  @$pb.TagNumber(15)
  void clearPowerFactor() => clearField(15);

  @$pb.TagNumber(16)
  $core.int get temperature => $_getIZ(15);
  @$pb.TagNumber(16)
  set temperature($core.int v) { $_setSignedInt32(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasTemperature() => $_has(15);
  @$pb.TagNumber(16)
  void clearTemperature() => clearField(16);

  @$pb.TagNumber(17)
  $core.int get warningNumber => $_getIZ(16);
  @$pb.TagNumber(17)
  set warningNumber($core.int v) { $_setSignedInt32(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasWarningNumber() => $_has(16);
  @$pb.TagNumber(17)
  void clearWarningNumber() => clearField(17);

  @$pb.TagNumber(18)
  $core.int get crcChecksum => $_getIZ(17);
  @$pb.TagNumber(18)
  set crcChecksum($core.int v) { $_setSignedInt32(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasCrcChecksum() => $_has(17);
  @$pb.TagNumber(18)
  void clearCrcChecksum() => clearField(18);

  @$pb.TagNumber(19)
  $core.int get linkStatus => $_getIZ(18);
  @$pb.TagNumber(19)
  set linkStatus($core.int v) { $_setSignedInt32(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasLinkStatus() => $_has(18);
  @$pb.TagNumber(19)
  void clearLinkStatus() => clearField(19);

  @$pb.TagNumber(20)
  $core.int get modulationIndexSignal => $_getIZ(19);
  @$pb.TagNumber(20)
  set modulationIndexSignal($core.int v) { $_setSignedInt32(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasModulationIndexSignal() => $_has(19);
  @$pb.TagNumber(20)
  void clearModulationIndexSignal() => clearField(20);
}

class PvMO extends $pb.GeneratedMessage {
  factory PvMO({
    $fixnum.Int64? serialNumber,
    $core.int? portNumber,
    $core.int? voltage,
    $core.int? current,
    $core.int? power,
    $core.int? energyTotal,
    $core.int? energyDaily,
    $core.int? errorCode,
  }) {
    final $result = create();
    if (serialNumber != null) {
      $result.serialNumber = serialNumber;
    }
    if (portNumber != null) {
      $result.portNumber = portNumber;
    }
    if (voltage != null) {
      $result.voltage = voltage;
    }
    if (current != null) {
      $result.current = current;
    }
    if (power != null) {
      $result.power = power;
    }
    if (energyTotal != null) {
      $result.energyTotal = energyTotal;
    }
    if (energyDaily != null) {
      $result.energyDaily = energyDaily;
    }
    if (errorCode != null) {
      $result.errorCode = errorCode;
    }
    return $result;
  }
  PvMO._() : super();
  factory PvMO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PvMO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PvMO', createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'serialNumber')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'portNumber', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'voltage', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'current', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'power', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'energyTotal', $pb.PbFieldType.O3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'energyDaily', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'errorCode', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PvMO clone() => PvMO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PvMO copyWith(void Function(PvMO) updates) => super.copyWith((message) => updates(message as PvMO)) as PvMO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PvMO create() => PvMO._();
  PvMO createEmptyInstance() => create();
  static $pb.PbList<PvMO> createRepeated() => $pb.PbList<PvMO>();
  @$core.pragma('dart2js:noInline')
  static PvMO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PvMO>(create);
  static PvMO? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get serialNumber => $_getI64(0);
  @$pb.TagNumber(1)
  set serialNumber($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSerialNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSerialNumber() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get portNumber => $_getIZ(1);
  @$pb.TagNumber(2)
  set portNumber($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPortNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearPortNumber() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get voltage => $_getIZ(2);
  @$pb.TagNumber(3)
  set voltage($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasVoltage() => $_has(2);
  @$pb.TagNumber(3)
  void clearVoltage() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get current => $_getIZ(3);
  @$pb.TagNumber(4)
  set current($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCurrent() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrent() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get power => $_getIZ(4);
  @$pb.TagNumber(5)
  set power($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPower() => $_has(4);
  @$pb.TagNumber(5)
  void clearPower() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get energyTotal => $_getIZ(5);
  @$pb.TagNumber(6)
  set energyTotal($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasEnergyTotal() => $_has(5);
  @$pb.TagNumber(6)
  void clearEnergyTotal() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get energyDaily => $_getIZ(6);
  @$pb.TagNumber(7)
  set energyDaily($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasEnergyDaily() => $_has(6);
  @$pb.TagNumber(7)
  void clearEnergyDaily() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get errorCode => $_getIZ(7);
  @$pb.TagNumber(8)
  set errorCode($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasErrorCode() => $_has(7);
  @$pb.TagNumber(8)
  void clearErrorCode() => clearField(8);
}

class RealDataNewReqDTO extends $pb.GeneratedMessage {
  factory RealDataNewReqDTO({
    $core.String? deviceSerialNumber,
    $core.int? timestamp,
    $core.int? ap,
    $core.int? cp,
    $core.int? firmwareVersion,
    $core.Iterable<MeterMO>? meterData,
    $core.Iterable<RpMO>? rpData,
    $core.Iterable<RSDMO>? rsdData,
    $core.Iterable<SGSMO>? sgsData,
    $core.Iterable<TGSMO>? tgsData,
    $core.Iterable<PvMO>? pvData,
    $fixnum.Int64? dtuPower,
    $fixnum.Int64? dtuDailyEnergy,
  }) {
    final $result = create();
    if (deviceSerialNumber != null) {
      $result.deviceSerialNumber = deviceSerialNumber;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (ap != null) {
      $result.ap = ap;
    }
    if (cp != null) {
      $result.cp = cp;
    }
    if (firmwareVersion != null) {
      $result.firmwareVersion = firmwareVersion;
    }
    if (meterData != null) {
      $result.meterData.addAll(meterData);
    }
    if (rpData != null) {
      $result.rpData.addAll(rpData);
    }
    if (rsdData != null) {
      $result.rsdData.addAll(rsdData);
    }
    if (sgsData != null) {
      $result.sgsData.addAll(sgsData);
    }
    if (tgsData != null) {
      $result.tgsData.addAll(tgsData);
    }
    if (pvData != null) {
      $result.pvData.addAll(pvData);
    }
    if (dtuPower != null) {
      $result.dtuPower = dtuPower;
    }
    if (dtuDailyEnergy != null) {
      $result.dtuDailyEnergy = dtuDailyEnergy;
    }
    return $result;
  }
  RealDataNewReqDTO._() : super();
  factory RealDataNewReqDTO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RealDataNewReqDTO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RealDataNewReqDTO', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceSerialNumber')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'ap', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'cp', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'firmwareVersion', $pb.PbFieldType.O3)
    ..pc<MeterMO>(6, _omitFieldNames ? '' : 'meterData', $pb.PbFieldType.PM, subBuilder: MeterMO.create)
    ..pc<RpMO>(7, _omitFieldNames ? '' : 'rpData', $pb.PbFieldType.PM, subBuilder: RpMO.create)
    ..pc<RSDMO>(8, _omitFieldNames ? '' : 'rsdData', $pb.PbFieldType.PM, subBuilder: RSDMO.create)
    ..pc<SGSMO>(9, _omitFieldNames ? '' : 'sgsData', $pb.PbFieldType.PM, subBuilder: SGSMO.create)
    ..pc<TGSMO>(10, _omitFieldNames ? '' : 'tgsData', $pb.PbFieldType.PM, subBuilder: TGSMO.create)
    ..pc<PvMO>(11, _omitFieldNames ? '' : 'pvData', $pb.PbFieldType.PM, subBuilder: PvMO.create)
    ..a<$fixnum.Int64>(12, _omitFieldNames ? '' : 'dtuPower', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(13, _omitFieldNames ? '' : 'dtuDailyEnergy', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RealDataNewReqDTO clone() => RealDataNewReqDTO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RealDataNewReqDTO copyWith(void Function(RealDataNewReqDTO) updates) => super.copyWith((message) => updates(message as RealDataNewReqDTO)) as RealDataNewReqDTO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RealDataNewReqDTO create() => RealDataNewReqDTO._();
  RealDataNewReqDTO createEmptyInstance() => create();
  static $pb.PbList<RealDataNewReqDTO> createRepeated() => $pb.PbList<RealDataNewReqDTO>();
  @$core.pragma('dart2js:noInline')
  static RealDataNewReqDTO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RealDataNewReqDTO>(create);
  static RealDataNewReqDTO? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceSerialNumber => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceSerialNumber($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeviceSerialNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceSerialNumber() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get timestamp => $_getIZ(1);
  @$pb.TagNumber(2)
  set timestamp($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get ap => $_getIZ(2);
  @$pb.TagNumber(3)
  set ap($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAp() => $_has(2);
  @$pb.TagNumber(3)
  void clearAp() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get cp => $_getIZ(3);
  @$pb.TagNumber(4)
  set cp($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCp() => $_has(3);
  @$pb.TagNumber(4)
  void clearCp() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get firmwareVersion => $_getIZ(4);
  @$pb.TagNumber(5)
  set firmwareVersion($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFirmwareVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearFirmwareVersion() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<MeterMO> get meterData => $_getList(5);

  @$pb.TagNumber(7)
  $core.List<RpMO> get rpData => $_getList(6);

  @$pb.TagNumber(8)
  $core.List<RSDMO> get rsdData => $_getList(7);

  @$pb.TagNumber(9)
  $core.List<SGSMO> get sgsData => $_getList(8);

  @$pb.TagNumber(10)
  $core.List<TGSMO> get tgsData => $_getList(9);

  @$pb.TagNumber(11)
  $core.List<PvMO> get pvData => $_getList(10);

  @$pb.TagNumber(12)
  $fixnum.Int64 get dtuPower => $_getI64(11);
  @$pb.TagNumber(12)
  set dtuPower($fixnum.Int64 v) { $_setInt64(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasDtuPower() => $_has(11);
  @$pb.TagNumber(12)
  void clearDtuPower() => clearField(12);

  @$pb.TagNumber(13)
  $fixnum.Int64 get dtuDailyEnergy => $_getI64(12);
  @$pb.TagNumber(13)
  set dtuDailyEnergy($fixnum.Int64 v) { $_setInt64(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasDtuDailyEnergy() => $_has(12);
  @$pb.TagNumber(13)
  void clearDtuDailyEnergy() => clearField(13);
}

class RealDataNewResDTO extends $pb.GeneratedMessage {
  factory RealDataNewResDTO({
    $core.List<$core.int>? timeYmdHms,
    $core.int? cp,
    $core.int? errorCode,
    $core.int? offset,
    $core.int? time,
  }) {
    final $result = create();
    if (timeYmdHms != null) {
      $result.timeYmdHms = timeYmdHms;
    }
    if (cp != null) {
      $result.cp = cp;
    }
    if (errorCode != null) {
      $result.errorCode = errorCode;
    }
    if (offset != null) {
      $result.offset = offset;
    }
    if (time != null) {
      $result.time = time;
    }
    return $result;
  }
  RealDataNewResDTO._() : super();
  factory RealDataNewResDTO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RealDataNewResDTO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RealDataNewResDTO', createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'timeYmdHms', $pb.PbFieldType.OY)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'cp', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'errorCode', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'time', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RealDataNewResDTO clone() => RealDataNewResDTO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RealDataNewResDTO copyWith(void Function(RealDataNewResDTO) updates) => super.copyWith((message) => updates(message as RealDataNewResDTO)) as RealDataNewResDTO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RealDataNewResDTO create() => RealDataNewResDTO._();
  RealDataNewResDTO createEmptyInstance() => create();
  static $pb.PbList<RealDataNewResDTO> createRepeated() => $pb.PbList<RealDataNewResDTO>();
  @$core.pragma('dart2js:noInline')
  static RealDataNewResDTO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RealDataNewResDTO>(create);
  static RealDataNewResDTO? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get timeYmdHms => $_getN(0);
  @$pb.TagNumber(1)
  set timeYmdHms($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTimeYmdHms() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimeYmdHms() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get cp => $_getIZ(1);
  @$pb.TagNumber(2)
  set cp($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCp() => $_has(1);
  @$pb.TagNumber(2)
  void clearCp() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get errorCode => $_getIZ(2);
  @$pb.TagNumber(3)
  set errorCode($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasErrorCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearErrorCode() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get offset => $_getIZ(3);
  @$pb.TagNumber(4)
  set offset($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOffset() => $_has(3);
  @$pb.TagNumber(4)
  void clearOffset() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get time => $_getIZ(4);
  @$pb.TagNumber(5)
  set time($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearTime() => clearField(5);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
