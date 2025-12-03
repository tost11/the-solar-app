import 'package:flutter/material.dart';

import 'SU.dart';

class MapUtils {
  static Object ? OM(Map<String,dynamic> data,List<String> parmas) {
    dynamic current = data;
    for(var elem in parmas){
      if(current is String || current is int || current is double){
        return null;
      }
      current = current[elem];
      if(current == null){
        return null;
      }
    }

    return current;
  }

   static T OMas<T>(Map<String,dynamic> ? data,List<String> parmas,T defaultParam) {
    if(data == null){
      return defaultParam;
    }
    var current = OM(data,parmas);

    if(current == null){
      return defaultParam;
    }

    // Type check + cast
    if (current is T) {
      return current as T;
    }

    return defaultParam;
  }

  static Map<String, dynamic> ? mergeMaps(
      Map<String, dynamic> ? a,
      Map<String, dynamic> ? b,
      ) {

    if(a == null){
      return b;
    }
    if(b == null){
      return a;
    }

    final result = Map<String, dynamic>.from(a);

    b.forEach((key, value) {
      final aValue = result[key];

      if (aValue is Map<String, dynamic> && value is Map<String, dynamic>) {
        //Merge nested maps
        result[key] = mergeMaps(aValue, value);
      } else if (aValue is List && value is List) {
        //Combine lists (customize merging logic here)
        result[key] = mergeLists(aValue, value);
      } else {
        //Overwrite scalar or mismatched types
        result[key] = value;
      }
    });

    return result;
  }

  static List<dynamic> ? mergeLists(List<dynamic> ? a, List<dynamic> ? b) {
    if( a == null){
      return b;
    }
    if(b == null){
      return b;
    }
    // Default: concatenate lists (can be customized)
    return [...a, ...b];
  }

  static Map<String, dynamic> toRecursiveMap(dynamic value) {
    if (value is Map) {
      return value.map(
            (key, val) => MapEntry(key.toString(), toRecursiveMap(val)),
      );
    } else if (value is List) {
      return {'list': value.map(toRecursiveMap).toList()};
    } else if (value is num || value is String || value is bool || value == null) {
      return {'value': value};
    } else if (value is Object && value is! Function) {
      // Try using toJson if available
      try {
        final json = (value as dynamic).toJson();
        if (json is Map<String, dynamic>) {
          return toRecursiveMap(json);
        }
      } catch (_) {}
    }
    return {'value': value.toString()};
  }

  static addIfAvailable(Map<String,dynamic> source,Map<String,dynamic> target,String name,[String ? newName]){
    if(source.containsKey(name)){
      if(newName == null) {
        target[name] = source[name];
      }else{
        target[newName] = source[name];
      }
    }
  }
}
