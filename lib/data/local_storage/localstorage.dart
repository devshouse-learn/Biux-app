import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences? _prefs;
  Future deleteToken() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs!.clear();
  }

  Future saveToken(String token) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs!.setString("token", token);
  }

  Future<String> getToken() async {
    _prefs = await SharedPreferences.getInstance();
    var token = _prefs!.getString("token");

    return "Bearer $token";
  }

  Future saveKey(String clave) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs!.setString("key", clave);
  }

  Future<String?> getKey() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs!.getString("key");
  }

  Future saveUser(String username) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs!.setString("user", username);
  }

  Future<String?> getUser() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs!.getString("user");
  }

  Future saveUserEmail(String email) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs!.setString("email", email);
  }

  Future<String?> getUserEmail() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs!.getString("email");
  } 

  Future saveUserId(String id) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs!.setString("id", id);
  }

  Future<String?> getUserId() async {
    _prefs = await SharedPreferences.getInstance();
    String? uid = _prefs!.getString("id");

    return uid;
  }

  Future saveDocumentUser(String document) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs!.setString("document", document);
  }

  Future saveJoinRoad(String id) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs!.setString("id", id);
  }

  Future<String?> getJoinRoad() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs!.getString("id");
  }

  Future saveApproved(bool approved) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs!.setBool("approved", true);
  }

  Future<bool?> getApproved() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs!.getBool("approved");
  }

  Future<String?> getDocumentUser() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs!.getString("document");
  }

  Future savePlanId(String planId) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs!.setString("planId", planId);
  }

  Future<String?> getPlanId() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs!.getString("planId");
  }

  Future saveTypePlanId(String typePlanId) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs!.setString("typePlanId", typePlanId);
  }

  Future<String?> getTypePlanId() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs!.getString("typePlanId");
  }

  Future saveGroupId(String groupId) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs!.setString("groupId", groupId);
  }

  Future deleteGroupsId() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs!.remove("groupId");
  }

  Future<String?> getGroupId() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs!.getString("groupId");
  }

  Future saveMobileId(String mobileId) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs!.setString("mobileId", mobileId);
  }

  Future<String?> getMobileId() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs!.getString("mobileId");
  }
}
