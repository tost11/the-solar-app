//
//  Generated code. Do not modify.
//  source: CommandPB.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use commandResDTODescriptor instead')
const CommandResDTO$json = {
  '1': 'CommandResDTO',
  '2': [
    {'1': 'time', '3': 1, '4': 1, '5': 5, '10': 'time'},
    {'1': 'action', '3': 2, '4': 1, '5': 5, '10': 'action'},
    {'1': 'dev_kind', '3': 3, '4': 1, '5': 5, '10': 'devKind'},
    {'1': 'package_nub', '3': 4, '4': 1, '5': 5, '10': 'packageNub'},
    {'1': 'package_now', '3': 5, '4': 1, '5': 5, '10': 'packageNow'},
    {'1': 'tid', '3': 6, '4': 1, '5': 3, '10': 'tid'},
    {'1': 'data', '3': 7, '4': 1, '5': 9, '10': 'data'},
    {'1': 'es_to_sn', '3': 8, '4': 3, '5': 9, '10': 'esToSn'},
    {'1': 'mi_to_sn', '3': 9, '4': 3, '5': 3, '10': 'miToSn'},
    {'1': 'system_total_a', '3': 10, '4': 1, '5': 5, '10': 'systemTotalA'},
    {'1': 'system_total_b', '3': 11, '4': 1, '5': 5, '10': 'systemTotalB'},
    {'1': 'system_total_c', '3': 12, '4': 1, '5': 5, '10': 'systemTotalC'},
    {'1': 'mi_sn_item_a', '3': 13, '4': 3, '5': 3, '10': 'miSnItemA'},
    {'1': 'mi_sn_item_b', '3': 14, '4': 3, '5': 3, '10': 'miSnItemB'},
    {'1': 'mi_sn_item_c', '3': 15, '4': 3, '5': 3, '10': 'miSnItemC'},
  ],
};

/// Descriptor for `CommandResDTO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandResDTODescriptor = $convert.base64Decode(
    'Cg1Db21tYW5kUmVzRFRPEhIKBHRpbWUYASABKAVSBHRpbWUSFgoGYWN0aW9uGAIgASgFUgZhY3'
    'Rpb24SGQoIZGV2X2tpbmQYAyABKAVSB2RldktpbmQSHwoLcGFja2FnZV9udWIYBCABKAVSCnBh'
    'Y2thZ2VOdWISHwoLcGFja2FnZV9ub3cYBSABKAVSCnBhY2thZ2VOb3cSEAoDdGlkGAYgASgDUg'
    'N0aWQSEgoEZGF0YRgHIAEoCVIEZGF0YRIYCghlc190b19zbhgIIAMoCVIGZXNUb1NuEhgKCG1p'
    'X3RvX3NuGAkgAygDUgZtaVRvU24SJAoOc3lzdGVtX3RvdGFsX2EYCiABKAVSDHN5c3RlbVRvdG'
    'FsQRIkCg5zeXN0ZW1fdG90YWxfYhgLIAEoBVIMc3lzdGVtVG90YWxCEiQKDnN5c3RlbV90b3Rh'
    'bF9jGAwgASgFUgxzeXN0ZW1Ub3RhbEMSHwoMbWlfc25faXRlbV9hGA0gAygDUgltaVNuSXRlbU'
    'ESHwoMbWlfc25faXRlbV9iGA4gAygDUgltaVNuSXRlbUISHwoMbWlfc25faXRlbV9jGA8gAygD'
    'UgltaVNuSXRlbUM=');

@$core.Deprecated('Use commandReqDTODescriptor instead')
const CommandReqDTO$json = {
  '1': 'CommandReqDTO',
  '2': [
    {'1': 'dtu_sn', '3': 1, '4': 1, '5': 9, '10': 'dtuSn'},
    {'1': 'time', '3': 2, '4': 1, '5': 5, '10': 'time'},
    {'1': 'action', '3': 3, '4': 1, '5': 5, '10': 'action'},
    {'1': 'package_now', '3': 4, '4': 1, '5': 5, '10': 'packageNow'},
    {'1': 'err_code', '3': 5, '4': 1, '5': 5, '10': 'errCode'},
    {'1': 'tid', '3': 6, '4': 1, '5': 3, '10': 'tid'},
  ],
};

/// Descriptor for `CommandReqDTO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandReqDTODescriptor = $convert.base64Decode(
    'Cg1Db21tYW5kUmVxRFRPEhUKBmR0dV9zbhgBIAEoCVIFZHR1U24SEgoEdGltZRgCIAEoBVIEdG'
    'ltZRIWCgZhY3Rpb24YAyABKAVSBmFjdGlvbhIfCgtwYWNrYWdlX25vdxgEIAEoBVIKcGFja2Fn'
    'ZU5vdxIZCghlcnJfY29kZRgFIAEoBVIHZXJyQ29kZRIQCgN0aWQYBiABKANSA3RpZA==');

