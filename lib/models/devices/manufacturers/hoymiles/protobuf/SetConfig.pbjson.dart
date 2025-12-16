//
//  Generated code. Do not modify.
//  source: SetConfig.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use setConfigResDTODescriptor instead')
const SetConfigResDTO$json = {
  '1': 'SetConfigResDTO',
  '2': [
    {'1': 'offset', '3': 1, '4': 1, '5': 5, '10': 'offset'},
    {'1': 'time', '3': 2, '4': 1, '5': 13, '10': 'time'},
    {'1': 'lock_password', '3': 3, '4': 1, '5': 5, '10': 'lockPassword'},
    {'1': 'lock_time', '3': 4, '4': 1, '5': 5, '10': 'lockTime'},
    {'1': 'limit_power_mypower', '3': 5, '4': 1, '5': 5, '10': 'limitPowerMypower'},
    {'1': 'zero_export_433_addr', '3': 6, '4': 1, '5': 5, '10': 'zeroExport433Addr'},
    {'1': 'zero_export_enable', '3': 7, '4': 1, '5': 5, '10': 'zeroExportEnable'},
    {'1': 'netmode_select', '3': 8, '4': 1, '5': 5, '10': 'netmodeSelect'},
    {'1': 'channel_select', '3': 9, '4': 1, '5': 5, '10': 'channelSelect'},
    {'1': 'server_send_time', '3': 10, '4': 1, '5': 5, '10': 'serverSendTime'},
    {'1': 'serverport', '3': 11, '4': 1, '5': 5, '10': 'serverport'},
    {'1': 'apn_set', '3': 12, '4': 1, '5': 9, '10': 'apnSet'},
    {'1': 'meter_kind', '3': 13, '4': 1, '5': 9, '10': 'meterKind'},
    {'1': 'meter_interface', '3': 14, '4': 1, '5': 9, '10': 'meterInterface'},
    {'1': 'wifi_ssid', '3': 15, '4': 1, '5': 9, '10': 'wifiSsid'},
    {'1': 'wifi_password', '3': 16, '4': 1, '5': 9, '10': 'wifiPassword'},
    {'1': 'server_domain_name', '3': 17, '4': 1, '5': 9, '10': 'serverDomainName'},
    {'1': 'inv_type', '3': 18, '4': 1, '5': 5, '10': 'invType'},
    {'1': 'dtu_sn', '3': 19, '4': 1, '5': 9, '10': 'dtuSn'},
    {'1': 'access_model', '3': 20, '4': 1, '5': 5, '10': 'accessModel'},
    {'1': 'mac_0', '3': 21, '4': 1, '5': 5, '10': 'mac0'},
    {'1': 'mac_1', '3': 22, '4': 1, '5': 5, '10': 'mac1'},
    {'1': 'mac_2', '3': 23, '4': 1, '5': 5, '10': 'mac2'},
    {'1': 'mac_3', '3': 24, '4': 1, '5': 5, '10': 'mac3'},
    {'1': 'dhcp_switch', '3': 25, '4': 1, '5': 5, '10': 'dhcpSwitch'},
    {'1': 'ip_addr_0', '3': 26, '4': 1, '5': 5, '10': 'ipAddr0'},
    {'1': 'ip_addr_1', '3': 27, '4': 1, '5': 5, '10': 'ipAddr1'},
    {'1': 'ip_addr_2', '3': 28, '4': 1, '5': 5, '10': 'ipAddr2'},
    {'1': 'ip_addr_3', '3': 29, '4': 1, '5': 5, '10': 'ipAddr3'},
    {'1': 'subnet_mask_0', '3': 30, '4': 1, '5': 5, '10': 'subnetMask0'},
    {'1': 'subnet_mask_1', '3': 31, '4': 1, '5': 5, '10': 'subnetMask1'},
    {'1': 'subnet_mask_2', '3': 32, '4': 1, '5': 5, '10': 'subnetMask2'},
    {'1': 'subnet_mask_3', '3': 33, '4': 1, '5': 5, '10': 'subnetMask3'},
    {'1': 'default_gateway_0', '3': 34, '4': 1, '5': 5, '10': 'defaultGateway0'},
    {'1': 'default_gateway_1', '3': 35, '4': 1, '5': 5, '10': 'defaultGateway1'},
    {'1': 'default_gateway_2', '3': 36, '4': 1, '5': 5, '10': 'defaultGateway2'},
    {'1': 'default_gateway_3', '3': 37, '4': 1, '5': 5, '10': 'defaultGateway3'},
    {'1': 'apn_name', '3': 38, '4': 1, '5': 9, '10': 'apnName'},
    {'1': 'apn_password', '3': 39, '4': 1, '5': 9, '10': 'apnPassword'},
    {'1': 'sub1g_sweep_switch', '3': 40, '4': 1, '5': 5, '10': 'sub1gSweepSwitch'},
    {'1': 'sub1g_work_channel', '3': 41, '4': 1, '5': 5, '10': 'sub1gWorkChannel'},
    {'1': 'cable_dns_0', '3': 42, '4': 1, '5': 5, '10': 'cableDns0'},
    {'1': 'cable_dns_1', '3': 43, '4': 1, '5': 5, '10': 'cableDns1'},
    {'1': 'cable_dns_2', '3': 44, '4': 1, '5': 5, '10': 'cableDns2'},
    {'1': 'cable_dns_3', '3': 45, '4': 1, '5': 5, '10': 'cableDns3'},
    {'1': 'mac_4', '3': 46, '4': 1, '5': 5, '10': 'mac4'},
    {'1': 'mac_5', '3': 47, '4': 1, '5': 5, '10': 'mac5'},
    {'1': 'dtu_ap_ssid', '3': 48, '4': 1, '5': 9, '10': 'dtuApSsid'},
    {'1': 'dtu_ap_pass', '3': 49, '4': 1, '5': 9, '10': 'dtuApPass'},
    {'1': 'app_page', '3': 50, '4': 1, '5': 5, '10': 'appPage'},
  ],
};

