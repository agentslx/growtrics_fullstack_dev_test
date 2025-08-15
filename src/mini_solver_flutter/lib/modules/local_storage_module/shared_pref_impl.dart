import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage_module.dart';

class SharedPrefLocalStorageImpl extends LocalStorageModule {
  late SharedPreferences _prefs;

  final Completer<void> _initCompleter = Completer();

  Future<void> _ensureInitialized() async {
    if (_initCompleter.isCompleted) return;
    _prefs = await SharedPreferences.getInstance();
    _initCompleter.complete();
  }

  @override
  Future<T?> get<T>(String key) async {
    await _ensureInitialized();
    switch (T) {
      case const (String):
        return _prefs.getString(key) as T?;
      case const (bool):
        return _prefs.getBool(key) as T?;
      case const (int):
        return _prefs.getInt(key) as T?;
      case const (double):
        return _prefs.getDouble(key) as T?;
      case const (List<String>):
        return _prefs.getStringList(key) as T?;

      case const (Map<String, dynamic>):
        final jsonData = _prefs.getString(key);
        if (jsonData != null) {
          return _recursiveJsonDecode(jsonData) as T;
        }
        return null;
    }
    throw UnimplementedError();
  }

  Map<String, dynamic> _recursiveJsonDecode(String data) => json.decode(data, reviver: (key, value) {
      if (key != null && value is String) {
        if (value.startsWith('{') || value.startsWith('[')) {
          return _recursiveJsonDecode(value);
        }
      }
      return value;
    },) as Map<String, dynamic>;

  @override
  Future<void> set<T>(String key, T value) async {
    await _ensureInitialized();
    switch (T) {
      case const (String) :
        await _prefs.setString(key, value as String);
        return;
      case const (bool) :
        await _prefs.setBool(key, value as bool);
        return;
      case const (int) :
        await _prefs.setInt(key, value as int);
        return;
      case const (double) :
        await _prefs.setDouble(key, value as double);
        return;
      case const (List<String>):
        await _prefs.setStringList(key, value as List<String>);
        return;
      case const (Map<String, dynamic>):
        await _prefs.setString(key, json.encode(value));
        return;
    }
    throw UnimplementedError();
  }

  @override
  Future<void> remove<T>(String key) async {
    await _ensureInitialized();
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _ensureInitialized();
  }
}
