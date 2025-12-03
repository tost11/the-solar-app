//
//  Generated code. Do not modify.
//  source: GetConfig.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use getConfigResDTODescriptor instead')
const GetConfigResDTO$json = {
  '1': 'GetConfigResDTO',
  '2': [
    {'1': 'offset', '3': 1, '4': 1, '5': 5, '10': 'offset'},
    {'1': 'time', '3': 2, '4': 1, '5': 13, '10': 'time'},
  ],
};

/// Descriptor for `GetConfigResDTO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getConfigResDTODescriptor = $convert.base64Decode(
    'Cg9HZXRDb25maWdSZXNEVE8SFgoGb2Zmc2V0GAEgASgFUgZvZmZzZXQSEgoEdGltZRgCIAEoDV'
    'IEdGltZQ==');

@$core.Deprecated('Use getConfigReqDTODescriptor instead')
const GetConfigReqDTO$json = {
  '1': 'GetConfigReqDTO',
  '2': [
    {'1': 'request_offset', '3': 1, '4': 1, '5': 5, '10': 'requestOffset'},
    {'1': 'request_time', '3': 2, '4': 1, '5': 13, '10': 'requestTime'},
    {'1': 'lock_password', '3': 3, '4': 1, '5': 5, '10': 'lockPassword'},
    {'1': 'lock_time', '3': 4, '4': 1, '5': 5, '10': 'lockTime'},
    {'1': 'limit_power_mypower', '3': 5, '4': 1, '5': 5, '10': 'limitPowerMypower'},
    {'1': 'zero_export_433_addr', '3': 6, '4': 1, '5': 5, '10': 'zeroExport433Addr'},
    {'1': 'zero_export_enable', '3': 7, '4': 1, '5': 5, '10': 'zeroExportEnable'},
    {'1': 'netmode_select', '3': 8, '4': 1, '5': 5, '10': 'netmodeSelect'},
    {'1': 'channel_select', '3': 9, '4': 1, '5': 5, '10': 'channelSelect'},
    {'1': 'server_send_time', '3': 10, '4': 1, '5': 5, '10': 'serverSendTime'},
    {'1': 'wifi_rssi', '3': 11, '4': 1, '5': 5, '10': 'wifiRssi'},
    {'1': 'serverport', '3': 12, '4': 1, '5': 5, '10': 'serverport'},
    {'1': 'apn_set', '3': 13, '4': 1, '5': 9, '10': 'apnSet'},
    {'1': 'meter_kind', '3': 14, '4': 1, '5': 9, '10': 'meterKind'},
    {'1': 'meter_interface', '3': 15, '4': 1, '5': 9, '10': 'meterInterface'},
    {'1': 'wifi_ssid', '3': 16, '4': 1, '5': 9, '10': 'wifiSsid'},
    {'1': 'wifi_password', '3': 17, '4': 1, '5': 9, '10': 'wifiPassword'},
    {'1': 'server_domain_name', '3': 18, '4': 1, '5': 9, '10': 'serverDomainName'},
    {'1': 'inv_type', '3': 19, '4': 1, '5': 5, '10': 'invType'},
    {'1': 'dtu_sn', '3': 20, '4': 1, '5': 9, '10': 'dtuSn'},
    {'1': 'access_model', '3': 21, '4': 1, '5': 5, '10': 'accessModel'},
    {'1': 'mac_0', '3': 22, '4': 1, '5': 5, '10': 'mac0'},
    {'1': 'mac_1', '3': 23, '4': 1, '5': 5, '10': 'mac1'},
    {'1': 'mac_2', '3': 24, '4': 1, '5': 5, '10': 'mac2'},
    {'1': 'mac_3', '3': 25, '4': 1, '5': 5, '10': 'mac3'},
    {'1': 'dhcp_switch', '3': 26, '4': 1, '5': 5, '10': 'dhcpSwitch'},
    {'1': 'ip_addr_0', '3': 27, '4': 1, '5': 5, '10': 'ipAddr0'},
    {'1': 'ip_addr_1', '3': 28, '4': 1, '5': 5, '10': 'ipAddr1'},
    {'1': 'ip_addr_2', '3': 29, '4': 1, '5': 5, '10': 'ipAddr2'},
    {'1': 'ip_addr_3', '3': 30, '4': 1, '5': 5, '10': 'ipAddr3'},
    {'1': 'subnet_mask_0', '3': 31, '4': 1, '5': 5, '10': 'subnetMask0'},
    {'1': 'subnet_mask_1', '3': 32, '4': 1, '5': 5, '10': 'subnetMask1'},
    {'1': 'subnet_mask_2', '3': 33, '4': 1, '5': 5, '10': 'subnetMask2'},
    {'1': 'subnet_mask_3', '3': 34, '4': 1, '5': 5, '10': 'subnetMask3'},
    {'1': 'default_gateway_0', '3': 35, '4': 1, '5': 5, '10': 'defaultGateway0'},
    {'1': 'default_gateway_1', '3': 36, '4': 1, '5': 5, '10': 'defaultGateway1'},
    {'1': 'default_gateway_2', '3': 37, '4': 1, '5': 5, '10': 'defaultGateway2'},
    {'1': 'default_gateway_3', '3': 38, '4': 1, '5': 5, '10': 'defaultGateway3'},
    {'1': 'ka_nub', '3': 39, '4': 1, '5': 9, '10': 'kaNub'},
    {'1': 'apn_name', '3': 40, '4': 1, '5': 9, '10': 'apnName'},
    {'1': 'apn_password', '3': 41, '4': 1, '5': 9, '10': 'apnPassword'},
    {'1': 'sub1g_sweep_switch', '3': 42, '4': 1, '5': 5, '10': 'sub1gSweepSwitch'},
    {'1': 'sub1g_work_channel', '3': 43, '4': 1, '5': 5, '10': 'sub1gWorkChannel'},
    {'1': 'cable_dns_0', '3': 44, '4': 1, '5': 5, '10': 'cableDns0'},
    {'1': 'cable_dns_1', '3': 45, '4': 1, '5': 5, '10': 'cableDns1'},
    {'1': 'cable_dns_2', '3': 46, '4': 1, '5': 5, '10': 'cableDns2'},
    {'1': 'cable_dns_3', '3': 47, '4': 1, '5': 5, '10': 'cableDns3'},
    {'1': 'wifi_ip_addr_0', '3': 48, '4': 1, '5': 5, '10': 'wifiIpAddr0'},
    {'1': 'wifi_ip_addr_1', '3': 49, '4': 1, '5': 5, '10': 'wifiIpAddr1'},
    {'1': 'wifi_ip_addr_2', '3': 50, '4': 1, '5': 5, '10': 'wifiIpAddr2'},
    {'1': 'wifi_ip_addr_3', '3': 51, '4': 1, '5': 5, '10': 'wifiIpAddr3'},
    {'1': 'mac_4', '3': 52, '4': 1, '5': 5, '10': 'mac4'},
    {'1': 'mac_5', '3': 53, '4': 1, '5': 5, '10': 'mac5'},
    {'1': 'wifi_mac_0', '3': 54, '4': 1, '5': 5, '10': 'wifiMac0'},
    {'1': 'wifi_mac_1', '3': 55, '4': 1, '5': 5, '10': 'wifiMac1'},
    {'1': 'wifi_mac_2', '3': 56, '4': 1, '5': 5, '10': 'wifiMac2'},
    {'1': 'wifi_mac_3', '3': 57, '4': 1, '5': 5, '10': 'wifiMac3'},
    {'1': 'wifi_mac_4', '3': 58, '4': 1, '5': 5, '10': 'wifiMac4'},
    {'1': 'wifi_mac_5', '3': 59, '4': 1, '5': 5, '10': 'wifiMac5'},
    {'1': 'gprs_imei', '3': 60, '4': 1, '5': 9, '10': 'gprsImei'},
    {'1': 'dtu_ap_ssid', '3': 61, '4': 1, '5': 9, '10': 'dtuApSsid'},
    {'1': 'dtu_ap_pass', '3': 62, '4': 1, '5': 9, '10': 'dtuApPass'},
  ],
};

