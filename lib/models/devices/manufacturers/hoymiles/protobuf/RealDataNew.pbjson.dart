//
//  Generated code. Do not modify.
//  source: RealDataNew.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use meterMODescriptor instead')
const MeterMO$json = {
  '1': 'MeterMO',
  '2': [
    {'1': 'device_type', '3': 1, '4': 1, '5': 5, '10': 'deviceType'},
    {'1': 'serial_number', '3': 2, '4': 1, '5': 3, '10': 'serialNumber'},
    {'1': 'phase_total_power', '3': 3, '4': 1, '5': 5, '10': 'phaseTotalPower'},
    {'1': 'phase_A_power', '3': 4, '4': 1, '5': 5, '10': 'phaseAPower'},
    {'1': 'phase_B_power', '3': 5, '4': 1, '5': 5, '10': 'phaseBPower'},
    {'1': 'phase_C_power', '3': 6, '4': 1, '5': 5, '10': 'phaseCPower'},
    {'1': 'power_factor_total', '3': 7, '4': 1, '5': 5, '10': 'powerFactorTotal'},
    {'1': 'energy_total_power', '3': 8, '4': 1, '5': 5, '10': 'energyTotalPower'},
    {'1': 'energy_phase_A', '3': 9, '4': 1, '5': 5, '10': 'energyPhaseA'},
    {'1': 'energy_phase_B', '3': 10, '4': 1, '5': 5, '10': 'energyPhaseB'},
    {'1': 'energy_phase_C', '3': 11, '4': 1, '5': 5, '10': 'energyPhaseC'},
    {'1': 'energy_total_consumed', '3': 12, '4': 1, '5': 5, '10': 'energyTotalConsumed'},
    {'1': 'energy_phase_A_consumed', '3': 13, '4': 1, '5': 5, '10': 'energyPhaseAConsumed'},
    {'1': 'energy_phase_B_consumed', '3': 14, '4': 1, '5': 5, '10': 'energyPhaseBConsumed'},
    {'1': 'energy_phase_C_consumed', '3': 15, '4': 1, '5': 5, '10': 'energyPhaseCConsumed'},
    {'1': 'fault_code', '3': 16, '4': 1, '5': 5, '10': 'faultCode'},
    {'1': 'voltage_phase_A', '3': 17, '4': 1, '5': 5, '10': 'voltagePhaseA'},
    {'1': 'voltage_phase_B', '3': 18, '4': 1, '5': 5, '10': 'voltagePhaseB'},
    {'1': 'voltage_phase_C', '3': 19, '4': 1, '5': 5, '10': 'voltagePhaseC'},
    {'1': 'current_phase_A', '3': 20, '4': 1, '5': 5, '10': 'currentPhaseA'},
    {'1': 'current_phase_B', '3': 21, '4': 1, '5': 5, '10': 'currentPhaseB'},
    {'1': 'current_phase_C', '3': 22, '4': 1, '5': 5, '10': 'currentPhaseC'},
    {'1': 'power_factor_phase_A', '3': 23, '4': 1, '5': 5, '10': 'powerFactorPhaseA'},
    {'1': 'power_factor_phase_B', '3': 24, '4': 1, '5': 5, '10': 'powerFactorPhaseB'},
    {'1': 'power_factor_phase_C', '3': 25, '4': 1, '5': 5, '10': 'powerFactorPhaseC'},
  ],
};

