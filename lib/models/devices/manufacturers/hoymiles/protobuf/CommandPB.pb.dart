//
//  Generated code. Do not modify.
//  source: CommandPB.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class CommandResDTO extends $pb.GeneratedMessage {
  factory CommandResDTO({
    $core.int? time,
    $core.int? action,
    $core.int? devKind,
    $core.int? packageNub,
    $core.int? packageNow,
    $fixnum.Int64? tid,
    $core.String? data,
    $core.Iterable<$core.String>? esToSn,
    $core.Iterable<$fixnum.Int64>? miToSn,
    $core.int? systemTotalA,
    $core.int? systemTotalB,
    $core.int? systemTotalC,
    $core.Iterable<$fixnum.Int64>? miSnItemA,
    $core.Iterable<$fixnum.Int64>? miSnItemB,
    $core.Iterable<$fixnum.Int64>? miSnItemC,
  }) {
    final $result = create();
    if (time != null) {
      $result.time = time;
    }
    if (action != null) {
      $result.action = action;
    }
    if (devKind != null) {
      $result.devKind = devKind;
    }
    if (packageNub != null) {
      $result.packageNub = packageNub;
    }
    if (packageNow != null) {
      $result.packageNow = packageNow;
    }
    if (tid != null) {
      $result.tid = tid;
    }
    if (data != null) {
      $result.data = data;
    }
    if (esToSn != null) {
      $result.esToSn.addAll(esToSn);
    }
    if (miToSn != null) {
      $result.miToSn.addAll(miToSn);
    }
    if (systemTotalA != null) {
      $result.systemTotalA = systemTotalA;
    }
    if (systemTotalB != null) {
      $result.systemTotalB = systemTotalB;
    }
    if (systemTotalC != null) {
      $result.systemTotalC = systemTotalC;
    }
    if (miSnItemA != null) {
      $result.miSnItemA.addAll(miSnItemA);
    }
    if (miSnItemB != null) {
      $result.miSnItemB.addAll(miSnItemB);
    }
    if (miSnItemC != null) {
      $result.miSnItemC.addAll(miSnItemC);
    }
    return $result;
  }
  CommandResDTO._() : super();
  factory CommandResDTO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CommandResDTO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CommandResDTO', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'time', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'action', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'devKind', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'packageNub', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'packageNow', $pb.PbFieldType.O3)
    ..aInt64(6, _omitFieldNames ? '' : 'tid')
    ..aOS(7, _omitFieldNames ? '' : 'data')
    ..pPS(8, _omitFieldNames ? '' : 'esToSn')
    ..p<$fixnum.Int64>(9, _omitFieldNames ? '' : 'miToSn', $pb.PbFieldType.K6)
    ..a<$core.int>(10, _omitFieldNames ? '' : 'systemTotalA', $pb.PbFieldType.O3)
    ..a<$core.int>(11, _omitFieldNames ? '' : 'systemTotalB', $pb.PbFieldType.O3)
    ..a<$core.int>(12, _omitFieldNames ? '' : 'systemTotalC', $pb.PbFieldType.O3)
    ..p<$fixnum.Int64>(13, _omitFieldNames ? '' : 'miSnItemA', $pb.PbFieldType.K6)
    ..p<$fixnum.Int64>(14, _omitFieldNames ? '' : 'miSnItemB', $pb.PbFieldType.K6)
    ..p<$fixnum.Int64>(15, _omitFieldNames ? '' : 'miSnItemC', $pb.PbFieldType.K6)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CommandResDTO clone() => CommandResDTO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CommandResDTO copyWith(void Function(CommandResDTO) updates) => super.copyWith((message) => updates(message as CommandResDTO)) as CommandResDTO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommandResDTO create() => CommandResDTO._();
  CommandResDTO createEmptyInstance() => create();
  static $pb.PbList<CommandResDTO> createRepeated() => $pb.PbList<CommandResDTO>();
  @$core.pragma('dart2js:noInline')
  static CommandResDTO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommandResDTO>(create);
  static CommandResDTO? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get time => $_getIZ(0);
  @$pb.TagNumber(1)
  set time($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearTime() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get action => $_getIZ(1);
  @$pb.TagNumber(2)
  set action($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAction() => $_has(1);
  @$pb.TagNumber(2)
  void clearAction() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get devKind => $_getIZ(2);
  @$pb.TagNumber(3)
  set devKind($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDevKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearDevKind() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get packageNub => $_getIZ(3);
  @$pb.TagNumber(4)
  set packageNub($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPackageNub() => $_has(3);
  @$pb.TagNumber(4)
  void clearPackageNub() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get packageNow => $_getIZ(4);
  @$pb.TagNumber(5)
  set packageNow($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPackageNow() => $_has(4);
  @$pb.TagNumber(5)
  void clearPackageNow() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get tid => $_getI64(5);
  @$pb.TagNumber(6)
  set tid($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTid() => $_has(5);
  @$pb.TagNumber(6)
  void clearTid() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get data => $_getSZ(6);
  @$pb.TagNumber(7)
  set data($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasData() => $_has(6);
  @$pb.TagNumber(7)
  void clearData() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.String> get esToSn => $_getList(7);

  @$pb.TagNumber(9)
  $core.List<$fixnum.Int64> get miToSn => $_getList(8);

  @$pb.TagNumber(10)
  $core.int get systemTotalA => $_getIZ(9);
  @$pb.TagNumber(10)
  set systemTotalA($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasSystemTotalA() => $_has(9);
  @$pb.TagNumber(10)
  void clearSystemTotalA() => clearField(10);

  @$pb.TagNumber(11)
  $core.int get systemTotalB => $_getIZ(10);
  @$pb.TagNumber(11)
  set systemTotalB($core.int v) { $_setSignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasSystemTotalB() => $_has(10);
  @$pb.TagNumber(11)
  void clearSystemTotalB() => clearField(11);

  @$pb.TagNumber(12)
  $core.int get systemTotalC => $_getIZ(11);
  @$pb.TagNumber(12)
  set systemTotalC($core.int v) { $_setSignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasSystemTotalC() => $_has(11);
  @$pb.TagNumber(12)
  void clearSystemTotalC() => clearField(12);

  @$pb.TagNumber(13)
  $core.List<$fixnum.Int64> get miSnItemA => $_getList(12);

  @$pb.TagNumber(14)
  $core.List<$fixnum.Int64> get miSnItemB => $_getList(13);

  @$pb.TagNumber(15)
  $core.List<$fixnum.Int64> get miSnItemC => $_getList(14);
}

class CommandReqDTO extends $pb.GeneratedMessage {
  factory CommandReqDTO({
    $core.String? dtuSn,
    $core.int? time,
    $core.int? action,
    $core.int? packageNow,
    $core.int? errCode,
    $fixnum.Int64? tid,
  }) {
    final $result = create();
    if (dtuSn != null) {
      $result.dtuSn = dtuSn;
    }
    if (time != null) {
      $result.time = time;
    }
    if (action != null) {
      $result.action = action;
    }
    if (packageNow != null) {
      $result.packageNow = packageNow;
    }
    if (errCode != null) {
      $result.errCode = errCode;
    }
    if (tid != null) {
      $result.tid = tid;
    }
    return $result;
  }
  CommandReqDTO._() : super();
  factory CommandReqDTO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CommandReqDTO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CommandReqDTO', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'dtuSn')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'time', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'action', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'packageNow', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'errCode', $pb.PbFieldType.O3)
    ..aInt64(6, _omitFieldNames ? '' : 'tid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CommandReqDTO clone() => CommandReqDTO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CommandReqDTO copyWith(void Function(CommandReqDTO) updates) => super.copyWith((message) => updates(message as CommandReqDTO)) as CommandReqDTO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommandReqDTO create() => CommandReqDTO._();
  CommandReqDTO createEmptyInstance() => create();
  static $pb.PbList<CommandReqDTO> createRepeated() => $pb.PbList<CommandReqDTO>();
  @$core.pragma('dart2js:noInline')
  static CommandReqDTO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommandReqDTO>(create);
  static CommandReqDTO? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dtuSn => $_getSZ(0);
  @$pb.TagNumber(1)
  set dtuSn($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDtuSn() => $_has(0);
  @$pb.TagNumber(1)
  void clearDtuSn() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get time => $_getIZ(1);
  @$pb.TagNumber(2)
  set time($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearTime() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get action => $_getIZ(2);
  @$pb.TagNumber(3)
  set action($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAction() => $_has(2);
  @$pb.TagNumber(3)
  void clearAction() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get packageNow => $_getIZ(3);
  @$pb.TagNumber(4)
  set packageNow($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPackageNow() => $_has(3);
  @$pb.TagNumber(4)
  void clearPackageNow() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get errCode => $_getIZ(4);
  @$pb.TagNumber(5)
  set errCode($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasErrCode() => $_has(4);
  @$pb.TagNumber(5)
  void clearErrCode() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get tid => $_getI64(5);
  @$pb.TagNumber(6)
  set tid($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTid() => $_has(5);
  @$pb.TagNumber(6)
  void clearTid() => clearField(6);
}

class ESOperatingStatusMO extends $pb.GeneratedMessage {
  factory ESOperatingStatusMO({
    $core.String? esSn,
    $core.int? progressRate,
  }) {
    final $result = create();
    if (esSn != null) {
      $result.esSn = esSn;
    }
    if (progressRate != null) {
      $result.progressRate = progressRate;
    }
    return $result;
  }
  ESOperatingStatusMO._() : super();
  factory ESOperatingStatusMO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ESOperatingStatusMO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ESOperatingStatusMO', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'esSn')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'progressRate', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ESOperatingStatusMO clone() => ESOperatingStatusMO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ESOperatingStatusMO copyWith(void Function(ESOperatingStatusMO) updates) => super.copyWith((message) => updates(message as ESOperatingStatusMO)) as ESOperatingStatusMO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ESOperatingStatusMO create() => ESOperatingStatusMO._();
  ESOperatingStatusMO createEmptyInstance() => create();
  static $pb.PbList<ESOperatingStatusMO> createRepeated() => $pb.PbList<ESOperatingStatusMO>();
  @$core.pragma('dart2js:noInline')
  static ESOperatingStatusMO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ESOperatingStatusMO>(create);
  static ESOperatingStatusMO? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get esSn => $_getSZ(0);
  @$pb.TagNumber(1)
  set esSn($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEsSn() => $_has(0);
  @$pb.TagNumber(1)
  void clearEsSn() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get progressRate => $_getIZ(1);
  @$pb.TagNumber(2)
  set progressRate($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProgressRate() => $_has(1);
  @$pb.TagNumber(2)
  void clearProgressRate() => clearField(2);
}

class MIOperatingStatusMO extends $pb.GeneratedMessage {
  factory MIOperatingStatusMO({
    $fixnum.Int64? miSn,
    $core.int? progressRate,
  }) {
    final $result = create();
    if (miSn != null) {
      $result.miSn = miSn;
    }
    if (progressRate != null) {
      $result.progressRate = progressRate;
    }
    return $result;
  }
  MIOperatingStatusMO._() : super();
  factory MIOperatingStatusMO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MIOperatingStatusMO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MIOperatingStatusMO', createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'miSn')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'progressRate', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MIOperatingStatusMO clone() => MIOperatingStatusMO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MIOperatingStatusMO copyWith(void Function(MIOperatingStatusMO) updates) => super.copyWith((message) => updates(message as MIOperatingStatusMO)) as MIOperatingStatusMO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MIOperatingStatusMO create() => MIOperatingStatusMO._();
  MIOperatingStatusMO createEmptyInstance() => create();
  static $pb.PbList<MIOperatingStatusMO> createRepeated() => $pb.PbList<MIOperatingStatusMO>();
  @$core.pragma('dart2js:noInline')
  static MIOperatingStatusMO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MIOperatingStatusMO>(create);
  static MIOperatingStatusMO? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get miSn => $_getI64(0);
  @$pb.TagNumber(1)
  set miSn($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMiSn() => $_has(0);
  @$pb.TagNumber(1)
  void clearMiSn() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get progressRate => $_getIZ(1);
  @$pb.TagNumber(2)
  set progressRate($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProgressRate() => $_has(1);
  @$pb.TagNumber(2)
  void clearProgressRate() => clearField(2);
}

class MIErrorStatusMO extends $pb.GeneratedMessage {
  factory MIErrorStatusMO({
    $fixnum.Int64? miSn,
    $fixnum.Int64? errorCode,
  }) {
    final $result = create();
    if (miSn != null) {
      $result.miSn = miSn;
    }
    if (errorCode != null) {
      $result.errorCode = errorCode;
    }
    return $result;
  }
  MIErrorStatusMO._() : super();
  factory MIErrorStatusMO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MIErrorStatusMO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MIErrorStatusMO', createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'miSn')
    ..aInt64(2, _omitFieldNames ? '' : 'errorCode')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MIErrorStatusMO clone() => MIErrorStatusMO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MIErrorStatusMO copyWith(void Function(MIErrorStatusMO) updates) => super.copyWith((message) => updates(message as MIErrorStatusMO)) as MIErrorStatusMO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MIErrorStatusMO create() => MIErrorStatusMO._();
  MIErrorStatusMO createEmptyInstance() => create();
  static $pb.PbList<MIErrorStatusMO> createRepeated() => $pb.PbList<MIErrorStatusMO>();
  @$core.pragma('dart2js:noInline')
  static MIErrorStatusMO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MIErrorStatusMO>(create);
  static MIErrorStatusMO? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get miSn => $_getI64(0);
  @$pb.TagNumber(1)
  set miSn($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMiSn() => $_has(0);
  @$pb.TagNumber(1)
  void clearMiSn() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get errorCode => $_getI64(1);
  @$pb.TagNumber(2)
  set errorCode($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasErrorCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorCode() => clearField(2);
}

class ESSucStatusMO extends $pb.GeneratedMessage {
  factory ESSucStatusMO({
    $core.String? esSn,
  }) {
    final $result = create();
    if (esSn != null) {
      $result.esSn = esSn;
    }
    return $result;
  }
  ESSucStatusMO._() : super();
  factory ESSucStatusMO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ESSucStatusMO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ESSucStatusMO', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'esSn')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ESSucStatusMO clone() => ESSucStatusMO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ESSucStatusMO copyWith(void Function(ESSucStatusMO) updates) => super.copyWith((message) => updates(message as ESSucStatusMO)) as ESSucStatusMO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ESSucStatusMO create() => ESSucStatusMO._();
  ESSucStatusMO createEmptyInstance() => create();
  static $pb.PbList<ESSucStatusMO> createRepeated() => $pb.PbList<ESSucStatusMO>();
  @$core.pragma('dart2js:noInline')
  static ESSucStatusMO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ESSucStatusMO>(create);
  static ESSucStatusMO? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get esSn => $_getSZ(0);
  @$pb.TagNumber(1)
  set esSn($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEsSn() => $_has(0);
  @$pb.TagNumber(1)
  void clearEsSn() => clearField(1);
}

class ESErrorStatusMO extends $pb.GeneratedMessage {
  factory ESErrorStatusMO({
    $core.String? esSn,
    $fixnum.Int64? errorCode,
  }) {
    final $result = create();
    if (esSn != null) {
      $result.esSn = esSn;
    }
    if (errorCode != null) {
      $result.errorCode = errorCode;
    }
    return $result;
  }
  ESErrorStatusMO._() : super();
  factory ESErrorStatusMO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ESErrorStatusMO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ESErrorStatusMO', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'esSn')
    ..aInt64(2, _omitFieldNames ? '' : 'errorCode')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ESErrorStatusMO clone() => ESErrorStatusMO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ESErrorStatusMO copyWith(void Function(ESErrorStatusMO) updates) => super.copyWith((message) => updates(message as ESErrorStatusMO)) as ESErrorStatusMO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ESErrorStatusMO create() => ESErrorStatusMO._();
  ESErrorStatusMO createEmptyInstance() => create();
  static $pb.PbList<ESErrorStatusMO> createRepeated() => $pb.PbList<ESErrorStatusMO>();
  @$core.pragma('dart2js:noInline')
  static ESErrorStatusMO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ESErrorStatusMO>(create);
  static ESErrorStatusMO? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get esSn => $_getSZ(0);
  @$pb.TagNumber(1)
  set esSn($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEsSn() => $_has(0);
  @$pb.TagNumber(1)
  void clearEsSn() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get errorCode => $_getI64(1);
  @$pb.TagNumber(2)
  set errorCode($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasErrorCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorCode() => clearField(2);
}

class CommandStatusReqDTO extends $pb.GeneratedMessage {
  factory CommandStatusReqDTO({
    $core.String? dtuSn,
    $core.int? time,
    $core.int? action,
    $core.int? packageNub,
    $core.int? packageNow,
    $fixnum.Int64? tid,
    $core.Iterable<$core.String>? esSnsSucs,
    $core.Iterable<$fixnum.Int64>? miSnsSucs,
    $core.Iterable<$core.String>? esSnsFailds,
    $core.Iterable<$fixnum.Int64>? miSnsFailds,
    $core.Iterable<ESOperatingStatusMO>? esMOperatingStatus,
    $core.Iterable<MIOperatingStatusMO>? miMOperatingStatus,
    $core.Iterable<MIErrorStatusMO>? miMErrorStatus,
    $core.Iterable<ESSucStatusMO>? esMSucStatus,
    $core.Iterable<ESErrorStatusMO>? esMErrorStatus,
  }) {
    final $result = create();
    if (dtuSn != null) {
      $result.dtuSn = dtuSn;
    }
    if (time != null) {
      $result.time = time;
    }
    if (action != null) {
      $result.action = action;
    }
    if (packageNub != null) {
      $result.packageNub = packageNub;
    }
    if (packageNow != null) {
      $result.packageNow = packageNow;
    }
    if (tid != null) {
      $result.tid = tid;
    }
    if (esSnsSucs != null) {
      $result.esSnsSucs.addAll(esSnsSucs);
    }
    if (miSnsSucs != null) {
      $result.miSnsSucs.addAll(miSnsSucs);
    }
    if (esSnsFailds != null) {
      $result.esSnsFailds.addAll(esSnsFailds);
    }
    if (miSnsFailds != null) {
      $result.miSnsFailds.addAll(miSnsFailds);
    }
    if (esMOperatingStatus != null) {
      $result.esMOperatingStatus.addAll(esMOperatingStatus);
    }
    if (miMOperatingStatus != null) {
      $result.miMOperatingStatus.addAll(miMOperatingStatus);
    }
    if (miMErrorStatus != null) {
      $result.miMErrorStatus.addAll(miMErrorStatus);
    }
    if (esMSucStatus != null) {
      $result.esMSucStatus.addAll(esMSucStatus);
    }
    if (esMErrorStatus != null) {
      $result.esMErrorStatus.addAll(esMErrorStatus);
    }
    return $result;
  }
  CommandStatusReqDTO._() : super();
  factory CommandStatusReqDTO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CommandStatusReqDTO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CommandStatusReqDTO', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'dtuSn')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'time', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'action', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'packageNub', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'packageNow', $pb.PbFieldType.O3)
    ..aInt64(6, _omitFieldNames ? '' : 'tid')
    ..pPS(7, _omitFieldNames ? '' : 'esSnsSucs')
    ..p<$fixnum.Int64>(8, _omitFieldNames ? '' : 'miSnsSucs', $pb.PbFieldType.K6)
    ..pPS(9, _omitFieldNames ? '' : 'esSnsFailds')
    ..p<$fixnum.Int64>(10, _omitFieldNames ? '' : 'miSnsFailds', $pb.PbFieldType.K6)
    ..pc<ESOperatingStatusMO>(11, _omitFieldNames ? '' : 'esMOperatingStatus', $pb.PbFieldType.PM, protoName: 'es_mOperatingStatus', subBuilder: ESOperatingStatusMO.create)
    ..pc<MIOperatingStatusMO>(12, _omitFieldNames ? '' : 'miMOperatingStatus', $pb.PbFieldType.PM, protoName: 'mi_mOperatingStatus', subBuilder: MIOperatingStatusMO.create)
    ..pc<MIErrorStatusMO>(13, _omitFieldNames ? '' : 'miMErrorStatus', $pb.PbFieldType.PM, protoName: 'mi_mErrorStatus', subBuilder: MIErrorStatusMO.create)
    ..pc<ESSucStatusMO>(14, _omitFieldNames ? '' : 'esMSucStatus', $pb.PbFieldType.PM, protoName: 'es_mSucStatus', subBuilder: ESSucStatusMO.create)
    ..pc<ESErrorStatusMO>(15, _omitFieldNames ? '' : 'esMErrorStatus', $pb.PbFieldType.PM, protoName: 'es_mErrorStatus', subBuilder: ESErrorStatusMO.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CommandStatusReqDTO clone() => CommandStatusReqDTO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CommandStatusReqDTO copyWith(void Function(CommandStatusReqDTO) updates) => super.copyWith((message) => updates(message as CommandStatusReqDTO)) as CommandStatusReqDTO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommandStatusReqDTO create() => CommandStatusReqDTO._();
  CommandStatusReqDTO createEmptyInstance() => create();
  static $pb.PbList<CommandStatusReqDTO> createRepeated() => $pb.PbList<CommandStatusReqDTO>();
  @$core.pragma('dart2js:noInline')
  static CommandStatusReqDTO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommandStatusReqDTO>(create);
  static CommandStatusReqDTO? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dtuSn => $_getSZ(0);
  @$pb.TagNumber(1)
  set dtuSn($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDtuSn() => $_has(0);
  @$pb.TagNumber(1)
  void clearDtuSn() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get time => $_getIZ(1);
  @$pb.TagNumber(2)
  set time($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearTime() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get action => $_getIZ(2);
  @$pb.TagNumber(3)
  set action($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAction() => $_has(2);
  @$pb.TagNumber(3)
  void clearAction() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get packageNub => $_getIZ(3);
  @$pb.TagNumber(4)
  set packageNub($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPackageNub() => $_has(3);
  @$pb.TagNumber(4)
  void clearPackageNub() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get packageNow => $_getIZ(4);
  @$pb.TagNumber(5)
  set packageNow($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPackageNow() => $_has(4);
  @$pb.TagNumber(5)
  void clearPackageNow() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get tid => $_getI64(5);
  @$pb.TagNumber(6)
  set tid($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTid() => $_has(5);
  @$pb.TagNumber(6)
  void clearTid() => clearField(6);

  @$pb.TagNumber(7)
  $core.List<$core.String> get esSnsSucs => $_getList(6);

  @$pb.TagNumber(8)
  $core.List<$fixnum.Int64> get miSnsSucs => $_getList(7);

  @$pb.TagNumber(9)
  $core.List<$core.String> get esSnsFailds => $_getList(8);

  @$pb.TagNumber(10)
  $core.List<$fixnum.Int64> get miSnsFailds => $_getList(9);

  @$pb.TagNumber(11)
  $core.List<ESOperatingStatusMO> get esMOperatingStatus => $_getList(10);

  @$pb.TagNumber(12)
  $core.List<MIOperatingStatusMO> get miMOperatingStatus => $_getList(11);

  @$pb.TagNumber(13)
  $core.List<MIErrorStatusMO> get miMErrorStatus => $_getList(12);

  @$pb.TagNumber(14)
  $core.List<ESSucStatusMO> get esMSucStatus => $_getList(13);

  @$pb.TagNumber(15)
  $core.List<ESErrorStatusMO> get esMErrorStatus => $_getList(14);
}

class CommandStatusResDTO extends $pb.GeneratedMessage {
  factory CommandStatusResDTO({
    $core.int? time,
    $core.int? action,
    $core.int? packageNow,
    $fixnum.Int64? tid,
    $core.int? errCode,
  }) {
    final $result = create();
    if (time != null) {
      $result.time = time;
    }
    if (action != null) {
      $result.action = action;
    }
    if (packageNow != null) {
      $result.packageNow = packageNow;
    }
    if (tid != null) {
      $result.tid = tid;
    }
    if (errCode != null) {
      $result.errCode = errCode;
    }
    return $result;
  }
  CommandStatusResDTO._() : super();
  factory CommandStatusResDTO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CommandStatusResDTO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CommandStatusResDTO', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'time', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'action', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'packageNow', $pb.PbFieldType.O3)
    ..aInt64(4, _omitFieldNames ? '' : 'tid')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'errCode', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CommandStatusResDTO clone() => CommandStatusResDTO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CommandStatusResDTO copyWith(void Function(CommandStatusResDTO) updates) => super.copyWith((message) => updates(message as CommandStatusResDTO)) as CommandStatusResDTO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommandStatusResDTO create() => CommandStatusResDTO._();
  CommandStatusResDTO createEmptyInstance() => create();
  static $pb.PbList<CommandStatusResDTO> createRepeated() => $pb.PbList<CommandStatusResDTO>();
  @$core.pragma('dart2js:noInline')
  static CommandStatusResDTO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommandStatusResDTO>(create);
  static CommandStatusResDTO? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get time => $_getIZ(0);
  @$pb.TagNumber(1)
  set time($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearTime() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get action => $_getIZ(1);
  @$pb.TagNumber(2)
  set action($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAction() => $_has(1);
  @$pb.TagNumber(2)
  void clearAction() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get packageNow => $_getIZ(2);
  @$pb.TagNumber(3)
  set packageNow($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPackageNow() => $_has(2);
  @$pb.TagNumber(3)
  void clearPackageNow() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get tid => $_getI64(3);
  @$pb.TagNumber(4)
  set tid($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTid() => $_has(3);
  @$pb.TagNumber(4)
  void clearTid() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get errCode => $_getIZ(4);
  @$pb.TagNumber(5)
  set errCode($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasErrCode() => $_has(4);
  @$pb.TagNumber(5)
  void clearErrCode() => clearField(5);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