/// Descriptor for `GetConfigReqDTO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getConfigReqDTODescriptor = $convert.base64Decode(
    'Cg9HZXRDb25maWdSZXFEVE8SJQoOcmVxdWVzdF9vZmZzZXQYASABKAVSDXJlcXVlc3RPZmZzZX'
    'QSIQoMcmVxdWVzdF90aW1lGAIgASgNUgtyZXF1ZXN0VGltZRIjCg1sb2NrX3Bhc3N3b3JkGAMg'
    'ASgFUgxsb2NrUGFzc3dvcmQSGwoJbG9ja190aW1lGAQgASgFUghsb2NrVGltZRIuChNsaW1pdF'
    '9wb3dlcl9teXBvd2VyGAUgASgFUhFsaW1pdFBvd2VyTXlwb3dlchIvChR6ZXJvX2V4cG9ydF80'
    'MzNfYWRkchgGIAEoBVIRemVyb0V4cG9ydDQzM0FkZHISLAoSemVyb19leHBvcnRfZW5hYmxlGA'
    'cgASgFUhB6ZXJvRXhwb3J0RW5hYmxlEiUKDm5ldG1vZGVfc2VsZWN0GAggASgFUg1uZXRtb2Rl'
    'U2VsZWN0EiUKDmNoYW5uZWxfc2VsZWN0GAkgASgFUg1jaGFubmVsU2VsZWN0EigKEHNlcnZlcl'
    '9zZW5kX3RpbWUYCiABKAVSDnNlcnZlclNlbmRUaW1lEhsKCXdpZmlfcnNzaRgLIAEoBVIId2lm'
    'aVJzc2kSHgoKc2VydmVycG9ydBgMIAEoBVIKc2VydmVycG9ydBIXCgdhcG5fc2V0GA0gASgJUg'
    'ZhcG5TZXQSHQoKbWV0ZXJfa2luZBgOIAEoCVIJbWV0ZXJLaW5kEicKD21ldGVyX2ludGVyZmFj'
    'ZRgPIAEoCVIObWV0ZXJJbnRlcmZhY2USGwoJd2lmaV9zc2lkGBAgASgJUgh3aWZpU3NpZBIjCg'
    '13aWZpX3Bhc3N3b3JkGBEgASgJUgx3aWZpUGFzc3dvcmQSLAoSc2VydmVyX2RvbWFpbl9uYW1l'
    'GBIgASgJUhBzZXJ2ZXJEb21haW5OYW1lEhkKCGludl90eXBlGBMgASgFUgdpbnZUeXBlEhUKBm'
    'R0dV9zbhgUIAEoCVIFZHR1U24SIQoMYWNjZXNzX21vZGVsGBUgASgFUgthY2Nlc3NNb2RlbBIT'
    'CgVtYWNfMBgWIAEoBVIEbWFjMBITCgVtYWNfMRgXIAEoBVIEbWFjMRITCgVtYWNfMhgYIAEoBV'
    'IEbWFjMhITCgVtYWNfMxgZIAEoBVIEbWFjMxIfCgtkaGNwX3N3aXRjaBgaIAEoBVIKZGhjcFN3'
    'aXRjaBIaCglpcF9hZGRyXzAYGyABKAVSB2lwQWRkcjASGgoJaXBfYWRkcl8xGBwgASgFUgdpcE'
    'FkZHIxEhoKCWlwX2FkZHJfMhgdIAEoBVIHaXBBZGRyMhIaCglpcF9hZGRyXzMYHiABKAVSB2lw'
    'QWRkcjMSIgoNc3VibmV0X21hc2tfMBgfIAEoBVILc3VibmV0TWFzazASIgoNc3VibmV0X21hc2'
    'tfMRggIAEoBVILc3VibmV0TWFzazESIgoNc3VibmV0X21hc2tfMhghIAEoBVILc3VibmV0TWFz'
    'azISIgoNc3VibmV0X21hc2tfMxgiIAEoBVILc3VibmV0TWFzazMSKgoRZGVmYXVsdF9nYXRld2'
    'F5XzAYIyABKAVSD2RlZmF1bHRHYXRld2F5MBIqChFkZWZhdWx0X2dhdGV3YXlfMRgkIAEoBVIP'
    'ZGVmYXVsdEdhdGV3YXkxEioKEWRlZmF1bHRfZ2F0ZXdheV8yGCUgASgFUg9kZWZhdWx0R2F0ZX'
    'dheTISKgoRZGVmYXVsdF9nYXRld2F5XzMYJiABKAVSD2RlZmF1bHRHYXRld2F5MxIVCgZrYV9u'
    'dWIYJyABKAlSBWthTnViEhkKCGFwbl9uYW1lGCggASgJUgdhcG5OYW1lEiEKDGFwbl9wYXNzd2'
    '9yZBgpIAEoCVILYXBuUGFzc3dvcmQSLAoSc3ViMWdfc3dlZXBfc3dpdGNoGCogASgFUhBzdWIx'
    'Z1N3ZWVwU3dpdGNoEiwKEnN1YjFnX3dvcmtfY2hhbm5lbBgrIAEoBVIQc3ViMWdXb3JrQ2hhbm'
    '5lbBIeCgtjYWJsZV9kbnNfMBgsIAEoBVIJY2FibGVEbnMwEh4KC2NhYmxlX2Ruc18xGC0gASgF'
    'UgljYWJsZURuczESHgoLY2FibGVfZG5zXzIYLiABKAVSCWNhYmxlRG5zMhIeCgtjYWJsZV9kbn'
    'NfMxgvIAEoBVIJY2FibGVEbnMzEiMKDndpZmlfaXBfYWRkcl8wGDAgASgFUgt3aWZpSXBBZGRy'
    'MBIjCg53aWZpX2lwX2FkZHJfMRgxIAEoBVILd2lmaUlwQWRkcjESIwoOd2lmaV9pcF9hZGRyXz'
    'IYMiABKAVSC3dpZmlJcEFkZHIyEiMKDndpZmlfaXBfYWRkcl8zGDMgASgFUgt3aWZpSXBBZGRy'
    'MxITCgVtYWNfNBg0IAEoBVIEbWFjNBITCgVtYWNfNRg1IAEoBVIEbWFjNRIcCgp3aWZpX21hY1'
    '8wGDYgASgFUgh3aWZpTWFjMBIcCgp3aWZpX21hY18xGDcgASgFUgh3aWZpTWFjMRIcCgp3aWZp'
    'X21hY18yGDggASgFUgh3aWZpTWFjMhIcCgp3aWZpX21hY18zGDkgASgFUgh3aWZpTWFjMxIcCg'
    'p3aWZpX21hY180GDogASgFUgh3aWZpTWFjNBIcCgp3aWZpX21hY181GDsgASgFUgh3aWZpTWFj'
    'NRIbCglncHJzX2ltZWkYPCABKAlSCGdwcnNJbWVpEh4KC2R0dV9hcF9zc2lkGD0gASgJUglkdH'
    'VBcFNzaWQSHgoLZHR1X2FwX3Bhc3MYPiABKAlSCWR0dUFwUGFzcw==');