/// Descriptor for `MeterMO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meterMODescriptor = $convert.base64Decode(
    'CgdNZXRlck1PEh8KC2RldmljZV90eXBlGAEgASgFUgpkZXZpY2VUeXBlEiMKDXNlcmlhbF9udW'
    '1iZXIYAiABKANSDHNlcmlhbE51bWJlchIqChFwaGFzZV90b3RhbF9wb3dlchgDIAEoBVIPcGhh'
    'c2VUb3RhbFBvd2VyEiIKDXBoYXNlX0FfcG93ZXIYBCABKAVSC3BoYXNlQVBvd2VyEiIKDXBoYX'
    'NlX0JfcG93ZXIYBSABKAVSC3BoYXNlQlBvd2VyEiIKDXBoYXNlX0NfcG93ZXIYBiABKAVSC3Bo'
    'YXNlQ1Bvd2VyEiwKEnBvd2VyX2ZhY3Rvcl90b3RhbBgHIAEoBVIQcG93ZXJGYWN0b3JUb3RhbB'
    'IsChJlbmVyZ3lfdG90YWxfcG93ZXIYCCABKAVSEGVuZXJneVRvdGFsUG93ZXISJAoOZW5lcmd5'
    'X3BoYXNlX0EYCSABKAVSDGVuZXJneVBoYXNlQRIkCg5lbmVyZ3lfcGhhc2VfQhgKIAEoBVIMZW'
    '5lcmd5UGhhc2VCEiQKDmVuZXJneV9waGFzZV9DGAsgASgFUgxlbmVyZ3lQaGFzZUMSMgoVZW5l'
    'cmd5X3RvdGFsX2NvbnN1bWVkGAwgASgFUhNlbmVyZ3lUb3RhbENvbnN1bWVkEjUKF2VuZXJneV'
    '9waGFzZV9BX2NvbnN1bWVkGA0gASgFUhRlbmVyZ3lQaGFzZUFDb25zdW1lZBI1ChdlbmVyZ3lf'
    'cGhhc2VfQl9jb25zdW1lZBgOIAEoBVIUZW5lcmd5UGhhc2VCQ29uc3VtZWQSNQoXZW5lcmd5X3'
    'BoYXNlX0NfY29uc3VtZWQYDyABKAVSFGVuZXJneVBoYXNlQ0NvbnN1bWVkEh0KCmZhdWx0X2Nv'
    'ZGUYECABKAVSCWZhdWx0Q29kZRImCg92b2x0YWdlX3BoYXNlX0EYESABKAVSDXZvbHRhZ2VQaG'
    'FzZUESJgoPdm9sdGFnZV9waGFzZV9CGBIgASgFUg12b2x0YWdlUGhhc2VCEiYKD3ZvbHRhZ2Vf'
    'cGhhc2VfQxgTIAEoBVINdm9sdGFnZVBoYXNlQxImCg9jdXJyZW50X3BoYXNlX0EYFCABKAVSDW'
    'N1cnJlbnRQaGFzZUESJgoPY3VycmVudF9waGFzZV9CGBUgASgFUg1jdXJyZW50UGhhc2VCEiYK'
    'D2N1cnJlbnRfcGhhc2VfQxgWIAEoBVINY3VycmVudFBoYXNlQxIvChRwb3dlcl9mYWN0b3JfcG'
    'hhc2VfQRgXIAEoBVIRcG93ZXJGYWN0b3JQaGFzZUESLwoUcG93ZXJfZmFjdG9yX3BoYXNlX0IY'
    'GCABKAVSEXBvd2VyRmFjdG9yUGhhc2VCEi8KFHBvd2VyX2ZhY3Rvcl9waGFzZV9DGBkgASgFUh'
    'Fwb3dlckZhY3RvclBoYXNlQw==');

@$core.Deprecated('Use rpMODescriptor instead')
const RpMO$json = {
  '1': 'RpMO',
  '2': [
    {'1': 'serial_number', '3': 1, '4': 1, '5': 3, '10': 'serialNumber'},
    {'1': 'signature', '3': 2, '4': 1, '5': 5, '10': 'signature'},
    {'1': 'channel', '3': 3, '4': 1, '5': 5, '10': 'channel'},
    {'1': 'pv_number', '3': 4, '4': 1, '5': 5, '10': 'pvNumber'},
    {'1': 'link_status', '3': 5, '4': 1, '5': 5, '10': 'linkStatus'},
  ],
};

/// Descriptor for `RpMO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rpMODescriptor = $convert.base64Decode(
    'CgRScE1PEiMKDXNlcmlhbF9udW1iZXIYASABKANSDHNlcmlhbE51bWJlchIcCglzaWduYXR1cm'
    'UYAiABKAVSCXNpZ25hdHVyZRIYCgdjaGFubmVsGAMgASgFUgdjaGFubmVsEhsKCXB2X251bWJl'
    'chgEIAEoBVIIcHZOdW1iZXISHwoLbGlua19zdGF0dXMYBSABKAVSCmxpbmtTdGF0dXM=');

