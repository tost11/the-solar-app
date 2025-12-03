//
//  Generated code. Do not modify.
//  source: NetworkInfo.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use networkInfoReqDTODescriptor instead')
const NetworkInfoReqDTO$json = {
  '1': 'NetworkInfoReqDTO',
  '2': [
    {'1': 'dtu_sn', '3': 1, '4': 1, '5': 9, '10': 'dtuSn'},
    {'1': 'time', '3': 2, '4': 1, '5': 13, '10': 'time'},
    {'1': 'net_set_mod', '3': 3, '4': 1, '5': 5, '10': 'netSetMod'},
    {'1': 'net_set_time', '3': 4, '4': 1, '5': 5, '10': 'netSetTime'},
    {'1': 'net_set_state', '3': 5, '4': 1, '5': 5, '10': 'netSetState'},
    {'1': 'net_work_mod', '3': 6, '4': 1, '5': 5, '10': 'netWorkMod'},
    {'1': 'net_work_time', '3': 7, '4': 1, '5': 5, '10': 'netWorkTime'},
    {'1': 'csq', '3': 8, '4': 1, '5': 5, '10': 'csq'},
    {'1': 'net_work_state', '3': 9, '4': 1, '5': 5, '10': 'netWorkState'},
    {'1': 'ap_set_state', '3': 10, '4': 1, '5': 5, '10': 'apSetState'},
  ],
};

/// Descriptor for `NetworkInfoReqDTO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List networkInfoReqDTODescriptor = $convert.base64Decode(
    'ChFOZXR3b3JrSW5mb1JlcURUTxIVCgZkdHVfc24YASABKAlSBWR0dVNuEhIKBHRpbWUYAiABKA'
    '1SBHRpbWUSHgoLbmV0X3NldF9tb2QYAyABKAVSCW5ldFNldE1vZBIgCgxuZXRfc2V0X3RpbWUY'
    'BCABKAVSCm5ldFNldFRpbWUSIgoNbmV0X3NldF9zdGF0ZRgFIAEoBVILbmV0U2V0U3RhdGUSIA'
    'oMbmV0X3dvcmtfbW9kGAYgASgFUgpuZXRXb3JrTW9kEiIKDW5ldF93b3JrX3RpbWUYByABKAVS'
    'C25ldFdvcmtUaW1lEhAKA2NzcRgIIAEoBVIDY3NxEiQKDm5ldF93b3JrX3N0YXRlGAkgASgFUg'
    'xuZXRXb3JrU3RhdGUSIAoMYXBfc2V0X3N0YXRlGAogASgFUgphcFNldFN0YXRl');

@$core.Deprecated('Use networkInfoResDTODescriptor instead')
const NetworkInfoResDTO$json = {
  '1': 'NetworkInfoResDTO',
  '2': [
    {'1': 'offset', '3': 1, '4': 1, '5': 5, '10': 'offset'},
    {'1': 'time', '3': 2, '4': 1, '5': 13, '10': 'time'},
  ],
};

/// Descriptor for `NetworkInfoResDTO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List networkInfoResDTODescriptor = $convert.base64Decode(
    'ChFOZXR3b3JrSW5mb1Jlc0RUTxIWCgZvZmZzZXQYASABKAVSBm9mZnNldBISCgR0aW1lGAIgAS'
    'gNUgR0aW1l');