/// Descriptor for `SetConfigResDTO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setConfigResDTODescriptor = $convert.base64Decode(
    'Cg9TZXRDb25maWdSZXNEVE8SFgoGb2Zmc2V0GAEgASgFUgZvZmZzZXQSEgoEdGltZRgCIAEoDV'
    'IEdGltZRIjCg1sb2NrX3Bhc3N3b3JkGAMgASgFUgxsb2NrUGFzc3dvcmQSGwoJbG9ja190aW1l'
    'GAQgASgFUghsb2NrVGltZRIuChNsaW1pdF9wb3dlcl9teXBvd2VyGAUgASgFUhFsaW1pdFBvd2'
    'VyTXlwb3dlchIvChR6ZXJvX2V4cG9ydF80MzNfYWRkchgGIAEoBVIRemVyb0V4cG9ydDQzM0Fk'
    'ZHISLAoSemVyb19leHBvcnRfZW5hYmxlGAcgASgFUhB6ZXJvRXhwb3J0RW5hYmxlEiUKDm5ldG'
    '1vZGVfc2VsZWN0GAggASgFUg1uZXRtb2RlU2VsZWN0EiUKDmNoYW5uZWxfc2VsZWN0GAkgASgF'
    'Ug1jaGFubmVsU2VsZWN0EigKEHNlcnZlcl9zZW5kX3RpbWUYCiABKAVSDnNlcnZlclNlbmRUaW'
    '1lEh4KCnNlcnZlcnBvcnQYCyABKAVSCnNlcnZlcnBvcnQSFwoHYXBuX3NldBgMIAEoCVIGYXBu'
    'U2V0Eh0KCm1ldGVyX2tpbmQYDSABKAlSCW1ldGVyS2luZBInCg9tZXRlcl9pbnRlcmZhY2UYDi'
    'ABKAlSDm1ldGVySW50ZXJmYWNlEhsKCXdpZmlfc3NpZBgPIAEoCVIId2lmaVNzaWQSIwoNd2lm'
    'aV9wYXNzd29yZBgQIAEoCVIMd2lmaVBhc3N3b3JkEiwKEnNlcnZlcl9kb21haW5fbmFtZRgRIA'
    'EoCVIQc2VydmVyRG9tYWluTmFtZRIZCghpbnZfdHlwZRgSIAEoBVIHaW52VHlwZRIVCgZkdHVf'
    'c24YEyABKAlSBWR0dVNuEiEKDGFjY2Vzc19tb2RlbBgUIAEoBVILYWNjZXNzTW9kZWwSEwoFbW'
    'FjXzAYFSABKAVSBG1hYzASEwoFbWFjXzEYFiABKAVSBG1hYzESEwoFbWFjXzIYFyABKAVSBG1h'
    'YzISEwoFbWFjXzMYGCABKAVSBG1hYzMSHwoLZGhjcF9zd2l0Y2gYGSABKAVSCmRoY3BTd2l0Y2'
    'gSGgoJaXBfYWRkcl8wGBogASgFUgdpcEFkZHIwEhoKCWlwX2FkZHJfMRgbIAEoBVIHaXBBZGRy'
    'MRIaCglpcF9hZGRyXzIYHCABKAVSB2lwQWRkcjISGgoJaXBfYWRkcl8zGB0gASgFUgdpcEFkZH'
    'IzEiIKDXN1Ym5ldF9tYXNrXzAYHiABKAVSC3N1Ym5ldE1hc2swEiIKDXN1Ym5ldF9tYXNrXzEY'
    'HyABKAVSC3N1Ym5ldE1hc2sxEiIKDXN1Ym5ldF9tYXNrXzIYICABKAVSC3N1Ym5ldE1hc2syEi'
    'IKDXN1Ym5ldF9tYXNrXzMYISABKAVSC3N1Ym5ldE1hc2szEioKEWRlZmF1bHRfZ2F0ZXdheV8w'
    'GCIgASgFUg9kZWZhdWx0R2F0ZXdheTASKgoRZGVmYXVsdF9nYXRld2F5XzEYIyABKAVSD2RlZm'
    'F1bHRHYXRld2F5MRIqChFkZWZhdWx0X2dhdGV3YXlfMhgkIAEoBVIPZGVmYXVsdEdhdGV3YXky'
    'EioKEWRlZmF1bHRfZ2F0ZXdheV8zGCUgASgFUg9kZWZhdWx0R2F0ZXdheTMSGQoIYXBuX25hbW'
    'UYJiABKAlSB2Fwbk5hbWUSIQoMYXBuX3Bhc3N3b3JkGCcgASgJUgthcG5QYXNzd29yZBIsChJz'
    'dWIxZ19zd2VlcF9zd2l0Y2gYKCABKAVSEHN1YjFnU3dlZXBTd2l0Y2gSLAoSc3ViMWdfd29ya1'
    '9jaGFubmVsGCkgASgFUhBzdWIxZ1dvcmtDaGFubmVsEh4KC2NhYmxlX2Ruc18wGCogASgFUglj'
    'YWJsZURuczASHgoLY2FibGVfZG5zXzEYKyABKAVSCWNhYmxlRG5zMRIeCgtjYWJsZV9kbnNfMh'
    'gsIAEoBVIJY2FibGVEbnMyEh4KC2NhYmxlX2Ruc18zGC0gASgFUgljYWJsZURuczMSEwoFbWFj'
    'XzQYLiABKAVSBG1hYzQSEwoFbWFjXzUYLyABKAVSBG1hYzUSHgoLZHR1X2FwX3NzaWQYMCABKA'
    'lSCWR0dUFwU3NpZBIeCgtkdHVfYXBfcGFzcxgxIAEoCVIJZHR1QXBQYXNzEhkKCGFwcF9wYWdl'
    'GDIgASgFUgdhcHBQYWdl');

@$core.Deprecated('Use setConfigReqDTODescriptor instead')
const SetConfigReqDTO$json = {
  '1': 'SetConfigReqDTO',
  '2': [
    {'1': 'offset', '3': 1, '4': 1, '5': 5, '10': 'offset'},
    {'1': 'time', '3': 2, '4': 1, '5': 13, '10': 'time'},
    {'1': 'error_code', '3': 3, '4': 1, '5': 5, '10': 'errorCode'},
  ],
};

/// Descriptor for `SetConfigReqDTO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setConfigReqDTODescriptor = $convert.base64Decode(
    'Cg9TZXRDb25maWdSZXFEVE8SFgoGb2Zmc2V0GAEgASgFUgZvZmZzZXQSEgoEdGltZRgCIAEoDV'
    'IEdGltZRIdCgplcnJvcl9jb2RlGAMgASgFUgllcnJvckNvZGU=');