@$core.Deprecated('Use rSDMODescriptor instead')
const RSDMO$json = {
  '1': 'RSDMO',
  '2': [
    {'1': 'serial_number', '3': 1, '4': 1, '5': 3, '10': 'serialNumber'},
    {'1': 'firmware_version', '3': 2, '4': 1, '5': 5, '10': 'firmwareVersion'},
    {'1': 'voltage', '3': 3, '4': 1, '5': 5, '10': 'voltage'},
    {'1': 'power', '3': 4, '4': 1, '5': 5, '10': 'power'},
    {'1': 'temperature', '3': 5, '4': 1, '5': 5, '10': 'temperature'},
    {'1': 'warning_number', '3': 6, '4': 1, '5': 5, '10': 'warningNumber'},
    {'1': 'crc_checksum', '3': 7, '4': 1, '5': 5, '10': 'crcChecksum'},
    {'1': 'link_status', '3': 8, '4': 1, '5': 5, '10': 'linkStatus'},
  ],
};

/// Descriptor for `RSDMO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rSDMODescriptor = $convert.base64Decode(
    'CgVSU0RNTxIjCg1zZXJpYWxfbnVtYmVyGAEgASgDUgxzZXJpYWxOdW1iZXISKQoQZmlybXdhcm'
    'VfdmVyc2lvbhgCIAEoBVIPZmlybXdhcmVWZXJzaW9uEhgKB3ZvbHRhZ2UYAyABKAVSB3ZvbHRh'
    'Z2USFAoFcG93ZXIYBCABKAVSBXBvd2VyEiAKC3RlbXBlcmF0dXJlGAUgASgFUgt0ZW1wZXJhdH'
    'VyZRIlCg53YXJuaW5nX251bWJlchgGIAEoBVINd2FybmluZ051bWJlchIhCgxjcmNfY2hlY2tz'
    'dW0YByABKAVSC2NyY0NoZWNrc3VtEh8KC2xpbmtfc3RhdHVzGAggASgFUgpsaW5rU3RhdHVz');

@$core.Deprecated('Use sGSMODescriptor instead')
const SGSMO$json = {
  '1': 'SGSMO',
  '2': [
    {'1': 'serial_number', '3': 1, '4': 1, '5': 3, '10': 'serialNumber'},
    {'1': 'firmware_version', '3': 2, '4': 1, '5': 5, '10': 'firmwareVersion'},
    {'1': 'voltage', '3': 3, '4': 1, '5': 5, '10': 'voltage'},
    {'1': 'frequency', '3': 4, '4': 1, '5': 5, '10': 'frequency'},
    {'1': 'active_power', '3': 5, '4': 1, '5': 5, '10': 'activePower'},
    {'1': 'reactive_power', '3': 6, '4': 1, '5': 5, '10': 'reactivePower'},
    {'1': 'current', '3': 7, '4': 1, '5': 5, '10': 'current'},
    {'1': 'power_factor', '3': 8, '4': 1, '5': 5, '10': 'powerFactor'},
    {'1': 'temperature', '3': 9, '4': 1, '5': 5, '10': 'temperature'},
    {'1': 'warning_number', '3': 10, '4': 1, '5': 5, '10': 'warningNumber'},
    {'1': 'crc_checksum', '3': 11, '4': 1, '5': 5, '10': 'crcChecksum'},
    {'1': 'link_status', '3': 12, '4': 1, '5': 5, '10': 'linkStatus'},
    {'1': 'power_limit', '3': 13, '4': 1, '5': 5, '10': 'powerLimit'},
    {'1': 'modulation_index_signal', '3': 20, '4': 1, '5': 5, '10': 'modulationIndexSignal'},
  ],
};