@$core.Deprecated('Use eSOperatingStatusMODescriptor instead')
const ESOperatingStatusMO$json = {
  '1': 'ESOperatingStatusMO',
  '2': [
    {'1': 'es_sn', '3': 1, '4': 1, '5': 9, '10': 'esSn'},
    {'1': 'progress_rate', '3': 2, '4': 1, '5': 5, '10': 'progressRate'},
  ],
};

/// Descriptor for `ESOperatingStatusMO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List eSOperatingStatusMODescriptor = $convert.base64Decode(
    'ChNFU09wZXJhdGluZ1N0YXR1c01PEhMKBWVzX3NuGAEgASgJUgRlc1NuEiMKDXByb2dyZXNzX3'
    'JhdGUYAiABKAVSDHByb2dyZXNzUmF0ZQ==');

@$core.Deprecated('Use mIOperatingStatusMODescriptor instead')
const MIOperatingStatusMO$json = {
  '1': 'MIOperatingStatusMO',
  '2': [
    {'1': 'mi_sn', '3': 1, '4': 1, '5': 3, '10': 'miSn'},
    {'1': 'progress_rate', '3': 2, '4': 1, '5': 5, '10': 'progressRate'},
  ],
};

/// Descriptor for `MIOperatingStatusMO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mIOperatingStatusMODescriptor = $convert.base64Decode(
    'ChNNSU9wZXJhdGluZ1N0YXR1c01PEhMKBW1pX3NuGAEgASgDUgRtaVNuEiMKDXByb2dyZXNzX3'
    'JhdGUYAiABKAVSDHByb2dyZXNzUmF0ZQ==');

@$core.Deprecated('Use mIErrorStatusMODescriptor instead')
const MIErrorStatusMO$json = {
  '1': 'MIErrorStatusMO',
  '2': [
    {'1': 'mi_sn', '3': 1, '4': 1, '5': 3, '10': 'miSn'},
    {'1': 'error_code', '3': 2, '4': 1, '5': 3, '10': 'errorCode'},
  ],
};

/// Descriptor for `MIErrorStatusMO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mIErrorStatusMODescriptor = $convert.base64Decode(
    'Cg9NSUVycm9yU3RhdHVzTU8SEwoFbWlfc24YASABKANSBG1pU24SHQoKZXJyb3JfY29kZRgCIA'
    'EoA1IJZXJyb3JDb2Rl');

@$core.Deprecated('Use eSSucStatusMODescriptor instead')
const ESSucStatusMO$json = {
  '1': 'ESSucStatusMO',
  '2': [
    {'1': 'es_sn', '3': 1, '4': 1, '5': 9, '10': 'esSn'},
  ],
};

/// Descriptor for `ESSucStatusMO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List eSSucStatusMODescriptor = $convert.base64Decode(
    'Cg1FU1N1Y1N0YXR1c01PEhMKBWVzX3NuGAEgASgJUgRlc1Nu');

@$core.Deprecated('Use eSErrorStatusMODescriptor instead')
const ESErrorStatusMO$json = {
  '1': 'ESErrorStatusMO',
  '2': [
    {'1': 'es_sn', '3': 1, '4': 1, '5': 9, '10': 'esSn'},
    {'1': 'error_code', '3': 2, '4': 1, '5': 3, '10': 'errorCode'},
  ],
};

/// Descriptor for `ESErrorStatusMO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List eSErrorStatusMODescriptor = $convert.base64Decode(
    'Cg9FU0Vycm9yU3RhdHVzTU8SEwoFZXNfc24YASABKAlSBGVzU24SHQoKZXJyb3JfY29kZRgCIA'
    'EoA1IJZXJyb3JDb2Rl');

