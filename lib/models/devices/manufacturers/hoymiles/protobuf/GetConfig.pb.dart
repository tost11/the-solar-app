//
//  Generated code. Do not modify.
//  source: GetConfig.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class GetConfigResDTO extends $pb.GeneratedMessage {
  factory GetConfigResDTO({
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
  GetConfigResDTO._() : super();
  factory GetConfigResDTO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetConfigResDTO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetConfigResDTO', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'time', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetConfigResDTO clone() => GetConfigResDTO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetConfigResDTO copyWith(void Function(GetConfigResDTO) updates) => super.copyWith((message) => updates(message as GetConfigResDTO)) as GetConfigResDTO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetConfigResDTO create() => GetConfigResDTO._();
  GetConfigResDTO createEmptyInstance() => create();
  static $pb.PbList<GetConfigResDTO> createRepeated() => $pb.PbList<GetConfigResDTO>();
  @$core.pragma('dart2js:noInline')
  static GetConfigResDTO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetConfigResDTO>(create);
  static GetConfigResDTO? _defaultInstance;

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

class GetConfigReqDTO extends $pb.GeneratedMessage {
  factory GetConfigReqDTO({
    $core.int? requestOffset,
    $core.int? requestTime,
    $core.int? lockPassword,
    $core.int? lockTime,
    $core.int? limitPowerMypower,
    $core.int? zeroExport433Addr,
    $core.int? zeroExportEnable,
    $core.int? netmodeSelect,
    $core.int? channelSelect,
    $core.int? serverSendTime,
    $core.int? wifiRssi,
    $core.int? serverport,
    $core.String? apnSet,
    $core.String? meterKind,
    $core.String? meterInterface,
    $core.String? wifiSsid,
    $core.String? wifiPassword,
    $core.String? serverDomainName,
    $core.int? invType,
    $core.String? dtuSn,
    $core.int? accessModel,
    $core.int? mac0,
    $core.int? mac1,
    $core.int? mac2,
    $core.int? mac3,
    $core.int? dhcpSwitch,
    $core.int? ipAddr0,
    $core.int? ipAddr1,
    $core.int? ipAddr2,
    $core.int? ipAddr3,
    $core.int? subnetMask0,
    $core.int? subnetMask1,
    $core.int? subnetMask2,
    $core.int? subnetMask3,
    $core.int? defaultGateway0,
    $core.int? defaultGateway1,
    $core.int? defaultGateway2,
    $core.int? defaultGateway3,
    $core.String? kaNub,
    $core.String? apnName,
    $core.String? apnPassword,
    $core.int? sub1gSweepSwitch,
    $core.int? sub1gWorkChannel,
    $core.int? cableDns0,
    $core.int? cableDns1,
    $core.int? cableDns2,
    $core.int? cableDns3,
    $core.int? wifiIpAddr0,
    $core.int? wifiIpAddr1,
    $core.int? wifiIpAddr2,
    $core.int? wifiIpAddr3,
    $core.int? mac4,
    $core.int? mac5,
    $core.int? wifiMac0,
    $core.int? wifiMac1,
    $core.int? wifiMac2,
    $core.int? wifiMac3,
    $core.int? wifiMac4,
    $core.int? wifiMac5,
    $core.String? gprsImei,
    $core.String? dtuApSsid,
    $core.String? dtuApPass,
  }) {
    final $result = create();
    if (requestOffset != null) {
      $result.requestOffset = requestOffset;
    }
    if (requestTime != null) {
      $result.requestTime = requestTime;
    }
    if (lockPassword != null) {
      $result.lockPassword = lockPassword;
    }
    if (lockTime != null) {
      $result.lockTime = lockTime;
    }
    if (limitPowerMypower != null) {
      $result.limitPowerMypower = limitPowerMypower;
    }
    if (zeroExport433Addr != null) {
      $result.zeroExport433Addr = zeroExport433Addr;
    }
    if (zeroExportEnable != null) {
      $result.zeroExportEnable = zeroExportEnable;
    }
    if (netmodeSelect != null) {
      $result.netmodeSelect = netmodeSelect;
    }
    if (channelSelect != null) {
      $result.channelSelect = channelSelect;
    }
    if (serverSendTime != null) {
      $result.serverSendTime = serverSendTime;
    }
    if (wifiRssi != null) {
      $result.wifiRssi = wifiRssi;
    }
    if (serverport != null) {
      $result.serverport = serverport;
    }
    if (apnSet != null) {
      $result.apnSet = apnSet;
    }
    if (meterKind != null) {
      $result.meterKind = meterKind;
    }
    if (meterInterface != null) {
      $result.meterInterface = meterInterface;
    }
    if (wifiSsid != null) {
      $result.wifiSsid = wifiSsid;
    }
    if (wifiPassword != null) {
      $result.wifiPassword = wifiPassword;
    }
    if (serverDomainName != null) {
      $result.serverDomainName = serverDomainName;
    }
    if (invType != null) {
      $result.invType = invType;
    }
    if (dtuSn != null) {
      $result.dtuSn = dtuSn;
    }
    if (accessModel != null) {
      $result.accessModel = accessModel;
    }
    if (mac0 != null) {
      $result.mac0 = mac0;
    }
    if (mac1 != null) {
      $result.mac1 = mac1;
    }
    if (mac2 != null) {
      $result.mac2 = mac2;
    }
    if (mac3 != null) {
      $result.mac3 = mac3;
    }
    if (dhcpSwitch != null) {
      $result.dhcpSwitch = dhcpSwitch;
    }
    if (ipAddr0 != null) {
      $result.ipAddr0 = ipAddr0;
    }
    if (ipAddr1 != null) {
      $result.ipAddr1 = ipAddr1;
    }
    if (ipAddr2 != null) {
      $result.ipAddr2 = ipAddr2;
    }
    if (ipAddr3 != null) {
      $result.ipAddr3 = ipAddr3;
    }
    if (subnetMask0 != null) {
      $result.subnetMask0 = subnetMask0;
    }
    if (subnetMask1 != null) {
      $result.subnetMask1 = subnetMask1;
    }
    if (subnetMask2 != null) {
      $result.subnetMask2 = subnetMask2;
    }
    if (subnetMask3 != null) {
      $result.subnetMask3 = subnetMask3;
    }
    if (defaultGateway0 != null) {
      $result.defaultGateway0 = defaultGateway0;
    }
    if (defaultGateway1 != null) {
      $result.defaultGateway1 = defaultGateway1;
    }
    if (defaultGateway2 != null) {
      $result.defaultGateway2 = defaultGateway2;
    }
    if (defaultGateway3 != null) {
      $result.defaultGateway3 = defaultGateway3;
    }
    if (kaNub != null) {
      $result.kaNub = kaNub;
    }
    if (apnName != null) {
      $result.apnName = apnName;
    }
    if (apnPassword != null) {
      $result.apnPassword = apnPassword;
    }
    if (sub1gSweepSwitch != null) {
      $result.sub1gSweepSwitch = sub1gSweepSwitch;
    }
    if (sub1gWorkChannel != null) {
      $result.sub1gWorkChannel = sub1gWorkChannel;
    }
    if (cableDns0 != null) {
      $result.cableDns0 = cableDns0;
    }
    if (cableDns1 != null) {
      $result.cableDns1 = cableDns1;
    }
    if (cableDns2 != null) {
      $result.cableDns2 = cableDns2;
    }
    if (cableDns3 != null) {
      $result.cableDns3 = cableDns3;
    }
    if (wifiIpAddr0 != null) {
      $result.wifiIpAddr0 = wifiIpAddr0;
    }
    if (wifiIpAddr1 != null) {
      $result.wifiIpAddr1 = wifiIpAddr1;
    }
    if (wifiIpAddr2 != null) {
      $result.wifiIpAddr2 = wifiIpAddr2;
    }
    if (wifiIpAddr3 != null) {
      $result.wifiIpAddr3 = wifiIpAddr3;
    }
    if (mac4 != null) {
      $result.mac4 = mac4;
    }
    if (mac5 != null) {
      $result.mac5 = mac5;
    }
    if (wifiMac0 != null) {
      $result.wifiMac0 = wifiMac0;
    }
    if (wifiMac1 != null) {
      $result.wifiMac1 = wifiMac1;
    }
    if (wifiMac2 != null) {
      $result.wifiMac2 = wifiMac2;
    }
    if (wifiMac3 != null) {
      $result.wifiMac3 = wifiMac3;
    }
    if (wifiMac4 != null) {
      $result.wifiMac4 = wifiMac4;
    }
    if (wifiMac5 != null) {
      $result.wifiMac5 = wifiMac5;
    }
    if (gprsImei != null) {
      $result.gprsImei = gprsImei;
    }
    if (dtuApSsid != null) {
      $result.dtuApSsid = dtuApSsid;
    }
    if (dtuApPass != null) {
      $result.dtuApPass = dtuApPass;
    }
    return $result;
  }
  GetConfigReqDTO._() : super();
  factory GetConfigReqDTO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetConfigReqDTO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetConfigReqDTO', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'requestOffset', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'requestTime', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'lockPassword', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'lockTime', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'limitPowerMypower', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'zeroExport433Addr', $pb.PbFieldType.O3, protoName: 'zero_export_433_addr')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'zeroExportEnable', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'netmodeSelect', $pb.PbFieldType.O3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'channelSelect', $pb.PbFieldType.O3)
    ..a<$core.int>(10, _omitFieldNames ? '' : 'serverSendTime', $pb.PbFieldType.O3)
    ..a<$core.int>(11, _omitFieldNames ? '' : 'wifiRssi', $pb.PbFieldType.O3)
    ..a<$core.int>(12, _omitFieldNames ? '' : 'serverport', $pb.PbFieldType.O3)
    ..aOS(13, _omitFieldNames ? '' : 'apnSet')
    ..aOS(14, _omitFieldNames ? '' : 'meterKind')
    ..aOS(15, _omitFieldNames ? '' : 'meterInterface')
    ..aOS(16, _omitFieldNames ? '' : 'wifiSsid')
    ..aOS(17, _omitFieldNames ? '' : 'wifiPassword')
    ..aOS(18, _omitFieldNames ? '' : 'serverDomainName')
    ..a<$core.int>(19, _omitFieldNames ? '' : 'invType', $pb.PbFieldType.O3)
    ..aOS(20, _omitFieldNames ? '' : 'dtuSn')
    ..a<$core.int>(21, _omitFieldNames ? '' : 'accessModel', $pb.PbFieldType.O3)
    ..a<$core.int>(22, _omitFieldNames ? '' : 'mac0', $pb.PbFieldType.O3, protoName: 'mac_0')
    ..a<$core.int>(23, _omitFieldNames ? '' : 'mac1', $pb.PbFieldType.O3, protoName: 'mac_1')
    ..a<$core.int>(24, _omitFieldNames ? '' : 'mac2', $pb.PbFieldType.O3, protoName: 'mac_2')
    ..a<$core.int>(25, _omitFieldNames ? '' : 'mac3', $pb.PbFieldType.O3, protoName: 'mac_3')
    ..a<$core.int>(26, _omitFieldNames ? '' : 'dhcpSwitch', $pb.PbFieldType.O3)
    ..a<$core.int>(27, _omitFieldNames ? '' : 'ipAddr0', $pb.PbFieldType.O3, protoName: 'ip_addr_0')
    ..a<$core.int>(28, _omitFieldNames ? '' : 'ipAddr1', $pb.PbFieldType.O3, protoName: 'ip_addr_1')
    ..a<$core.int>(29, _omitFieldNames ? '' : 'ipAddr2', $pb.PbFieldType.O3, protoName: 'ip_addr_2')
    ..a<$core.int>(30, _omitFieldNames ? '' : 'ipAddr3', $pb.PbFieldType.O3, protoName: 'ip_addr_3')
    ..a<$core.int>(31, _omitFieldNames ? '' : 'subnetMask0', $pb.PbFieldType.O3, protoName: 'subnet_mask_0')
    ..a<$core.int>(32, _omitFieldNames ? '' : 'subnetMask1', $pb.PbFieldType.O3, protoName: 'subnet_mask_1')
    ..a<$core.int>(33, _omitFieldNames ? '' : 'subnetMask2', $pb.PbFieldType.O3, protoName: 'subnet_mask_2')
    ..a<$core.int>(34, _omitFieldNames ? '' : 'subnetMask3', $pb.PbFieldType.O3, protoName: 'subnet_mask_3')
    ..a<$core.int>(35, _omitFieldNames ? '' : 'defaultGateway0', $pb.PbFieldType.O3, protoName: 'default_gateway_0')
    ..a<$core.int>(36, _omitFieldNames ? '' : 'defaultGateway1', $pb.PbFieldType.O3, protoName: 'default_gateway_1')
    ..a<$core.int>(37, _omitFieldNames ? '' : 'defaultGateway2', $pb.PbFieldType.O3, protoName: 'default_gateway_2')
    ..a<$core.int>(38, _omitFieldNames ? '' : 'defaultGateway3', $pb.PbFieldType.O3, protoName: 'default_gateway_3')
    ..aOS(39, _omitFieldNames ? '' : 'kaNub')
    ..aOS(40, _omitFieldNames ? '' : 'apnName')
    ..aOS(41, _omitFieldNames ? '' : 'apnPassword')
    ..a<$core.int>(42, _omitFieldNames ? '' : 'sub1gSweepSwitch', $pb.PbFieldType.O3)
    ..a<$core.int>(43, _omitFieldNames ? '' : 'sub1gWorkChannel', $pb.PbFieldType.O3)
    ..a<$core.int>(44, _omitFieldNames ? '' : 'cableDns0', $pb.PbFieldType.O3, protoName: 'cable_dns_0')
    ..a<$core.int>(45, _omitFieldNames ? '' : 'cableDns1', $pb.PbFieldType.O3, protoName: 'cable_dns_1')
    ..a<$core.int>(46, _omitFieldNames ? '' : 'cableDns2', $pb.PbFieldType.O3, protoName: 'cable_dns_2')
    ..a<$core.int>(47, _omitFieldNames ? '' : 'cableDns3', $pb.PbFieldType.O3, protoName: 'cable_dns_3')
    ..a<$core.int>(48, _omitFieldNames ? '' : 'wifiIpAddr0', $pb.PbFieldType.O3, protoName: 'wifi_ip_addr_0')
    ..a<$core.int>(49, _omitFieldNames ? '' : 'wifiIpAddr1', $pb.PbFieldType.O3, protoName: 'wifi_ip_addr_1')
    ..a<$core.int>(50, _omitFieldNames ? '' : 'wifiIpAddr2', $pb.PbFieldType.O3, protoName: 'wifi_ip_addr_2')
    ..a<$core.int>(51, _omitFieldNames ? '' : 'wifiIpAddr3', $pb.PbFieldType.O3, protoName: 'wifi_ip_addr_3')
    ..a<$core.int>(52, _omitFieldNames ? '' : 'mac4', $pb.PbFieldType.O3, protoName: 'mac_4')
    ..a<$core.int>(53, _omitFieldNames ? '' : 'mac5', $pb.PbFieldType.O3, protoName: 'mac_5')
    ..a<$core.int>(54, _omitFieldNames ? '' : 'wifiMac0', $pb.PbFieldType.O3, protoName: 'wifi_mac_0')
    ..a<$core.int>(55, _omitFieldNames ? '' : 'wifiMac1', $pb.PbFieldType.O3, protoName: 'wifi_mac_1')
    ..a<$core.int>(56, _omitFieldNames ? '' : 'wifiMac2', $pb.PbFieldType.O3, protoName: 'wifi_mac_2')
    ..a<$core.int>(57, _omitFieldNames ? '' : 'wifiMac3', $pb.PbFieldType.O3, protoName: 'wifi_mac_3')
    ..a<$core.int>(58, _omitFieldNames ? '' : 'wifiMac4', $pb.PbFieldType.O3, protoName: 'wifi_mac_4')
    ..a<$core.int>(59, _omitFieldNames ? '' : 'wifiMac5', $pb.PbFieldType.O3, protoName: 'wifi_mac_5')
    ..aOS(60, _omitFieldNames ? '' : 'gprsImei')
    ..aOS(61, _omitFieldNames ? '' : 'dtuApSsid')
    ..aOS(62, _omitFieldNames ? '' : 'dtuApPass')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetConfigReqDTO clone() => GetConfigReqDTO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetConfigReqDTO copyWith(void Function(GetConfigReqDTO) updates) => super.copyWith((message) => updates(message as GetConfigReqDTO)) as GetConfigReqDTO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetConfigReqDTO create() => GetConfigReqDTO._();
  GetConfigReqDTO createEmptyInstance() => create();
  static $pb.PbList<GetConfigReqDTO> createRepeated() => $pb.PbList<GetConfigReqDTO>();
  @$core.pragma('dart2js:noInline')
  static GetConfigReqDTO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetConfigReqDTO>(create);
  static GetConfigReqDTO? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get requestOffset => $_getIZ(0);
  @$pb.TagNumber(1)
  set requestOffset($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRequestOffset() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestOffset() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get requestTime => $_getIZ(1);
  @$pb.TagNumber(2)
  set requestTime($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRequestTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequestTime() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get lockPassword => $_getIZ(2);
  @$pb.TagNumber(3)
  set lockPassword($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLockPassword() => $_has(2);
  @$pb.TagNumber(3)
  void clearLockPassword() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get lockTime => $_getIZ(3);
  @$pb.TagNumber(4)
  set lockTime($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLockTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearLockTime() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get limitPowerMypower => $_getIZ(4);
  @$pb.TagNumber(5)
  set limitPowerMypower($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasLimitPowerMypower() => $_has(4);
  @$pb.TagNumber(5)
  void clearLimitPowerMypower() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get zeroExport433Addr => $_getIZ(5);
  @$pb.TagNumber(6)
  set zeroExport433Addr($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasZeroExport433Addr() => $_has(5);
  @$pb.TagNumber(6)
  void clearZeroExport433Addr() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get zeroExportEnable => $_getIZ(6);
  @$pb.TagNumber(7)
  set zeroExportEnable($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasZeroExportEnable() => $_has(6);
  @$pb.TagNumber(7)
  void clearZeroExportEnable() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get netmodeSelect => $_getIZ(7);
  @$pb.TagNumber(8)
  set netmodeSelect($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasNetmodeSelect() => $_has(7);
  @$pb.TagNumber(8)
  void clearNetmodeSelect() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get channelSelect => $_getIZ(8);
  @$pb.TagNumber(9)
  set channelSelect($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasChannelSelect() => $_has(8);
  @$pb.TagNumber(9)
  void clearChannelSelect() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get serverSendTime => $_getIZ(9);
  @$pb.TagNumber(10)
  set serverSendTime($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasServerSendTime() => $_has(9);
  @$pb.TagNumber(10)
  void clearServerSendTime() => clearField(10);

  @$pb.TagNumber(11)
  $core.int get wifiRssi => $_getIZ(10);
  @$pb.TagNumber(11)
  set wifiRssi($core.int v) { $_setSignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasWifiRssi() => $_has(10);
  @$pb.TagNumber(11)
  void clearWifiRssi() => clearField(11);

  @$pb.TagNumber(12)
  $core.int get serverport => $_getIZ(11);
  @$pb.TagNumber(12)
  set serverport($core.int v) { $_setSignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasServerport() => $_has(11);
  @$pb.TagNumber(12)
  void clearServerport() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get apnSet => $_getSZ(12);
  @$pb.TagNumber(13)
  set apnSet($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasApnSet() => $_has(12);
  @$pb.TagNumber(13)
  void clearApnSet() => clearField(13);

  @$pb.TagNumber(14)
  $core.String get meterKind => $_getSZ(13);
  @$pb.TagNumber(14)
  set meterKind($core.String v) { $_setString(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasMeterKind() => $_has(13);
  @$pb.TagNumber(14)
  void clearMeterKind() => clearField(14);

  @$pb.TagNumber(15)
  $core.String get meterInterface => $_getSZ(14);
  @$pb.TagNumber(15)
  set meterInterface($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasMeterInterface() => $_has(14);
  @$pb.TagNumber(15)
  void clearMeterInterface() => clearField(15);

  @$pb.TagNumber(16)
  $core.String get wifiSsid => $_getSZ(15);
  @$pb.TagNumber(16)
  set wifiSsid($core.String v) { $_setString(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasWifiSsid() => $_has(15);
  @$pb.TagNumber(16)
  void clearWifiSsid() => clearField(16);

  @$pb.TagNumber(17)
  $core.String get wifiPassword => $_getSZ(16);
  @$pb.TagNumber(17)
  set wifiPassword($core.String v) { $_setString(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasWifiPassword() => $_has(16);
  @$pb.TagNumber(17)
  void clearWifiPassword() => clearField(17);

  @$pb.TagNumber(18)
  $core.String get serverDomainName => $_getSZ(17);
  @$pb.TagNumber(18)
  set serverDomainName($core.String v) { $_setString(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasServerDomainName() => $_has(17);
  @$pb.TagNumber(18)
  void clearServerDomainName() => clearField(18);

  @$pb.TagNumber(19)
  $core.int get invType => $_getIZ(18);
  @$pb.TagNumber(19)
  set invType($core.int v) { $_setSignedInt32(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasInvType() => $_has(18);
  @$pb.TagNumber(19)
  void clearInvType() => clearField(19);

  @$pb.TagNumber(20)
  $core.String get dtuSn => $_getSZ(19);
  @$pb.TagNumber(20)
  set dtuSn($core.String v) { $_setString(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasDtuSn() => $_has(19);
  @$pb.TagNumber(20)
  void clearDtuSn() => clearField(20);

  @$pb.TagNumber(21)
  $core.int get accessModel => $_getIZ(20);
  @$pb.TagNumber(21)
  set accessModel($core.int v) { $_setSignedInt32(20, v); }
  @$pb.TagNumber(21)
  $core.bool hasAccessModel() => $_has(20);
  @$pb.TagNumber(21)
  void clearAccessModel() => clearField(21);

  @$pb.TagNumber(22)
  $core.int get mac0 => $_getIZ(21);
  @$pb.TagNumber(22)
  set mac0($core.int v) { $_setSignedInt32(21, v); }
  @$pb.TagNumber(22)
  $core.bool hasMac0() => $_has(21);
  @$pb.TagNumber(22)
  void clearMac0() => clearField(22);

  @$pb.TagNumber(23)
  $core.int get mac1 => $_getIZ(22);
  @$pb.TagNumber(23)
  set mac1($core.int v) { $_setSignedInt32(22, v); }
  @$pb.TagNumber(23)
  $core.bool hasMac1() => $_has(22);
  @$pb.TagNumber(23)
  void clearMac1() => clearField(23);

  @$pb.TagNumber(24)
  $core.int get mac2 => $_getIZ(23);
  @$pb.TagNumber(24)
  set mac2($core.int v) { $_setSignedInt32(23, v); }
  @$pb.TagNumber(24)
  $core.bool hasMac2() => $_has(23);
  @$pb.TagNumber(24)
  void clearMac2() => clearField(24);

  @$pb.TagNumber(25)
  $core.int get mac3 => $_getIZ(24);
  @$pb.TagNumber(25)
  set mac3($core.int v) { $_setSignedInt32(24, v); }
  @$pb.TagNumber(25)
  $core.bool hasMac3() => $_has(24);
  @$pb.TagNumber(25)
  void clearMac3() => clearField(25);

  @$pb.TagNumber(26)
  $core.int get dhcpSwitch => $_getIZ(25);
  @$pb.TagNumber(26)
  set dhcpSwitch($core.int v) { $_setSignedInt32(25, v); }
  @$pb.TagNumber(26)
  $core.bool hasDhcpSwitch() => $_has(25);
  @$pb.TagNumber(26)
  void clearDhcpSwitch() => clearField(26);

  @$pb.TagNumber(27)
  $core.int get ipAddr0 => $_getIZ(26);
  @$pb.TagNumber(27)
  set ipAddr0($core.int v) { $_setSignedInt32(26, v); }
  @$pb.TagNumber(27)
  $core.bool hasIpAddr0() => $_has(26);
  @$pb.TagNumber(27)
  void clearIpAddr0() => clearField(27);

  @$pb.TagNumber(28)
  $core.int get ipAddr1 => $_getIZ(27);
  @$pb.TagNumber(28)
  set ipAddr1($core.int v) { $_setSignedInt32(27, v); }
  @$pb.TagNumber(28)
  $core.bool hasIpAddr1() => $_has(27);
  @$pb.TagNumber(28)
  void clearIpAddr1() => clearField(28);

  @$pb.TagNumber(29)
  $core.int get ipAddr2 => $_getIZ(28);
  @$pb.TagNumber(29)
  set ipAddr2($core.int v) { $_setSignedInt32(28, v); }
  @$pb.TagNumber(29)
  $core.bool hasIpAddr2() => $_has(28);
  @$pb.TagNumber(29)
  void clearIpAddr2() => clearField(29);

  @$pb.TagNumber(30)
  $core.int get ipAddr3 => $_getIZ(29);
  @$pb.TagNumber(30)
  set ipAddr3($core.int v) { $_setSignedInt32(29, v); }
  @$pb.TagNumber(30)
  $core.bool hasIpAddr3() => $_has(29);
  @$pb.TagNumber(30)
  void clearIpAddr3() => clearField(30);

  @$pb.TagNumber(31)
  $core.int get subnetMask0 => $_getIZ(30);
  @$pb.TagNumber(31)
  set subnetMask0($core.int v) { $_setSignedInt32(30, v); }
  @$pb.TagNumber(31)
  $core.bool hasSubnetMask0() => $_has(30);
  @$pb.TagNumber(31)
  void clearSubnetMask0() => clearField(31);

  @$pb.TagNumber(32)
  $core.int get subnetMask1 => $_getIZ(31);
  @$pb.TagNumber(32)
  set subnetMask1($core.int v) { $_setSignedInt32(31, v); }
  @$pb.TagNumber(32)
  $core.bool hasSubnetMask1() => $_has(31);
  @$pb.TagNumber(32)
  void clearSubnetMask1() => clearField(32);

  @$pb.TagNumber(33)
  $core.int get subnetMask2 => $_getIZ(32);
  @$pb.TagNumber(33)
  set subnetMask2($core.int v) { $_setSignedInt32(32, v); }
  @$pb.TagNumber(33)
  $core.bool hasSubnetMask2() => $_has(32);
  @$pb.TagNumber(33)
  void clearSubnetMask2() => clearField(33);

  @$pb.TagNumber(34)
  $core.int get subnetMask3 => $_getIZ(33);
  @$pb.TagNumber(34)
  set subnetMask3($core.int v) { $_setSignedInt32(33, v); }
  @$pb.TagNumber(34)
  $core.bool hasSubnetMask3() => $_has(33);
  @$pb.TagNumber(34)
  void clearSubnetMask3() => clearField(34);

  @$pb.TagNumber(35)
  $core.int get defaultGateway0 => $_getIZ(34);
  @$pb.TagNumber(35)
  set defaultGateway0($core.int v) { $_setSignedInt32(34, v); }
  @$pb.TagNumber(35)
  $core.bool hasDefaultGateway0() => $_has(34);
  @$pb.TagNumber(35)
  void clearDefaultGateway0() => clearField(35);

  @$pb.TagNumber(36)
  $core.int get defaultGateway1 => $_getIZ(35);
  @$pb.TagNumber(36)
  set defaultGateway1($core.int v) { $_setSignedInt32(35, v); }
  @$pb.TagNumber(36)
  $core.bool hasDefaultGateway1() => $_has(35);
  @$pb.TagNumber(36)
  void clearDefaultGateway1() => clearField(36);

  @$pb.TagNumber(37)
  $core.int get defaultGateway2 => $_getIZ(36);
  @$pb.TagNumber(37)
  set defaultGateway2($core.int v) { $_setSignedInt32(36, v); }
  @$pb.TagNumber(37)
  $core.bool hasDefaultGateway2() => $_has(36);
  @$pb.TagNumber(37)
  void clearDefaultGateway2() => clearField(37);

  @$pb.TagNumber(38)
  $core.int get defaultGateway3 => $_getIZ(37);
  @$pb.TagNumber(38)
  set defaultGateway3($core.int v) { $_setSignedInt32(37, v); }
  @$pb.TagNumber(38)
  $core.bool hasDefaultGateway3() => $_has(37);
  @$pb.TagNumber(38)
  void clearDefaultGateway3() => clearField(38);

  @$pb.TagNumber(39)
  $core.String get kaNub => $_getSZ(38);
  @$pb.TagNumber(39)
  set kaNub($core.String v) { $_setString(38, v); }
  @$pb.TagNumber(39)
  $core.bool hasKaNub() => $_has(38);
  @$pb.TagNumber(39)
  void clearKaNub() => clearField(39);

  @$pb.TagNumber(40)
  $core.String get apnName => $_getSZ(39);
  @$pb.TagNumber(40)
  set apnName($core.String v) { $_setString(39, v); }
  @$pb.TagNumber(40)
  $core.bool hasApnName() => $_has(39);
  @$pb.TagNumber(40)
  void clearApnName() => clearField(40);

  @$pb.TagNumber(41)
  $core.String get apnPassword => $_getSZ(40);
  @$pb.TagNumber(41)
  set apnPassword($core.String v) { $_setString(40, v); }
  @$pb.TagNumber(41)
  $core.bool hasApnPassword() => $_has(40);
  @$pb.TagNumber(41)
  void clearApnPassword() => clearField(41);

  @$pb.TagNumber(42)
  $core.int get sub1gSweepSwitch => $_getIZ(41);
  @$pb.TagNumber(42)
  set sub1gSweepSwitch($core.int v) { $_setSignedInt32(41, v); }
  @$pb.TagNumber(42)
  $core.bool hasSub1gSweepSwitch() => $_has(41);
  @$pb.TagNumber(42)
  void clearSub1gSweepSwitch() => clearField(42);

  @$pb.TagNumber(43)
  $core.int get sub1gWorkChannel => $_getIZ(42);
  @$pb.TagNumber(43)
  set sub1gWorkChannel($core.int v) { $_setSignedInt32(42, v); }
  @$pb.TagNumber(43)
  $core.bool hasSub1gWorkChannel() => $_has(42);
  @$pb.TagNumber(43)
  void clearSub1gWorkChannel() => clearField(43);

  @$pb.TagNumber(44)
  $core.int get cableDns0 => $_getIZ(43);
  @$pb.TagNumber(44)
  set cableDns0($core.int v) { $_setSignedInt32(43, v); }
  @$pb.TagNumber(44)
  $core.bool hasCableDns0() => $_has(43);
  @$pb.TagNumber(44)
  void clearCableDns0() => clearField(44);

  @$pb.TagNumber(45)
  $core.int get cableDns1 => $_getIZ(44);
  @$pb.TagNumber(45)
  set cableDns1($core.int v) { $_setSignedInt32(44, v); }
  @$pb.TagNumber(45)
  $core.bool hasCableDns1() => $_has(44);
  @$pb.TagNumber(45)
  void clearCableDns1() => clearField(45);

  @$pb.TagNumber(46)
  $core.int get cableDns2 => $_getIZ(45);
  @$pb.TagNumber(46)
  set cableDns2($core.int v) { $_setSignedInt32(45, v); }
  @$pb.TagNumber(46)
  $core.bool hasCableDns2() => $_has(45);
  @$pb.TagNumber(46)
  void clearCableDns2() => clearField(46);

  @$pb.TagNumber(47)
  $core.int get cableDns3 => $_getIZ(46);
  @$pb.TagNumber(47)
  set cableDns3($core.int v) { $_setSignedInt32(46, v); }
  @$pb.TagNumber(47)
  $core.bool hasCableDns3() => $_has(46);
  @$pb.TagNumber(47)
  void clearCableDns3() => clearField(47);

  @$pb.TagNumber(48)
  $core.int get wifiIpAddr0 => $_getIZ(47);
  @$pb.TagNumber(48)
  set wifiIpAddr0($core.int v) { $_setSignedInt32(47, v); }
  @$pb.TagNumber(48)
  $core.bool hasWifiIpAddr0() => $_has(47);
  @$pb.TagNumber(48)
  void clearWifiIpAddr0() => clearField(48);

  @$pb.TagNumber(49)
  $core.int get wifiIpAddr1 => $_getIZ(48);
  @$pb.TagNumber(49)
  set wifiIpAddr1($core.int v) { $_setSignedInt32(48, v); }
  @$pb.TagNumber(49)
  $core.bool hasWifiIpAddr1() => $_has(48);
  @$pb.TagNumber(49)
  void clearWifiIpAddr1() => clearField(49);

  @$pb.TagNumber(50)
  $core.int get wifiIpAddr2 => $_getIZ(49);
  @$pb.TagNumber(50)
  set wifiIpAddr2($core.int v) { $_setSignedInt32(49, v); }
  @$pb.TagNumber(50)
  $core.bool hasWifiIpAddr2() => $_has(49);
  @$pb.TagNumber(50)
  void clearWifiIpAddr2() => clearField(50);

  @$pb.TagNumber(51)
  $core.int get wifiIpAddr3 => $_getIZ(50);
  @$pb.TagNumber(51)
  set wifiIpAddr3($core.int v) { $_setSignedInt32(50, v); }
  @$pb.TagNumber(51)
  $core.bool hasWifiIpAddr3() => $_has(50);
  @$pb.TagNumber(51)
  void clearWifiIpAddr3() => clearField(51);

  @$pb.TagNumber(52)
  $core.int get mac4 => $_getIZ(51);
  @$pb.TagNumber(52)
  set mac4($core.int v) { $_setSignedInt32(51, v); }
  @$pb.TagNumber(52)
  $core.bool hasMac4() => $_has(51);
  @$pb.TagNumber(52)
  void clearMac4() => clearField(52);

  @$pb.TagNumber(53)
  $core.int get mac5 => $_getIZ(52);
  @$pb.TagNumber(53)
  set mac5($core.int v) { $_setSignedInt32(52, v); }
  @$pb.TagNumber(53)
  $core.bool hasMac5() => $_has(52);
  @$pb.TagNumber(53)
  void clearMac5() => clearField(53);

  @$pb.TagNumber(54)
  $core.int get wifiMac0 => $_getIZ(53);
  @$pb.TagNumber(54)
  set wifiMac0($core.int v) { $_setSignedInt32(53, v); }
  @$pb.TagNumber(54)
  $core.bool hasWifiMac0() => $_has(53);
  @$pb.TagNumber(54)
  void clearWifiMac0() => clearField(54);

  @$pb.TagNumber(55)
  $core.int get wifiMac1 => $_getIZ(54);
  @$pb.TagNumber(55)
  set wifiMac1($core.int v) { $_setSignedInt32(54, v); }
  @$pb.TagNumber(55)
  $core.bool hasWifiMac1() => $_has(54);
  @$pb.TagNumber(55)
  void clearWifiMac1() => clearField(55);

  @$pb.TagNumber(56)
  $core.int get wifiMac2 => $_getIZ(55);
  @$pb.TagNumber(56)
  set wifiMac2($core.int v) { $_setSignedInt32(55, v); }
  @$pb.TagNumber(56)
  $core.bool hasWifiMac2() => $_has(55);
  @$pb.TagNumber(56)
  void clearWifiMac2() => clearField(56);

  @$pb.TagNumber(57)
  $core.int get wifiMac3 => $_getIZ(56);
  @$pb.TagNumber(57)
  set wifiMac3($core.int v) { $_setSignedInt32(56, v); }
  @$pb.TagNumber(57)
  $core.bool hasWifiMac3() => $_has(56);
  @$pb.TagNumber(57)
  void clearWifiMac3() => clearField(57);

  @$pb.TagNumber(58)
  $core.int get wifiMac4 => $_getIZ(57);
  @$pb.TagNumber(58)
  set wifiMac4($core.int v) { $_setSignedInt32(57, v); }
  @$pb.TagNumber(58)
  $core.bool hasWifiMac4() => $_has(57);
  @$pb.TagNumber(58)
  void clearWifiMac4() => clearField(58);

  @$pb.TagNumber(59)
  $core.int get wifiMac5 => $_getIZ(58);
  @$pb.TagNumber(59)
  set wifiMac5($core.int v) { $_setSignedInt32(58, v); }
  @$pb.TagNumber(59)
  $core.bool hasWifiMac5() => $_has(58);
  @$pb.TagNumber(59)
  void clearWifiMac5() => clearField(59);

  @$pb.TagNumber(60)
  $core.String get gprsImei => $_getSZ(59);
  @$pb.TagNumber(60)
  set gprsImei($core.String v) { $_setString(59, v); }
  @$pb.TagNumber(60)
  $core.bool hasGprsImei() => $_has(59);
  @$pb.TagNumber(60)
  void clearGprsImei() => clearField(60);

  @$pb.TagNumber(61)
  $core.String get dtuApSsid => $_getSZ(60);
  @$pb.TagNumber(61)
  set dtuApSsid($core.String v) { $_setString(60, v); }
  @$pb.TagNumber(61)
  $core.bool hasDtuApSsid() => $_has(60);
  @$pb.TagNumber(61)
  void clearDtuApSsid() => clearField(61);

  @$pb.TagNumber(62)
  $core.String get dtuApPass => $_getSZ(61);
  @$pb.TagNumber(62)
  set dtuApPass($core.String v) { $_setString(61, v); }
  @$pb.TagNumber(62)
  $core.bool hasDtuApPass() => $_has(61);
  @$pb.TagNumber(62)
  void clearDtuApPass() => clearField(62);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