/// Descriptor for `SGSMO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sGSMODescriptor = $convert.base64Decode(
    'CgVTR1NNTxIjCg1zZXJpYWxfbnVtYmVyGAEgASgDUgxzZXJpYWxOdW1iZXISKQoQZmlybXdhcm'
    'VfdmVyc2lvbhgCIAEoBVIPZmlybXdhcmVWZXJzaW9uEhgKB3ZvbHRhZ2UYAyABKAVSB3ZvbHRh'
    'Z2USHAoJZnJlcXVlbmN5GAQgASgFUglmcmVxdWVuY3kSIQoMYWN0aXZlX3Bvd2VyGAUgASgFUg'
    'thY3RpdmVQb3dlchIlCg5yZWFjdGl2ZV9wb3dlchgGIAEoBVINcmVhY3RpdmVQb3dlchIYCgdj'
    'dXJyZW50GAcgASgFUgdjdXJyZW50EiEKDHBvd2VyX2ZhY3RvchgIIAEoBVILcG93ZXJGYWN0b3'
    'ISIAoLdGVtcGVyYXR1cmUYCSABKAVSC3RlbXBlcmF0dXJlEiUKDndhcm5pbmdfbnVtYmVyGAog'
    'ASgFUg13YXJuaW5nTnVtYmVyEiEKDGNyY19jaGVja3N1bRgLIAEoBVILY3JjQ2hlY2tzdW0SHw'
    'oLbGlua19zdGF0dXMYDCABKAVSCmxpbmtTdGF0dXMSHwoLcG93ZXJfbGltaXQYDSABKAVSCnBv'
    'd2VyTGltaXQSNgoXbW9kdWxhdGlvbl9pbmRleF9zaWduYWwYFCABKAVSFW1vZHVsYXRpb25Jbm'
    'RleFNpZ25hbA==');

@$core.Deprecated('Use tGSMODescriptor instead')
const TGSMO$json = {
  '1': 'TGSMO',
  '2': [
    {'1': 'serial_number', '3': 1, '4': 1, '5': 3, '10': 'serialNumber'},
    {'1': 'firmware_version', '3': 2, '4': 1, '5': 5, '10': 'firmwareVersion'},
    {'1': 'voltage_phase_A', '3': 3, '4': 1, '5': 5, '10': 'voltagePhaseA'},
    {'1': 'voltage_phase_B', '3': 4, '4': 1, '5': 5, '10': 'voltagePhaseB'},
    {'1': 'voltage_phase_C', '3': 5, '4': 1, '5': 5, '10': 'voltagePhaseC'},
    {'1': 'voltage_line_AB', '3': 6, '4': 1, '5': 5, '10': 'voltageLineAB'},
    {'1': 'voltage_line_BC', '3': 7, '4': 1, '5': 5, '10': 'voltageLineBC'},
    {'1': 'voltage_line_CA', '3': 8, '4': 1, '5': 5, '10': 'voltageLineCA'},
    {'1': 'frequency', '3': 9, '4': 1, '5': 5, '10': 'frequency'},
    {'1': 'active_power', '3': 10, '4': 1, '5': 5, '10': 'activePower'},
    {'1': 'reactive_power', '3': 11, '4': 1, '5': 5, '10': 'reactivePower'},
    {'1': 'current_phase_A', '3': 12, '4': 1, '5': 5, '10': 'currentPhaseA'},
    {'1': 'current_phase_B', '3': 13, '4': 1, '5': 5, '10': 'currentPhaseB'},
    {'1': 'current_phase_C', '3': 14, '4': 1, '5': 5, '10': 'currentPhaseC'},
    {'1': 'power_factor', '3': 15, '4': 1, '5': 5, '10': 'powerFactor'},
    {'1': 'temperature', '3': 16, '4': 1, '5': 5, '10': 'temperature'},
    {'1': 'warning_number', '3': 17, '4': 1, '5': 5, '10': 'warningNumber'},
    {'1': 'crc_checksum', '3': 18, '4': 1, '5': 5, '10': 'crcChecksum'},
    {'1': 'link_status', '3': 19, '4': 1, '5': 5, '10': 'linkStatus'},
    {'1': 'modulation_index_signal', '3': 20, '4': 1, '5': 5, '10': 'modulationIndexSignal'},
  ],
};

