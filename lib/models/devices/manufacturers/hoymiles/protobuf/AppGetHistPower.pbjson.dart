//
//  Generated code. Do not modify.
//  source: AppGetHistPower.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use appGetHistPowerResDTODescriptor instead')
const AppGetHistPowerResDTO$json = {
  '1': 'AppGetHistPowerResDTO',
  '2': [
    {'1': 'cp', '3': 1, '4': 1, '5': 5, '10': 'cp'},
    {'1': 'offset', '3': 2, '4': 1, '5': 5, '10': 'offset'},
    {'1': 'requested_time', '3': 3, '4': 1, '5': 13, '10': 'requestedTime'},
    {'1': 'requested_day', '3': 4, '4': 1, '5': 13, '10': 'requestedDay'},
  ],
};

/// Descriptor for `AppGetHistPowerResDTO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List appGetHistPowerResDTODescriptor = $convert.base64Decode(
    'ChVBcHBHZXRIaXN0UG93ZXJSZXNEVE8SDgoCY3AYASABKAVSAmNwEhYKBm9mZnNldBgCIAEoBV'
    'IGb2Zmc2V0EiUKDnJlcXVlc3RlZF90aW1lGAMgASgNUg1yZXF1ZXN0ZWRUaW1lEiMKDXJlcXVl'
    'c3RlZF9kYXkYBCABKA1SDHJlcXVlc3RlZERheQ==');

@$core.Deprecated('Use appGetHistPowerReqDTODescriptor instead')
const AppGetHistPowerReqDTO$json = {
  '1': 'AppGetHistPowerReqDTO',
  '2': [
    {'1': 'serial_number', '3': 1, '4': 1, '5': 3, '10': 'serialNumber'},
    {'1': 'ap', '3': 2, '4': 1, '5': 5, '10': 'ap'},
    {'1': 'cp', '3': 3, '4': 1, '5': 5, '10': 'cp'},
    {'1': 'offset', '3': 4, '4': 1, '5': 5, '10': 'offset'},
    {'1': 'request_time', '3': 5, '4': 1, '5': 13, '10': 'requestTime'},
    {'1': 'start_time', '3': 6, '4': 1, '5': 13, '10': 'startTime'},
    {'1': 'long_term_start', '3': 7, '4': 1, '5': 13, '10': 'longTermStart'},
    {'1': 'absolute_start', '3': 8, '4': 1, '5': 13, '10': 'absoluteStart'},
    {'1': 'step_time', '3': 9, '4': 1, '5': 13, '10': 'stepTime'},
    {'1': 'relative_power', '3': 10, '4': 1, '5': 13, '10': 'relativePower'},
    {'1': 'total_energy', '3': 11, '4': 1, '5': 13, '10': 'totalEnergy'},
    {'1': 'daily_energy', '3': 12, '4': 1, '5': 13, '10': 'dailyEnergy'},
    {'1': 'power_array', '3': 13, '4': 3, '5': 5, '10': 'powerArray'},
    {'1': 'warning_number', '3': 14, '4': 1, '5': 13, '10': 'warningNumber'},
  ],
};

/// Descriptor for `AppGetHistPowerReqDTO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List appGetHistPowerReqDTODescriptor = $convert.base64Decode(
    'ChVBcHBHZXRIaXN0UG93ZXJSZXFEVE8SIwoNc2VyaWFsX251bWJlchgBIAEoA1IMc2VyaWFsTn'
    'VtYmVyEg4KAmFwGAIgASgFUgJhcBIOCgJjcBgDIAEoBVICY3ASFgoGb2Zmc2V0GAQgASgFUgZv'
    'ZmZzZXQSIQoMcmVxdWVzdF90aW1lGAUgASgNUgtyZXF1ZXN0VGltZRIdCgpzdGFydF90aW1lGA'
    'YgASgNUglzdGFydFRpbWUSJgoPbG9uZ190ZXJtX3N0YXJ0GAcgASgNUg1sb25nVGVybVN0YXJ0'
    'EiUKDmFic29sdXRlX3N0YXJ0GAggASgNUg1hYnNvbHV0ZVN0YXJ0EhsKCXN0ZXBfdGltZRgJIA'
    'EoDVIIc3RlcFRpbWUSJQoOcmVsYXRpdmVfcG93ZXIYCiABKA1SDXJlbGF0aXZlUG93ZXISIQoM'
    'dG90YWxfZW5lcmd5GAsgASgNUgt0b3RhbEVuZXJneRIhCgxkYWlseV9lbmVyZ3kYDCABKA1SC2'
    'RhaWx5RW5lcmd5Eh8KC3Bvd2VyX2FycmF5GA0gAygFUgpwb3dlckFycmF5EiUKDndhcm5pbmdf'
    'bnVtYmVyGA4gASgNUg13YXJuaW5nTnVtYmVy');

