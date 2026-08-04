//
//  Generated code. Do not modify.
//  source: AppGetHistPower.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class AppGetHistPowerResDTO extends $pb.GeneratedMessage {
  factory AppGetHistPowerResDTO({
    $core.int? cp,
    $core.int? offset,
    $core.int? requestedTime,
    $core.int? requestedDay,
  }) {
    final $result = create();
    if (cp != null) {
      $result.cp = cp;
    }
    if (offset != null) {
      $result.offset = offset;
    }
    if (requestedTime != null) {
      $result.requestedTime = requestedTime;
    }
    if (requestedDay != null) {
      $result.requestedDay = requestedDay;
    }
    return $result;
  }
  AppGetHistPowerResDTO._() : super();
  factory AppGetHistPowerResDTO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AppGetHistPowerResDTO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AppGetHistPowerResDTO', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'cp', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'requestedTime', $pb.PbFieldType.OU3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'requestedDay', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AppGetHistPowerResDTO clone() => AppGetHistPowerResDTO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AppGetHistPowerResDTO copyWith(void Function(AppGetHistPowerResDTO) updates) => super.copyWith((message) => updates(message as AppGetHistPowerResDTO)) as AppGetHistPowerResDTO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AppGetHistPowerResDTO create() => AppGetHistPowerResDTO._();
  AppGetHistPowerResDTO createEmptyInstance() => create();
  static $pb.PbList<AppGetHistPowerResDTO> createRepeated() => $pb.PbList<AppGetHistPowerResDTO>();
  @$core.pragma('dart2js:noInline')
  static AppGetHistPowerResDTO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AppGetHistPowerResDTO>(create);
  static AppGetHistPowerResDTO? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get cp => $_getIZ(0);
  @$pb.TagNumber(1)
  set cp($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCp() => $_has(0);
  @$pb.TagNumber(1)
  void clearCp() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get offset => $_getIZ(1);
  @$pb.TagNumber(2)
  set offset($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOffset() => $_has(1);
  @$pb.TagNumber(2)
  void clearOffset() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get requestedTime => $_getIZ(2);
  @$pb.TagNumber(3)
  set requestedTime($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRequestedTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequestedTime() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get requestedDay => $_getIZ(3);
  @$pb.TagNumber(4)
  set requestedDay($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRequestedDay() => $_has(3);
  @$pb.TagNumber(4)
  void clearRequestedDay() => clearField(4);
}

class AppGetHistPowerReqDTO extends $pb.GeneratedMessage {
  factory AppGetHistPowerReqDTO({
    $fixnum.Int64? serialNumber,
    $core.int? ap,
    $core.int? cp,
    $core.int? offset,
    $core.int? requestTime,
    $core.int? startTime,
    $core.int? longTermStart,
    $core.int? absoluteStart,
    $core.int? stepTime,
    $core.int? relativePower,
    $core.int? totalEnergy,
    $core.int? dailyEnergy,
    $core.Iterable<$core.int>? powerArray,
    $core.int? warningNumber,
  }) {
    final $result = create();
    if (serialNumber != null) {
      $result.serialNumber = serialNumber;
    }
    if (ap != null) {
      $result.ap = ap;
    }
    if (cp != null) {
      $result.cp = cp;
    }
    if (offset != null) {
      $result.offset = offset;
    }
    if (requestTime != null) {
      $result.requestTime = requestTime;
    }
    if (startTime != null) {
      $result.startTime = startTime;
    }
    if (longTermStart != null) {
      $result.longTermStart = longTermStart;
    }
    if (absoluteStart != null) {
      $result.absoluteStart = absoluteStart;
    }
    if (stepTime != null) {
      $result.stepTime = stepTime;
    }
    if (relativePower != null) {
      $result.relativePower = relativePower;
    }
    if (totalEnergy != null) {
      $result.totalEnergy = totalEnergy;
    }
    if (dailyEnergy != null) {
      $result.dailyEnergy = dailyEnergy;
    }
    if (powerArray != null) {
      $result.powerArray.addAll(powerArray);
    }
    if (warningNumber != null) {
      $result.warningNumber = warningNumber;
    }
    return $result;
  }
  AppGetHistPowerReqDTO._() : super();
  factory AppGetHistPowerReqDTO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AppGetHistPowerReqDTO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AppGetHistPowerReqDTO', createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'serialNumber')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'ap', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'cp', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'requestTime', $pb.PbFieldType.OU3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'startTime', $pb.PbFieldType.OU3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'longTermStart', $pb.PbFieldType.OU3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'absoluteStart', $pb.PbFieldType.OU3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'stepTime', $pb.PbFieldType.OU3)
    ..a<$core.int>(10, _omitFieldNames ? '' : 'relativePower', $pb.PbFieldType.OU3)
    ..a<$core.int>(11, _omitFieldNames ? '' : 'totalEnergy', $pb.PbFieldType.OU3)
    ..a<$core.int>(12, _omitFieldNames ? '' : 'dailyEnergy', $pb.PbFieldType.OU3)
    ..p<$core.int>(13, _omitFieldNames ? '' : 'powerArray', $pb.PbFieldType.K3)
    ..a<$core.int>(14, _omitFieldNames ? '' : 'warningNumber', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AppGetHistPowerReqDTO clone() => AppGetHistPowerReqDTO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AppGetHistPowerReqDTO copyWith(void Function(AppGetHistPowerReqDTO) updates) => super.copyWith((message) => updates(message as AppGetHistPowerReqDTO)) as AppGetHistPowerReqDTO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AppGetHistPowerReqDTO create() => AppGetHistPowerReqDTO._();
  AppGetHistPowerReqDTO createEmptyInstance() => create();
  static $pb.PbList<AppGetHistPowerReqDTO> createRepeated() => $pb.PbList<AppGetHistPowerReqDTO>();
  @$core.pragma('dart2js:noInline')
  static AppGetHistPowerReqDTO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AppGetHistPowerReqDTO>(create);
  static AppGetHistPowerReqDTO? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get serialNumber => $_getI64(0);
  @$pb.TagNumber(1)
  set serialNumber($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSerialNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSerialNumber() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get ap => $_getIZ(1);
  @$pb.TagNumber(2)
  set ap($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAp() => $_has(1);
  @$pb.TagNumber(2)
  void clearAp() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get cp => $_getIZ(2);
  @$pb.TagNumber(3)
  set cp($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCp() => $_has(2);
  @$pb.TagNumber(3)
  void clearCp() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get offset => $_getIZ(3);
  @$pb.TagNumber(4)
  set offset($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOffset() => $_has(3);
  @$pb.TagNumber(4)
  void clearOffset() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get requestTime => $_getIZ(4);
  @$pb.TagNumber(5)
  set requestTime($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasRequestTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearRequestTime() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get startTime => $_getIZ(5);
  @$pb.TagNumber(6)
  set startTime($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasStartTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearStartTime() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get longTermStart => $_getIZ(6);
  @$pb.TagNumber(7)
  set longTermStart($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasLongTermStart() => $_has(6);
  @$pb.TagNumber(7)
  void clearLongTermStart() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get absoluteStart => $_getIZ(7);
  @$pb.TagNumber(8)
  set absoluteStart($core.int v) { $_setUnsignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasAbsoluteStart() => $_has(7);
  @$pb.TagNumber(8)
  void clearAbsoluteStart() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get stepTime => $_getIZ(8);
  @$pb.TagNumber(9)
  set stepTime($core.int v) { $_setUnsignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasStepTime() => $_has(8);
  @$pb.TagNumber(9)
  void clearStepTime() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get relativePower => $_getIZ(9);
  @$pb.TagNumber(10)
  set relativePower($core.int v) { $_setUnsignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasRelativePower() => $_has(9);
  @$pb.TagNumber(10)
  void clearRelativePower() => clearField(10);

  @$pb.TagNumber(11)
  $core.int get totalEnergy => $_getIZ(10);
  @$pb.TagNumber(11)
  set totalEnergy($core.int v) { $_setUnsignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasTotalEnergy() => $_has(10);
  @$pb.TagNumber(11)
  void clearTotalEnergy() => clearField(11);

  @$pb.TagNumber(12)
  $core.int get dailyEnergy => $_getIZ(11);
  @$pb.TagNumber(12)
  set dailyEnergy($core.int v) { $_setUnsignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasDailyEnergy() => $_has(11);
  @$pb.TagNumber(12)
  void clearDailyEnergy() => clearField(12);

  @$pb.TagNumber(13)
  $core.List<$core.int> get powerArray => $_getList(12);

  @$pb.TagNumber(14)
  $core.int get warningNumber => $_getIZ(13);
  @$pb.TagNumber(14)
  set warningNumber($core.int v) { $_setUnsignedInt32(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasWarningNumber() => $_has(13);
  @$pb.TagNumber(14)
  void clearWarningNumber() => clearField(14);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