/// Descriptor for `TGSMO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tGSMODescriptor = $convert.base64Decode(
    'CgVUR1NNTxIjCg1zZXJpYWxfbnVtYmVyGAEgASgDUgxzZXJpYWxOdW1iZXISKQoQZmlybXdhcm'
    'VfdmVyc2lvbhgCIAEoBVIPZmlybXdhcmVWZXJzaW9uEiYKD3ZvbHRhZ2VfcGhhc2VfQRgDIAEo'
    'BVINdm9sdGFnZVBoYXNlQRImCg92b2x0YWdlX3BoYXNlX0IYBCABKAVSDXZvbHRhZ2VQaGFzZU'
    'ISJgoPdm9sdGFnZV9waGFzZV9DGAUgASgFUg12b2x0YWdlUGhhc2VDEiYKD3ZvbHRhZ2VfbGlu'
    'ZV9BQhgGIAEoBVINdm9sdGFnZUxpbmVBQhImCg92b2x0YWdlX2xpbmVfQkMYByABKAVSDXZvbH'
    'RhZ2VMaW5lQkMSJgoPdm9sdGFnZV9saW5lX0NBGAggASgFUg12b2x0YWdlTGluZUNBEhwKCWZy'
    'ZXF1ZW5jeRgJIAEoBVIJZnJlcXVlbmN5EiEKDGFjdGl2ZV9wb3dlchgKIAEoBVILYWN0aXZlUG'
    '93ZXISJQoOcmVhY3RpdmVfcG93ZXIYCyABKAVSDXJlYWN0aXZlUG93ZXISJgoPY3VycmVudF9w'
    'aGFzZV9BGAwgASgFUg1jdXJyZW50UGhhc2VBEiYKD2N1cnJlbnRfcGhhc2VfQhgNIAEoBVINY3'
    'VycmVudFBoYXNlQhImCg9jdXJyZW50X3BoYXNlX0MYDiABKAVSDWN1cnJlbnRQaGFzZUMSIQoM'
    'cG93ZXJfZmFjdG9yGA8gASgFUgtwb3dlckZhY3RvchIgCgt0ZW1wZXJhdHVyZRgQIAEoBVILdG'
    'VtcGVyYXR1cmUSJQoOd2FybmluZ19udW1iZXIYESABKAVSDXdhcm5pbmdOdW1iZXISIQoMY3Jj'
    'X2NoZWNrc3VtGBIgASgFUgtjcmNDaGVja3N1bRIfCgtsaW5rX3N0YXR1cxgTIAEoBVIKbGlua1'
    'N0YXR1cxI2Chdtb2R1bGF0aW9uX2luZGV4X3NpZ25hbBgUIAEoBVIVbW9kdWxhdGlvbkluZGV4'
    'U2lnbmFs');

@$core.Deprecated('Use pvMODescriptor instead')
const PvMO$json = {
  '1': 'PvMO',
  '2': [
    {'1': 'serial_number', '3': 1, '4': 1, '5': 3, '10': 'serialNumber'},
    {'1': 'port_number', '3': 2, '4': 1, '5': 5, '10': 'portNumber'},
    {'1': 'voltage', '3': 3, '4': 1, '5': 5, '10': 'voltage'},
    {'1': 'current', '3': 4, '4': 1, '5': 5, '10': 'current'},
    {'1': 'power', '3': 5, '4': 1, '5': 5, '10': 'power'},
    {'1': 'energy_total', '3': 6, '4': 1, '5': 5, '10': 'energyTotal'},
    {'1': 'energy_daily', '3': 7, '4': 1, '5': 5, '10': 'energyDaily'},
    {'1': 'error_code', '3': 8, '4': 1, '5': 5, '10': 'errorCode'},
  ],
};

/// Descriptor for `PvMO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pvMODescriptor = $convert.base64Decode(
    'CgRQdk1PEiMKDXNlcmlhbF9udW1iZXIYASABKANSDHNlcmlhbE51bWJlchIfCgtwb3J0X251bW'
    'JlchgCIAEoBVIKcG9ydE51bWJlchIYCgd2b2x0YWdlGAMgASgFUgd2b2x0YWdlEhgKB2N1cnJl'
    'bnQYBCABKAVSB2N1cnJlbnQSFAoFcG93ZXIYBSABKAVSBXBvd2VyEiEKDGVuZXJneV90b3RhbB'
    'gGIAEoBVILZW5lcmd5VG90YWwSIQoMZW5lcmd5X2RhaWx5GAcgASgFUgtlbmVyZ3lEYWlseRId'
    'CgplcnJvcl9jb2RlGAggASgFUgllcnJvckNvZGU=');

