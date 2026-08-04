//
//  Generated code. Do not modify.
//  source: AppGetHistED.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use appGetHistEDResDTODescriptor instead')
const AppGetHistEDResDTO$json = {
  '1': 'AppGetHistEDResDTO',
  '2': [
    {'1': 'cp', '3': 1, '4': 1, '5': 5, '10': 'cp'},
    {'1': 'oft', '3': 2, '4': 1, '5': 5, '10': 'oft'},
    {'1': 'time', '3': 3, '4': 1, '5': 13, '10': 'time'},
  ],
};

/// Descriptor for `AppGetHistEDResDTO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List appGetHistEDResDTODescriptor = $convert.base64Decode(
    'ChJBcHBHZXRIaXN0RURSZXNEVE8SDgoCY3AYASABKAVSAmNwEhAKA29mdBgCIAEoBVIDb2Z0Eh'
    'IKBHRpbWUYAyABKA1SBHRpbWU=');

@$core.Deprecated('Use aPPEnergyInfoMODescriptor instead')
const APPEnergyInfoMO$json = {
  '1': 'APPEnergyInfoMO',
  '2': [
    {'1': 'ed', '3': 1, '4': 1, '5': 13, '10': 'ed'},
    {'1': 'r_time', '3': 2, '4': 1, '5': 13, '10': 'rTime'},
  ],
};

/// Descriptor for `APPEnergyInfoMO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aPPEnergyInfoMODescriptor = $convert.base64Decode(
    'Cg9BUFBFbmVyZ3lJbmZvTU8SDgoCZWQYASABKA1SAmVkEhUKBnJfdGltZRgCIAEoDVIFclRpbW'
    'U=');

@$core.Deprecated('Use appGetHistEDReqDTODescriptor instead')
const AppGetHistEDReqDTO$json = {
  '1': 'AppGetHistEDReqDTO',
  '2': [
    {'1': 'sn', '3': 1, '4': 1, '5': 3, '10': 'sn'},
    {'1': 'oft', '3': 2, '4': 1, '5': 5, '10': 'oft'},
    {'1': 'time', '3': 3, '4': 1, '5': 13, '10': 'time'},
    {'1': 'energ', '3': 4, '4': 3, '5': 11, '6': '.APPEnergyInfoMO', '10': 'energ'},
  ],
};

/// Descriptor for `AppGetHistEDReqDTO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List appGetHistEDReqDTODescriptor = $convert.base64Decode(
    'ChJBcHBHZXRIaXN0RURSZXFEVE8SDgoCc24YASABKANSAnNuEhAKA29mdBgCIAEoBVIDb2Z0Eh'
    'IKBHRpbWUYAyABKA1SBHRpbWUSJgoFZW5lcmcYBCADKAsyEC5BUFBFbmVyZ3lJbmZvTU9SBWVu'
    'ZXJn');

