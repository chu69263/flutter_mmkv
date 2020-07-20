import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class MMKV {
  static const SINGLE_PROCESS_MODE = 1;
  static const MULTI_PROCESS_MODE = 2;
  static const MethodChannel _channel =
      const MethodChannel('plugin.waibibabo.com/flutter_mmkv');

  // call on program start
  static Future<String> initialize({String rootDir}) async {
    return _channel.invokeMethod('initialize', {'rootDir': rootDir});
  }

  // call on program exit
  static Future<void> onExit() async {
    _channel.invokeMethod('onExit');
  }

  static Future<String> get rootDir async {
    return _channel.invokeMethod('getRootDir');
  }

  // get device's page size,on IOS,this function always return 0
  static Future<int> get pageSize async {
    return _channel.invokeMethod('pageSize');
  }

  static MMKV defaultMMKV({int mode, String cryptKey}) {
    return MMKV._(mode: mode, cryptKey: cryptKey);
  }

  static MMKV mmkvWithID({String id, int mode, String cryptKey}) {
    return MMKV._(id: id, mode: mode, cryptKey: cryptKey);
  }

  // a memory only MMKV, cleared on program exit
  // size cannot change afterward (because ashmem won't allow it)
//  static MMKV mmkvWithAshmemID({String id, int mode, String cryptKey}) {
//    return MMKV._(id: id, mode: mode, cryptKey: cryptKey, ashmem: true);
//  }

  final String id;

  final int mode;

  // cryptKey's length <= 16
  final String cryptKey;

  //final bool ashmem;

  MMKV._({
    this.id,
    int mode,
    this.cryptKey,
    //this.ashmem = false,
  }) : this.mode = mode ?? SINGLE_PROCESS_MODE;

  Map _arguments([Map args]) {
    Map arguments = {
      'id': id,
      'cryptKey': cryptKey,
      'mode': mode,
      //'ashmem': ashmem
    };
    if (args != null && args.isNotEmpty) arguments.addAll(args);
    return arguments;
  }

  Future<bool> encodeString(String key, String value) async {
    return _channel.invokeMethod(
        'encode', _arguments({'key': key, 'value': value}));
  }

  Future<String> decodeString(String key, [String defaultValue]) async {
    return _channel.invokeMethod(
        'decodeString', _arguments({'key': key, 'defaultValue': defaultValue}));
  }

  Future<bool> encodeInt(String key, int value) async {
    return encodeString(key, value.toString());
  }

  Future<int> decodeInt(String key, [int defaultValue]) async {
    // kotlin/Java has Int and Long types
    var d0 = defaultValue != null ? defaultValue.toString() : '0';
    var value = await decodeString(key, d0);
    return int.parse(value);
  }

  Future<bool> encodeDouble(String key, double value) async {
    return _channel.invokeMethod(
        'encode', _arguments({'key': key, 'value': value}));
  }

  Future<double> decodeDouble(String key, [double defaultValue]) async {
    return _channel.invokeMethod(
        'decodeDouble', _arguments({'key': key, 'defaultValue': defaultValue}));
  }

  Future<bool> encodeBool(String key, bool value) async {
    return _channel.invokeMethod(
        'encode', _arguments({'key': key, 'value': value}));
  }

  Future<bool> decodeBool(String key, [bool defaultValue]) async {
    return _channel.invokeMethod(
        'decodeBool', _arguments({'key': key, 'defaultValue': defaultValue}));
  }

  Future<bool> encodeBytes(String key, Uint8List value) async {
    return _channel.invokeMethod(
        'encode', _arguments({'key': key, 'value': value}));
  }

  Future<Uint8List> decodeBytes(String key, [Uint8List defaultValue]) async {
    return _channel.invokeMethod(
        'decodeBytes', _arguments({'key': key, 'defaultValue': defaultValue}));
  }

  Future<bool> containsKey(String key) async {
    return _channel.invokeMethod('containsKey', _arguments({'key': key}));
  }

  Future<List<String>> get allKeys async {
    List list = await _channel.invokeMethod<List>('allKeys', _arguments());
    return list?.map((e) => e?.toString())?.toList();
  }

  Future<int> get count async {
    return _channel.invokeMethod('count', _arguments());
  }

  // used file size
  Future<int> get totalSize async {
    return _channel.invokeMethod('totalSize', _arguments());
  }

  // return the actual size consumption of the key's value
  // Note: might be a little bigger than value's length
  Future<int> getValueSize(String key) async {
    return _channel.invokeMethod('getValueSize', _arguments({'key': key}));
  }

  // return the actual size of the key's value
  // String's length or byte[]'s length, etc
  Future<int> getValueActualSize(String key) async {
    return _channel.invokeMethod(
        'getValueActualSize', _arguments({'key': key}));
  }

  Future<void> removeValueForKey(String key) async {
    await _channel.invokeMethod('removeValueForKey', _arguments({'key': key}));
  }

  Future<void> removeValuesForKeys(List<String> keys) async {
    await _channel.invokeMethod(
        'removeValuesForKeys', _arguments({'keys': keys}));
  }

  Future<void> clearAll() async {
    await _channel.invokeMethod('clearAll', _arguments());
  }

  // MMKV's size won't reduce after deleting key-values
  // call this method after lots of deleting if you care about disk usage
  // note that `clearAll` has the similar effect of `trim`
  Future<void> trim() async {
    await _channel.invokeMethod('trim', _arguments());
  }

  // call this method if the instance is no longer needed in the near future
  // any subsequent call to the instance is undefined behavior
  Future<void> close() async {
    await _channel.invokeMethod('close', _arguments());
  }

  // call on memory warning
  // any subsequent call to the instance will load all key-values from file again
  Future<void> clearMemoryCache() async {
    await _channel.invokeMethod('clearMemoryCache', _arguments());
  }
}