@$core.Deprecated('Use realDataNewReqDTODescriptor instead')
const RealDataNewReqDTO$json = {
  '1': 'RealDataNewReqDTO',
  '2': [
    {'1': 'device_serial_number', '3': 1, '4': 1, '5': 9, '10': 'deviceSerialNumber'},
    {'1': 'timestamp', '3': 2, '4': 1, '5': 5, '10': 'timestamp'},
    {'1': 'ap', '3': 3, '4': 1, '5': 5, '10': 'ap'},
    {'1': 'cp', '3': 4, '4': 1, '5': 5, '10': 'cp'},
    {'1': 'firmware_version', '3': 5, '4': 1, '5': 5, '10': 'firmwareVersion'},
    {'1': 'meter_data', '3': 6, '4': 3, '5': 11, '6': '.MeterMO', '10': 'meterData'},
    {'1': 'rp_data', '3': 7, '4': 3, '5': 11, '6': '.RpMO', '10': 'rpData'},
    {'1': 'rsd_data', '3': 8, '4': 3, '5': 11, '6': '.RSDMO', '10': 'rsdData'},
    {'1': 'sgs_data', '3': 9, '4': 3, '5': 11, '6': '.SGSMO', '10': 'sgsData'},
    {'1': 'tgs_data', '3': 10, '4': 3, '5': 11, '6': '.TGSMO', '10': 'tgsData'},
    {'1': 'pv_data', '3': 11, '4': 3, '5': 11, '6': '.PvMO', '10': 'pvData'},
    {'1': 'dtu_power', '3': 12, '4': 1, '5': 4, '10': 'dtuPower'},
    {'1': 'dtu_daily_energy', '3': 13, '4': 1, '5': 4, '10': 'dtuDailyEnergy'},
  ],
};

/// Descriptor for `RealDataNewReqDTO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List realDataNewReqDTODescriptor = $convert.base64Decode(
    'ChFSZWFsRGF0YU5ld1JlcURUTxIwChRkZXZpY2Vfc2VyaWFsX251bWJlchgBIAEoCVISZGV2aW'
    'NlU2VyaWFsTnVtYmVyEhwKCXRpbWVzdGFtcBgCIAEoBVIJdGltZXN0YW1wEg4KAmFwGAMgASgF'
    'UgJhcBIOCgJjcBgEIAEoBVICY3ASKQoQZmlybXdhcmVfdmVyc2lvbhgFIAEoBVIPZmlybXdhcm'
    'VWZXJzaW9uEicKCm1ldGVyX2RhdGEYBiADKAsyCC5NZXRlck1PUgltZXRlckRhdGESHgoHcnBf'
    'ZGF0YRgHIAMoCzIFLlJwTU9SBnJwRGF0YRIhCghyc2RfZGF0YRgIIAMoCzIGLlJTRE1PUgdyc2'
    'REYXRhEiEKCHNnc19kYXRhGAkgAygLMgYuU0dTTU9SB3Nnc0RhdGESIQoIdGdzX2RhdGEYCiAD'
    'KAsyBi5UR1NNT1IHdGdzRGF0YRIeCgdwdl9kYXRhGAsgAygLMgUuUHZNT1IGcHZEYXRhEhsKCW'
    'R0dV9wb3dlchgMIAEoBFIIZHR1UG93ZXISKAoQZHR1X2RhaWx5X2VuZXJneRgNIAEoBFIOZHR1'
    'RGFpbHlFbmVyZ3k=');

@$core.Deprecated('Use realDataNewResDTODescriptor instead')
const RealDataNewResDTO$json = {
  '1': 'RealDataNewResDTO',
  '2': [
    {'1': 'time_ymd_hms', '3': 1, '4': 1, '5': 12, '10': 'timeYmdHms'},
    {'1': 'cp', '3': 2, '4': 1, '5': 5, '10': 'cp'},
    {'1': 'error_code', '3': 3, '4': 1, '5': 5, '10': 'errorCode'},
    {'1': 'offset', '3': 4, '4': 1, '5': 5, '10': 'offset'},
    {'1': 'time', '3': 5, '4': 1, '5': 5, '10': 'time'},
  ],
};

/// Descriptor for `RealDataNewResDTO`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List realDataNewResDTODescriptor = $convert.base64Decode(
    'ChFSZWFsRGF0YU5ld1Jlc0RUTxIgCgx0aW1lX3ltZF9obXMYASABKAxSCnRpbWVZbWRIbXMSDg'
    'oCY3AYAiABKAVSAmNwEh0KCmVycm9yX2NvZGUYAyABKAVSCWVycm9yQ29kZRIWCgZvZmZzZXQY'
    'BCABKAVSBm9mZnNldBISCgR0aW1lGAUgASgFUgR0aW1l');

