//
//  Generated code. Do not modify.
//  source: SetConfig.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class SetConfigResDTO extends $pb.GeneratedMessage {
  factory SetConfigResDTO({
    $core.int? offset,
    $core.int? time,
    $core.int? lockPassword,
    $core.int? lockTime,
    $core.int? limitPowerMypower,
    $core.int? zeroExport433Addr,
    $core.int? zeroExportEnable,
    $core.int? netmodeSelect,
    $core.int? channelSelect,
    $core.int? serverSendTime,
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
    $core.String? apnName,
    $core.String? apnPassword,
    $core.int? sub1gSweepSwitch,
    $core.int? sub1gWorkChannel,
    $core.int? cableDns0,
    $core.int? cableDns1,
    $core.int? cableDns2,
    $core.int? cableDns3,
    $core.int? mac4,
    $core.int? mac5,
    $core.String? dtuApSsid,
    $core.String? dtuApPass,
    $core.int? appPage,
  }) {
    final $result = create();
    if (offset != null) {
      $result.offset = offset;
    }
    if (time != null) {
      $result.time = time;
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
    if (mac4 != null) {
      $result.mac4 = mac4;
    }
    if (mac5 != null) {
      $result.mac5 = mac5;
    }
    if (dtuApSsid != null) {
      $result.dtuApSsid = dtuApSsid;
    }
    if (dtuApPass != null) {
      $result.dtuApPass = dtuApPass;
    }
    if (appPage != null) {
      $result.appPage = appPage;
    }
    return $result;
  }
  SetConfigResDTO._() : super();
  factory SetConfigResDTO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetConfigResDTO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetConfigResDTO', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'time', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'lockPassword', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'lockTime', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'limitPowerMypower', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'zeroExport433Addr', $pb.PbFieldType.O3, protoName: 'zero_export_433_addr')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'zeroExportEnable', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'netmodeSelect', $pb.PbFieldType.O3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'channelSelect', $pb.PbFieldType.O3)
    ..a<$core.int>(10, _omitFieldNames ? '' : 'serverSendTime', $pb.PbFieldType.O3)
    ..a<$core.int>(11, _omitFieldNames ? '' : 'serverport', $pb.PbFieldType.O3)
    ..aOS(12, _omitFieldNames ? '' : 'apnSet')
    ..aOS(13, _omitFieldNames ? '' : 'meterKind')
    ..aOS(14, _omitFieldNames ? '' : 'meterInterface')
    ..aOS(15, _omitFieldNames ? '' : 'wifiSsid')
    ..aOS(16, _omitFieldNames ? '' : 'wifiPassword')
    ..aOS(17, _omitFieldNames ? '' : 'serverDomainName')
    ..a<$core.int>(18, _omitFieldNames ? '' : 'invType', $pb.PbFieldType.O3)
    ..aOS(19, _omitFieldNames ? '' : 'dtuSn')
    ..a<$core.int>(20, _omitFieldNames ? '' : 'accessModel', $pb.PbFieldType.O3)
    ..a<$core.int>(21, _omitFieldNames ? '' : 'mac0', $pb.PbFieldType.O3, protoName: 'mac_0')
    ..a<$core.int>(22, _omitFieldNames ? '' : 'mac1', $pb.PbFieldType.O3, protoName: 'mac_1')
    ..a<$core.int>(23, _omitFieldNames ? '' : 'mac2', $pb.PbFieldType.O3, protoName: 'mac_2')
    ..a<$core.int>(24, _omitFieldNames ? '' : 'mac3', $pb.PbFieldType.O3, protoName: 'mac_3')
    ..a<$core.int>(25, _omitFieldNames ? '' : 'dhcpSwitch', $pb.PbFieldType.O3)
    ..a<$core.int>(26, _omitFieldNames ? '' : 'ipAddr0', $pb.PbFieldType.O3, protoName: 'ip_addr_0')
    ..a<$core.int>(27, _omitFieldNames ? '' : 'ipAddr1', $pb.PbFieldType.O3, protoName: 'ip_addr_1')
    ..a<$core.int>(28, _omitFieldNames ? '' : 'ipAddr2', $pb.PbFieldType.O3, protoName: 'ip_addr_2')
    ..a<$core.int>(29, _omitFieldNames ? '' : 'ipAddr3', $pb.PbFieldType.O3, protoName: 'ip_addr_3')
    ..a<$core.int>(30, _omitFieldNames ? '' : 'subnetMask0', $pb.PbFieldType.O3, protoName: 'subnet_mask_0')
    ..a<$core.int>(31, _omitFieldNames ? '' : 'subnetMask1', $pb.PbFieldType.O3, protoName: 'subnet_mask_1')
    ..a<$core.int>(32, _omitFieldNames ? '' : 'subnetMask2', $pb.PbFieldType.O3, protoName: 'subnet_mask_2')
    ..a<$core.int>(33, _omitFieldNames ? '' : 'subnetMask3', $pb.PbFieldType.O3, protoName: 'subnet_mask_3')
    ..a<$core.int>(34, _omitFieldNames ? '' : 'defaultGateway0', $pb.PbFieldType.O3, protoName: 'default_gateway_0')
    ..a<$core.int>(35, _omitFieldNames ? '' : 'defaultGateway1', $pb.PbFieldType.O3, protoName: 'default_gateway_1')
    ..a<$core.int>(36, _omitFieldNames ? '' : 'defaultGateway2', $pb.PbFieldType.O3, protoName: 'default_gateway_2')
    ..a<$core.int>(37, _omitFieldNames ? '' : 'defaultGateway3', $pb.PbFieldType.O3, protoName: 'default_gateway_3')
    ..aOS(38, _omitFieldNames ? '' : 'apnName')
    ..aOS(39, _omitFieldNames ? '' : 'apnPassword')
    ..a<$core.int>(40, _omitFieldNames ? '' : 'sub1gSweepSwitch', $pb.PbFieldType.O3)
    ..a<$core.int>(41, _omitFieldNames ? '' : 'sub1gWorkChannel', $pb.PbFieldType.O3)
    ..a<$core.int>(42, _omitFieldNames ? '' : 'cableDns0', $pb.PbFieldType.O3, protoName: 'cable_dns_0')
    ..a<$core.int>(43, _omitFieldNames ? '' : 'cableDns1', $pb.PbFieldType.O3, protoName: 'cable_dns_1')
    ..a<$core.int>(44, _omitFieldNames ? '' : 'cableDns2', $pb.PbFieldType.O3, protoName: 'cable_dns_2')
    ..a<$core.int>(45, _omitFieldNames ? '' : 'cableDns3', $pb.PbFieldType.O3, protoName: 'cable_dns_3')
    ..a<$core.int>(46, _omitFieldNames ? '' : 'mac4', $pb.PbFieldType.O3, protoName: 'mac_4')
    ..a<$core.int>(47, _omitFieldNames ? '' : 'mac5', $pb.PbFieldType.O3, protoName: 'mac_5')
    ..aOS(48, _omitFieldNames ? '' : 'dtuApSsid')
    ..aOS(49, _omitFieldNames ? '' : 'dtuApPass')
    ..a<$core.int>(50, _omitFieldNames ? '' : 'appPage', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetConfigResDTO clone() => SetConfigResDTO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetConfigResDTO copyWith(void Function(SetConfigResDTO) updates) => super.copyWith((message) => updates(message as SetConfigResDTO)) as SetConfigResDTO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetConfigResDTO create() => SetConfigResDTO._();
  SetConfigResDTO createEmptyInstance() => create();
  static $pb.PbList<SetConfigResDTO> createRepeated() => $pb.PbList<SetConfigResDTO>();
  @$core.pragma('dart2js:noInline')
  static SetConfigResDTO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetConfigResDTO>(create);
  static SetConfigResDTO? _defaultInstance;

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
  $core.int get serverport => $_getIZ(10);
  @$pb.TagNumber(11)
  set serverport($core.int v) { $_setSignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasServerport() => $_has(10);
  @$pb.TagNumber(11)
  void clearServerport() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get apnSet => $_getSZ(11);
  @$pb.TagNumber(12)
  set apnSet($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasApnSet() => $_has(11);
  @$pb.TagNumber(12)
  void clearApnSet() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get meterKind => $_getSZ(12);
  @$pb.TagNumber(13)
  set meterKind($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasMeterKind() => $_has(12);
  @$pb.TagNumber(13)
  void clearMeterKind() => clearField(13);

  @$pb.TagNumber(14)
  $core.String get meterInterface => $_getSZ(13);
  @$pb.TagNumber(14)
  set meterInterface($core.String v) { $_setString(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasMeterInterface() => $_has(13);
  @$pb.TagNumber(14)
  void clearMeterInterface() => clearField(14);

  @$pb.TagNumber(15)
  $core.String get wifiSsid => $_getSZ(14);
  @$pb.TagNumber(15)
  set wifiSsid($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasWifiSsid() => $_has(14);
  @$pb.TagNumber(15)
  void clearWifiSsid() => clearField(15);

  @$pb.TagNumber(16)
  $core.String get wifiPassword => $_getSZ(15);
  @$pb.TagNumber(16)
  set wifiPassword($core.String v) { $_setString(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasWifiPassword() => $_has(15);
  @$pb.TagNumber(16)
  void clearWifiPassword() => clearField(16);

  @$pb.TagNumber(17)
  $core.String get serverDomainName => $_getSZ(16);
  @$pb.TagNumber(17)
  set serverDomainName($core.String v) { $_setString(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasServerDomainName() => $_has(16);
  @$pb.TagNumber(17)
  void clearServerDomainName() => clearField(17);

  @$pb.TagNumber(18)
  $core.int get invType => $_getIZ(17);
  @$pb.TagNumber(18)
  set invType($core.int v) { $_setSignedInt32(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasInvType() => $_has(17);
  @$pb.TagNumber(18)
  void clearInvType() => clearField(18);

  @$pb.TagNumber(19)
  $core.String get dtuSn => $_getSZ(18);
  @$pb.TagNumber(19)
  set dtuSn($core.String v) { $_setString(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasDtuSn() => $_has(18);
  @$pb.TagNumber(19)
  void clearDtuSn() => clearField(19);

  @$pb.TagNumber(20)
  $core.int get accessModel => $_getIZ(19);
  @$pb.TagNumber(20)
  set accessModel($core.int v) { $_setSignedInt32(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasAccessModel() => $_has(19);
  @$pb.TagNumber(20)
  void clearAccessModel() => clearField(20);

  @$pb.TagNumber(21)
  $core.int get mac0 => $_getIZ(20);
  @$pb.TagNumber(21)
  set mac0($core.int v) { $_setSignedInt32(20, v); }
  @$pb.TagNumber(21)
  $core.bool hasMac0() => $_has(20);
  @$pb.TagNumber(21)
  void clearMac0() => clearField(21);

  @$pb.TagNumber(22)
  $core.int get mac1 => $_getIZ(21);
  @$pb.TagNumber(22)
  set mac1($core.int v) { $_setSignedInt32(21, v); }
  @$pb.TagNumber(22)
  $core.bool hasMac1() => $_has(21);
  @$pb.TagNumber(22)
  void clearMac1() => clearField(22);

  @$pb.TagNumber(23)
  $core.int get mac2 => $_getIZ(22);
  @$pb.TagNumber(23)
  set mac2($core.int v) { $_setSignedInt32(22, v); }
  @$pb.TagNumber(23)
  $core.bool hasMac2() => $_has(22);
  @$pb.TagNumber(23)
  void clearMac2() => clearField(23);

  @$pb.TagNumber(24)
  $core.int get mac3 => $_getIZ(23);
  @$pb.TagNumber(24)
  set mac3($core.int v) { $_setSignedInt32(23, v); }
  @$pb.TagNumber(24)
  $core.bool hasMac3() => $_has(23);
  @$pb.TagNumber(24)
  void clearMac3() => clearField(24);

  @$pb.TagNumber(25)
  $core.int get dhcpSwitch => $_getIZ(24);
  @$pb.TagNumber(25)
  set dhcpSwitch($core.int v) { $_setSignedInt32(24, v); }
  @$pb.TagNumber(25)
  $core.bool hasDhcpSwitch() => $_has(24);
  @$pb.TagNumber(25)
  void clearDhcpSwitch() => clearField(25);

  @$pb.TagNumber(26)
  $core.int get ipAddr0 => $_getIZ(25);
  @$pb.TagNumber(26)
  set ipAddr0($core.int v) { $_setSignedInt32(25, v); }
  @$pb.TagNumber(26)
  $core.bool hasIpAddr0() => $_has(25);
  @$pb.TagNumber(26)
  void clearIpAddr0() => clearField(26);

  @$pb.TagNumber(27)
  $core.int get ipAddr1 => $_getIZ(26);
  @$pb.TagNumber(27)
  set ipAddr1($core.int v) { $_setSignedInt32(26, v); }
  @$pb.TagNumber(27)
  $core.bool hasIpAddr1() => $_has(26);
  @$pb.TagNumber(27)
  void clearIpAddr1() => clearField(27);

  @$pb.TagNumber(28)
  $core.int get ipAddr2 => $_getIZ(27);
  @$pb.TagNumber(28)
  set ipAddr2($core.int v) { $_setSignedInt32(27, v); }
  @$pb.TagNumber(28)
  $core.bool hasIpAddr2() => $_has(27);
  @$pb.TagNumber(28)
  void clearIpAddr2() => clearField(28);

  @$pb.TagNumber(29)
  $core.int get ipAddr3 => $_getIZ(28);
  @$pb.TagNumber(29)
  set ipAddr3($core.int v) { $_setSignedInt32(28, v); }
  @$pb.TagNumber(29)
  $core.bool hasIpAddr3() => $_has(28);
  @$pb.TagNumber(29)
  void clearIpAddr3() => clearField(29);

  @$pb.TagNumber(30)
  $core.int get subnetMask0 => $_getIZ(29);
  @$pb.TagNumber(30)
  set subnetMask0($core.int v) { $_setSignedInt32(29, v); }
  @$pb.TagNumber(30)
  $core.bool hasSubnetMask0() => $_has(29);
  @$pb.TagNumber(30)
  void clearSubnetMask0() => clearField(30);

  @$pb.TagNumber(31)
  $core.int get subnetMask1 => $_getIZ(30);
  @$pb.TagNumber(31)
  set subnetMask1($core.int v) { $_setSignedInt32(30, v); }
  @$pb.TagNumber(31)
  $core.bool hasSubnetMask1() => $_has(30);
  @$pb.TagNumber(31)
  void clearSubnetMask1() => clearField(31);

  @$pb.TagNumber(32)
  $core.int get subnetMask2 => $_getIZ(31);
  @$pb.TagNumber(32)
  set subnetMask2($core.int v) { $_setSignedInt32(31, v); }
  @$pb.TagNumber(32)
  $core.bool hasSubnetMask2() => $_has(31);
  @$pb.TagNumber(32)
  void clearSubnetMask2() => clearField(32);

  @$pb.TagNumber(33)
  $core.int get subnetMask3 => $_getIZ(32);
  @$pb.TagNumber(33)
  set subnetMask3($core.int v) { $_setSignedInt32(32, v); }
  @$pb.TagNumber(33)
  $core.bool hasSubnetMask3() => $_has(32);
  @$pb.TagNumber(33)
  void clearSubnetMask3() => clearField(33);

  @$pb.TagNumber(34)
  $core.int get defaultGateway0 => $_getIZ(33);
  @$pb.TagNumber(34)
  set defaultGateway0($core.int v) { $_setSignedInt32(33, v); }
  @$pb.TagNumber(34)
  $core.bool hasDefaultGateway0() => $_has(33);
  @$pb.TagNumber(34)
  void clearDefaultGateway0() => clearField(34);

  @$pb.TagNumber(35)
  $core.int get defaultGateway1 => $_getIZ(34);
  @$pb.TagNumber(35)
  set defaultGateway1($core.int v) { $_setSignedInt32(34, v); }
  @$pb.TagNumber(35)
  $core.bool hasDefaultGateway1() => $_has(34);
  @$pb.TagNumber(35)
  void clearDefaultGateway1() => clearField(35);

  @$pb.TagNumber(36)
  $core.int get defaultGateway2 => $_getIZ(35);
  @$pb.TagNumber(36)
  set defaultGateway2($core.int v) { $_setSignedInt32(35, v); }
  @$pb.TagNumber(36)
  $core.bool hasDefaultGateway2() => $_has(35);
  @$pb.TagNumber(36)
  void clearDefaultGateway2() => clearField(36);

  @$pb.TagNumber(37)
  $core.int get defaultGateway3 => $_getIZ(36);
  @$pb.TagNumber(37)
  set defaultGateway3($core.int v) { $_setSignedInt32(36, v); }
  @$pb.TagNumber(37)
  $core.bool hasDefaultGateway3() => $_has(36);
  @$pb.TagNumber(37)
  void clearDefaultGateway3() => clearField(37);

  @$pb.TagNumber(38)
  $core.String get apnName => $_getSZ(37);
  @$pb.TagNumber(38)
  set apnName($core.String v) { $_setString(37, v); }
  @$pb.TagNumber(38)
  $core.bool hasApnName() => $_has(37);
  @$pb.TagNumber(38)
  void clearApnName() => clearField(38);

  @$pb.TagNumber(39)
  $core.String get apnPassword => $_getSZ(38);
  @$pb.TagNumber(39)
  set apnPassword($core.String v) { $_setString(38, v); }
  @$pb.TagNumber(39)
  $core.bool hasApnPassword() => $_has(38);
  @$pb.TagNumber(39)
  void clearApnPassword() => clearField(39);

  @$pb.TagNumber(40)
  $core.int get sub1gSweepSwitch => $_getIZ(39);
  @$pb.TagNumber(40)
  set sub1gSweepSwitch($core.int v) { $_setSignedInt32(39, v); }
  @$pb.TagNumber(40)
  $core.bool hasSub1gSweepSwitch() => $_has(39);
  @$pb.TagNumber(40)
  void clearSub1gSweepSwitch() => clearField(40);

  @$pb.TagNumber(41)
  $core.int get sub1gWorkChannel => $_getIZ(40);
  @$pb.TagNumber(41)
  set sub1gWorkChannel($core.int v) { $_setSignedInt32(40, v); }
  @$pb.TagNumber(41)
  $core.bool hasSub1gWorkChannel() => $_has(40);
  @$pb.TagNumber(41)
  void clearSub1gWorkChannel() => clearField(41);

  @$pb.TagNumber(42)
  $core.int get cableDns0 => $_getIZ(41);
  @$pb.TagNumber(42)
  set cableDns0($core.int v) { $_setSignedInt32(41, v); }
  @$pb.TagNumber(42)
  $core.bool hasCableDns0() => $_has(41);
  @$pb.TagNumber(42)
  void clearCableDns0() => clearField(42);

  @$pb.TagNumber(43)
  $core.int get cableDns1 => $_getIZ(42);
  @$pb.TagNumber(43)
  set cableDns1($core.int v) { $_setSignedInt32(42, v); }
  @$pb.TagNumber(43)
  $core.bool hasCableDns1() => $_has(42);
  @$pb.TagNumber(43)
  void clearCableDns1() => clearField(43);

  @$pb.TagNumber(44)
  $core.int get cableDns2 => $_getIZ(43);
  @$pb.TagNumber(44)
  set cableDns2($core.int v) { $_setSignedInt32(43, v); }
  @$pb.TagNumber(44)
  $core.bool hasCableDns2() => $_has(43);
  @$pb.TagNumber(44)
  void clearCableDns2() => clearField(44);

  @$pb.TagNumber(45)
  $core.int get cableDns3 => $_getIZ(44);
  @$pb.TagNumber(45)
  set cableDns3($core.int v) { $_setSignedInt32(44, v); }
  @$pb.TagNumber(45)
  $core.bool hasCableDns3() => $_has(44);
  @$pb.TagNumber(45)
  void clearCableDns3() => clearField(45);

  @$pb.TagNumber(46)
  $core.int get mac4 => $_getIZ(45);
  @$pb.TagNumber(46)
  set mac4($core.int v) { $_setSignedInt32(45, v); }
  @$pb.TagNumber(46)
  $core.bool hasMac4() => $_has(45);
  @$pb.TagNumber(46)
  void clearMac4() => clearField(46);

  @$pb.TagNumber(47)
  $core.int get mac5 => $_getIZ(46);
  @$pb.TagNumber(47)
  set mac5($core.int v) { $_setSignedInt32(46, v); }
  @$pb.TagNumber(47)
  $core.bool hasMac5() => $_has(46);
  @$pb.TagNumber(47)
  void clearMac5() => clearField(47);

  @$pb.TagNumber(48)
  $core.String get dtuApSsid => $_getSZ(47);
  @$pb.TagNumber(48)
  set dtuApSsid($core.String v) { $_setString(47, v); }
  @$pb.TagNumber(48)
  $core.bool hasDtuApSsid() => $_has(47);
  @$pb.TagNumber(48)
  void clearDtuApSsid() => clearField(48);

  @$pb.TagNumber(49)
  $core.String get dtuApPass => $_getSZ(48);
  @$pb.TagNumber(49)
  set dtuApPass($core.String v) { $_setString(48, v); }
  @$pb.TagNumber(49)
  $core.bool hasDtuApPass() => $_has(48);
  @$pb.TagNumber(49)
  void clearDtuApPass() => clearField(49);

  @$pb.TagNumber(50)
  $core.int get appPage => $_getIZ(49);
  @$pb.TagNumber(50)
  set appPage($core.int v) { $_setSignedInt32(49, v); }
  @$pb.TagNumber(50)
  $core.bool hasAppPage() => $_has(49);
  @$pb.TagNumber(50)
  void clearAppPage() => clearField(50);
}

/// Definition of the request message for setting configuration.
class SetConfigReqDTO extends $pb.GeneratedMessage {
  factory SetConfigReqDTO({
    $core.int? offset,
    $core.int? time,
    $core.int? errorCode,
  }) {
    final $result = create();
    if (offset != null) {
      $result.offset = offset;
    }
    if (time != null) {
      $result.time = time;
    }
    if (errorCode != null) {
      $result.errorCode = errorCode;
    }
    return $result;
  }
  SetConfigReqDTO._() : super();
  factory SetConfigReqDTO.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetConfigReqDTO.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetConfigReqDTO', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'time', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'errorCode', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetConfigReqDTO clone() => SetConfigReqDTO()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetConfigReqDTO copyWith(void Function(SetConfigReqDTO) updates) => super.copyWith((message) => updates(message as SetConfigReqDTO)) as SetConfigReqDTO;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetConfigReqDTO create() => SetConfigReqDTO._();
  SetConfigReqDTO createEmptyInstance() => create();
  static $pb.PbList<SetConfigReqDTO> createRepeated() => $pb.PbList<SetConfigReqDTO>();
  @$core.pragma('dart2js:noInline')
  static SetConfigReqDTO getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetConfigReqDTO>(create);
  static SetConfigReqDTO? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.int get errorCode => $_getIZ(2);
  @$pb.TagNumber(3)
  set errorCode($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasErrorCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearErrorCode() => clearField(3);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
