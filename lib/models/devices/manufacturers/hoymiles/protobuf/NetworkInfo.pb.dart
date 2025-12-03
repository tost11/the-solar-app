//
//  Generated code. Do not modify.
//  source: NetworkInfo.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class NetworkInfoReqDTO extends $pb.GeneratedMessage {
  factory NetworkInfoReqDTO({
    $core.String? dtuSn,
    $core.int? time,
    $core.int? netSetMod,
    $core.int? netSetTime,
    $core.int? netSetState,
    $core.int? netWorkMod,
    $core.int? netWorkTime,
    $core.int? csq,
    $core.int? netWorkState,
    $core.int? apSetState,
  }) {
    final $result = create();
    if (dtuSn != null) {
      $result.dtuSn = dtuSn;
    }
    if (time != null) {
      $result.time = time;
    }
    if (netSetMod != null) {
      $result.netSetMod = netSetMod;
    }
    if (netSetTime != null) {
      $result.netSetTime = netSetTime;
    }
    if (netSetState != null) {
      $result.netSetState = netSetState;
    }
    if (netWorkMod != null) {
      $result.netWorkMod = netWorkMod;
    }
    if (netWorkTime != null) {
      $result.netWorkTime = netWorkTime;
    }
    if (csq != null) {
      $result.csq = csq;
    }
    if (netWorkState != null) {
      $result.netWorkState = netWorkState;
    }
    if (apSetState != null) {
      $result.apSetState = apSetState;
    }
    return $result;
  }
  NetworkInfoReqDTO._() : super();
  factory NetworkInfoReqDTO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NetworkInfoReqDTO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NetworkInfoReqDTO', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'dtuSn')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'time', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'netSetMod', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'netSetTime', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'netSetState', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'netWorkMod', $pb.PbFieldType.O3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'netWorkTime', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'csq', $pb.PbFieldType.O3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'netWorkState', $pb.PbFieldType.O3)
    ..a<$core.int>(10, _omitFieldNames ? '' : 'apSetState', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NetworkInfoReqDTO clone() => NetworkInfoReqDTO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NetworkInfoReqDTO copyWith(void Function(NetworkInfoReqDTO) updates) => super.copyWith((message) => updates(message as NetworkInfoReqDTO)) as NetworkInfoReqDTO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NetworkInfoReqDTO create() => NetworkInfoReqDTO._();
  NetworkInfoReqDTO createEmptyInstance() => create();
  static $pb.PbList<NetworkInfoReqDTO> createRepeated() => $pb.PbList<NetworkInfoReqDTO>();
  @$core.pragma('dart2js:noInline')
  static NetworkInfoReqDTO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NetworkInfoReqDTO>(create);
  static NetworkInfoReqDTO? _defaultInstance;

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
  set time($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearTime() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get netSetMod => $_getIZ(2);
  @$pb.TagNumber(3)
  set netSetMod($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNetSetMod() => $_has(2);
  @$pb.TagNumber(3)
  void clearNetSetMod() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get netSetTime => $_getIZ(3);
  @$pb.TagNumber(4)
  set netSetTime($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasNetSetTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearNetSetTime() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get netSetState => $_getIZ(4);
  @$pb.TagNumber(5)
  set netSetState($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasNetSetState() => $_has(4);
  @$pb.TagNumber(5)
  void clearNetSetState() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get netWorkMod => $_getIZ(5);
  @$pb.TagNumber(6)
  set netWorkMod($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasNetWorkMod() => $_has(5);
  @$pb.TagNumber(6)
  void clearNetWorkMod() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get netWorkTime => $_getIZ(6);
  @$pb.TagNumber(7)
  set netWorkTime($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasNetWorkTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearNetWorkTime() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get csq => $_getIZ(7);
  @$pb.TagNumber(8)
  set csq($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasCsq() => $_has(7);
  @$pb.TagNumber(8)
  void clearCsq() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get netWorkState => $_getIZ(8);
  @$pb.TagNumber(9)
  set netWorkState($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasNetWorkState() => $_has(8);
  @$pb.TagNumber(9)
  void clearNetWorkState() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get apSetState => $_getIZ(9);
  @$pb.TagNumber(10)
  set apSetState($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasApSetState() => $_has(9);
  @$pb.TagNumber(10)
  void clearApSetState() => clearField(10);
}

class NetworkInfoResDTO extends $pb.GeneratedMessage {
  factory NetworkInfoResDTO({
    $core.int? offset,
    $core.int? time,
  }) {
    final $result = create();
    if (offset != null) {
      $result.offset = offset;
    }
    if (time != null) {
      $result.time = time;
    }
    return $result;
  }
  NetworkInfoResDTO._() : super();
  factory NetworkInfoResDTO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NetworkInfoResDTO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NetworkInfoResDTO', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'time', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NetworkInfoResDTO clone() => NetworkInfoResDTO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NetworkInfoResDTO copyWith(void Function(NetworkInfoResDTO) updates) => super.copyWith((message) => updates(message as NetworkInfoResDTO)) as NetworkInfoResDTO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NetworkInfoResDTO create() => NetworkInfoResDTO._();
  NetworkInfoResDTO createEmptyInstance() => create();
  static $pb.PbList<NetworkInfoResDTO> createRepeated() => $pb.PbList<NetworkInfoResDTO>();
  @$core.pragma('dart2js:noInline')
  static NetworkInfoResDTO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NetworkInfoResDTO>(create);
  static NetworkInfoResDTO? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get offset => $_getIZ(0);
  @$pb.TagNumber(1)
  set offset($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOffset() => $_has(0);
  @$pb.TagNumber(1)
  void clearOffset() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get time => $_getIZ(1);
  @$pb.TagNumber(2)
  set time($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearTime() => clearField(2);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
