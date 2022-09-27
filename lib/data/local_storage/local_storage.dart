import 'package:biux/config/strings.dart';
import 'package:biux/data/local_storage/storage_keys.dart';
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
    // TO DO: uncomment when it's the local Storage is enabled
    // return _prefs.getString(key) ?? AppStrings.notFoundKey;
    return 'uSQDPSNH8VObpQFBaZd2HrPt4l22';
  }

  Future<void> _setString({
    required String key,
    required String value,
  }) async {
    await _prefs.setString(key, value);
  }

  // userId
  Future setUserId(String userId) => _setString(
        key: StorageKeys.userId,
        value: userId,
      );

  String getUserId() => _getString(StorageKeys.userId);

  // TO DO // Remove
  String _getStringTest(String key) {
    // TO DO: uncomment when it's the local Storage is enabled
    // return _prefs.getString(key) ?? AppStrings.notFoundKey;
    return 'nataSer24';
  }
  String getUserName() => _getStringTest(StorageKeys.userName);

  Future<void> deleteUserId() => _removeValue(StorageKeys.userId);

  // loggedIn
  Future setLoggedIn(bool loggedIn) => _setBool(
        key: StorageKeys.loggedIn,
        value: loggedIn,
      );

  bool getLoggedIn() => _getBool(StorageKeys.loggedIn);

  Future<void> deleteLoggedIn() => _removeValue(StorageKeys.loggedIn);
}
