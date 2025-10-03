import 'package:biux/core/config/strings.dart';
import 'package:biux/shared/services/storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  factory LocalStorage() {
    return _singleton;
  }

  late final SharedPreferences _prefs;
  LocalStorage._internal();
  static final LocalStorage _singleton = LocalStorage._internal();

  Future clearLocalStorage() async {
    await _prefs.clear();
  }

  Future<bool> _checkValue(String key) async {
    bool present = _prefs.containsKey(key);
    return present;
  }

  Future<void> _removeValue(String key) async {
    await _prefs.remove(key);
  }

  bool _getBool(String key) {
    return _prefs.getBool(key) ?? false;
  }

  Future<void> _setBool({
    required String key,
    required bool value,
  }) async {
    await _prefs.setBool(key, value);
  }

  int _getInt(String key) {
    return _prefs.getInt(key) ?? -404;
  }

  Future<void> _setInt({
    required String key,
    required int value,
  }) async {
    await _prefs.setInt(key, value);
  }

  String _getString(String key) {
    return _prefs.getString(key) ?? AppStrings.notFoundKey;
  }

  Future<void> _setString({
    required String key,
    required String value,
  }) async {
    await _prefs.setString(key, value);
  }

  // userName
  Future setUserName(String userId) => _setString(
        key: StorageKeys.userName,
        value: userId,
      );

  String getUserName() => _getString(StorageKeys.userName);

}