@$core.Deprecated('Use commandStatusReqDTODescriptor instead')
const CommandStatusReqDTO$json = {
  '1': 'CommandStatusReqDTO',
  '2': [
    {'1': 'dtu_sn', '3': 1, '4': 1, '5': 9, '10': 'dtuSn'},
    {'1': 'time', '3': 2, '4': 1, '5': 5, '10': 'time'},
    {'1': 'action', '3': 3, '4': 1, '5': 5, '10': 'action'},
    {'1': 'package_nub', '3': 4, '4': 1, '5': 5, '10': 'packageNub'},
    {'1': 'package_now', '3': 5, '4': 1, '5': 5, '10': 'packageNow'},
    {'1': 'tid', '3': 6, '4': 1, '5': 3, '10': 'tid'},
    {'1': 'es_sns_sucs', '3': 7, '4': 3, '5': 9, '10': 'esSnsSucs'},
    {'1': 'mi_sns_sucs', '3': 8, '4': 3, '5': 3, '10': 'miSnsSucs'},
    {'1': 'es_sns_failds', '3': 9, '4': 3, '5': 9, '10': 'esSnsFailds'},
    {'1': 'mi_sns_failds', '3': 10, '4': 3, '5': 3, '10': 'miSnsFailds'},
    {'1': 'es_mOperatingStatus', '3': 11, '4': 3, '5': 11, '6': '.ESOperatingStatusMO', '10': 'esMOperatingStatus'},
    {'1': 'mi_mOperatingStatus', '3': 12, '4': 3, '5': 11, '6': '.MIOperatingStatusMO', '10': 'miMOperatingStatus'},
    {'1': 'mi_mErrorStatus', '3': 13, '4': 3, '5': 11, '6': '.MIErrorStatusMO', '10': 'miMErrorStatus'},
    {'1': 'es_mSucStatus', '3': 14, '4': 3, '5': 11, '6': '.ESSucStatusMO', '10': 'esMSucStatus'},
    {'1': 'es_mErrorStatus', '3': 15, '4': 3, '5': 11, '6': '.ESErrorStatusMO', '10': 'esMErrorStatus'},
  ],
};

/// Descriptor for `CommandStatusReqDTO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandStatusReqDTODescriptor = $convert.base64Decode(
    'ChNDb21tYW5kU3RhdHVzUmVxRFRPEhUKBmR0dV9zbhgBIAEoCVIFZHR1U24SEgoEdGltZRgCIA'
    'EoBVIEdGltZRIWCgZhY3Rpb24YAyABKAVSBmFjdGlvbhIfCgtwYWNrYWdlX251YhgEIAEoBVIK'
    'cGFja2FnZU51YhIfCgtwYWNrYWdlX25vdxgFIAEoBVIKcGFja2FnZU5vdxIQCgN0aWQYBiABKA'
    'NSA3RpZBIeCgtlc19zbnNfc3VjcxgHIAMoCVIJZXNTbnNTdWNzEh4KC21pX3Nuc19zdWNzGAgg'
    'AygDUgltaVNuc1N1Y3MSIgoNZXNfc25zX2ZhaWxkcxgJIAMoCVILZXNTbnNGYWlsZHMSIgoNbW'
    'lfc25zX2ZhaWxkcxgKIAMoA1ILbWlTbnNGYWlsZHMSRQoTZXNfbU9wZXJhdGluZ1N0YXR1cxgL'
    'IAMoCzIULkVTT3BlcmF0aW5nU3RhdHVzTU9SEmVzTU9wZXJhdGluZ1N0YXR1cxJFChNtaV9tT3'
    'BlcmF0aW5nU3RhdHVzGAwgAygLMhQuTUlPcGVyYXRpbmdTdGF0dXNNT1ISbWlNT3BlcmF0aW5n'
    'U3RhdHVzEjkKD21pX21FcnJvclN0YXR1cxgNIAMoCzIQLk1JRXJyb3JTdGF0dXNNT1IObWlNRX'
    'Jyb3JTdGF0dXMSMwoNZXNfbVN1Y1N0YXR1cxgOIAMoCzIOLkVTU3VjU3RhdHVzTU9SDGVzTVN1'
    'Y1N0YXR1cxI5Cg9lc19tRXJyb3JTdGF0dXMYDyADKAsyEC5FU0Vycm9yU3RhdHVzTU9SDmVzTU'
    'Vycm9yU3RhdHVz');

@$core.Deprecated('Use commandStatusResDTODescriptor instead')
const CommandStatusResDTO$json = {
  '1': 'CommandStatusResDTO',
  '2': [
    {'1': 'time', '3': 1, '4': 1, '5': 5, '10': 'time'},
    {'1': 'action', '3': 2, '4': 1, '5': 5, '10': 'action'},
    {'1': 'package_now', '3': 3, '4': 1, '5': 5, '10': 'packageNow'},
    {'1': 'tid', '3': 4, '4': 1, '5': 3, '10': 'tid'},
    {'1': 'err_code', '3': 5, '4': 1, '5': 5, '10': 'errCode'},
  ],
};

/// Descriptor for `CommandStatusResDTO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandStatusResDTODescriptor = $convert.base64Decode(
    'ChNDb21tYW5kU3RhdHVzUmVzRFRPEhIKBHRpbWUYASABKAVSBHRpbWUSFgoGYWN0aW9uGAIgAS'
    'gFUgZhY3Rpb24SHwoLcGFja2FnZV9ub3cYAyABKAVSCnBhY2thZ2VOb3cSEAoDdGlkGAQgASgD'
    'UgN0aWQSGQoIZXJyX2NvZGUYBSABKAVSB2VyckNvZGU=');

