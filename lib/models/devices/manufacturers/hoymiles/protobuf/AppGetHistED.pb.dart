//
//  Generated code. Do not modify.
//  source: AppGetHistED.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class AppGetHistEDResDTO extends $pb.GeneratedMessage {
  factory AppGetHistEDResDTO({
    $core.int? cp,
    $core.int? oft,
    $core.int? time,
  }) {
    final $result = create();
    if (cp != null) {
      $result.cp = cp;
    }
    if (oft != null) {
      $result.oft = oft;
    }
    if (time != null) {
      $result.time = time;
    }
    return $result;
  }
  AppGetHistEDResDTO._() : super();
  factory AppGetHistEDResDTO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AppGetHistEDResDTO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AppGetHistEDResDTO', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'cp', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'oft', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'time', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AppGetHistEDResDTO clone() => AppGetHistEDResDTO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AppGetHistEDResDTO copyWith(void Function(AppGetHistEDResDTO) updates) => super.copyWith((message) => updates(message as AppGetHistEDResDTO)) as AppGetHistEDResDTO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AppGetHistEDResDTO create() => AppGetHistEDResDTO._();
  AppGetHistEDResDTO createEmptyInstance() => create();
  static $pb.PbList<AppGetHistEDResDTO> createRepeated() => $pb.PbList<AppGetHistEDResDTO>();
  @$core.pragma('dart2js:noInline')
  static AppGetHistEDResDTO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AppGetHistEDResDTO>(create);
  static AppGetHistEDResDTO? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get cp => $_getIZ(0);
  @$pb.TagNumber(1)
  set cp($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCp() => $_has(0);
  @$pb.TagNumber(1)
  void clearCp() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get oft => $_getIZ(1);
  @$pb.TagNumber(2)
  set oft($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOft() => $_has(1);
  @$pb.TagNumber(2)
  void clearOft() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get time => $_getIZ(2);
  @$pb.TagNumber(3)
  set time($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearTime() => clearField(3);
}

class APPEnergyInfoMO extends $pb.GeneratedMessage {
  factory APPEnergyInfoMO({
    $core.int? ed,
    $core.int? rTime,
  }) {
    final $result = create();
    if (ed != null) {
      $result.ed = ed;
    }
    if (rTime != null) {
      $result.rTime = rTime;
    }
    return $result;
  }
  APPEnergyInfoMO._() : super();
  factory APPEnergyInfoMO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory APPEnergyInfoMO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'APPEnergyInfoMO', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'ed', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'rTime', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  APPEnergyInfoMO clone() => APPEnergyInfoMO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  APPEnergyInfoMO copyWith(void Function(APPEnergyInfoMO) updates) => super.copyWith((message) => updates(message as APPEnergyInfoMO)) as APPEnergyInfoMO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static APPEnergyInfoMO create() => APPEnergyInfoMO._();
  APPEnergyInfoMO createEmptyInstance() => create();
  static $pb.PbList<APPEnergyInfoMO> createRepeated() => $pb.PbList<APPEnergyInfoMO>();
  @$core.pragma('dart2js:noInline')
  static APPEnergyInfoMO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<APPEnergyInfoMO>(create);
  static APPEnergyInfoMO? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get ed => $_getIZ(0);
  @$pb.TagNumber(1)
  set ed($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEd() => $_has(0);
  @$pb.TagNumber(1)
  void clearEd() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get rTime => $_getIZ(1);
  @$pb.TagNumber(2)
  set rTime($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearRTime() => clearField(2);
}

class AppGetHistEDReqDTO extends $pb.GeneratedMessage {
  factory AppGetHistEDReqDTO({
    $fixnum.Int64? sn,
    $core.int? oft,
    $core.int? time,
    $core.Iterable<APPEnergyInfoMO>? energ,
  }) {
    final $result = create();
    if (sn != null) {
      $result.sn = sn;
    }
    if (oft != null) {
      $result.oft = oft;
    }
    if (time != null) {
      $result.time = time;
    }
    if (energ != null) {
      $result.energ.addAll(energ);
    }
    return $result;
  }
  AppGetHistEDReqDTO._() : super();
  factory AppGetHistEDReqDTO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AppGetHistEDReqDTO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AppGetHistEDReqDTO', createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'sn')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'oft', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'time', $pb.PbFieldType.OU3)
    ..pc<APPEnergyInfoMO>(4, _omitFieldNames ? '' : 'energ', $pb.PbFieldType.PM, subBuilder: APPEnergyInfoMO.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AppGetHistEDReqDTO clone() => AppGetHistEDReqDTO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AppGetHistEDReqDTO copyWith(void Function(AppGetHistEDReqDTO) updates) => super.copyWith((message) => updates(message as AppGetHistEDReqDTO)) as AppGetHistEDReqDTO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AppGetHistEDReqDTO create() => AppGetHistEDReqDTO._();
  AppGetHistEDReqDTO createEmptyInstance() => create();
  static $pb.PbList<AppGetHistEDReqDTO> createRepeated() => $pb.PbList<AppGetHistEDReqDTO>();
  @$core.pragma('dart2js:noInline')
  static AppGetHistEDReqDTO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AppGetHistEDReqDTO>(create);
  static AppGetHistEDReqDTO? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get sn => $_getI64(0);
  @$pb.TagNumber(1)
  set sn($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSn() => $_has(0);
  @$pb.TagNumber(1)
  void clearSn() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get oft => $_getIZ(1);
  @$pb.TagNumber(2)
  set oft($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOft() => $_has(1);
  @$pb.TagNumber(2)
  void clearOft() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get time => $_getIZ(2);
  @$pb.TagNumber(3)
  set time($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearTime() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<APPEnergyInfoMO> get energ => $_getList(3);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
