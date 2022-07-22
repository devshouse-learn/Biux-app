import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

class Analitycs {
  static String SIGN_UP = 'sing_up';
  static String LOGIN = 'login';
  static String VIEW_RODADA = 'view_rodada';
  static String JOIN_RODADA = 'join_rodada';
  static String LEAVE_RODADA = 'leave_rodada';
  static String VIEW_PUBLICIDAD = 'view_publicidad';
  static String ONPRESS_EMPRESA = 'onpress_empresa';

  static void sendSignUp(String userId) async {
    await analytics.logEvent(
      name: SIGN_UP,
      parameters: <String, dynamic>{
        'userName': userId,
      },
    );
  }

  static void login(String userName) async {
    await analytics.logEvent(
      name: SIGN_UP,
      parameters: <String, dynamic>{
        'userName': userName,
      },
    );
  }

  static void viewRoad(
    String userName,
    String roadName,
    int userId,
    int roadId,
  ) async {
    await analytics.logEvent(
      name: VIEW_RODADA,
      parameters: <String, dynamic>{
        'userName': userName,
        'roadName': roadName,
        'userId': userId,
        'roadId': roadId,
      },
    );
  }

  static void onpressCompany(
    String name,
    String whatsapp,
    String city,
    String direction,
  ) async {
    await analytics.logEvent(
      name: ONPRESS_EMPRESA,
      parameters: <String, dynamic>{
        'name': name,
        'whatsapp': whatsapp,
        'city': city,
        'direction': direction,
      },
    );
  }

  static void onpressAdvertising(
    String userName,
    String advertisingName,
    int userId,
    int id,
    String cost,
  ) async {
    await analytics.logEvent(
      name: VIEW_RODADA,
      parameters: <String, dynamic>{
        'userName': userName,
        'advertisingName': advertisingName,
        'userId': userId,
        'id': id,
        'cost': cost,
      },
    );
  }

  static void viewAdvertising(
    String userName,
    String advertisingName,
    int userId,
    int id,
  ) async {
    await analytics.logEvent(
      name: VIEW_PUBLICIDAD,
      parameters: <String, dynamic>{
        'userName': userName,
        'advertisingName': advertisingName,
        'userId': userId,
        'id': id,
      },
    );
  }

  static void joinRoad(
    int km,
    int level,
    String userName,
    int userId,
    String roadName,
    int roadId,
  ) async {
    await analytics.logEvent(
      name: JOIN_RODADA,
      parameters: <String, dynamic>{
        'km': km,
        'level': level,
        'userName': userName,
        'userId': userId,
        'roadName': roadName,
        'roadId': roadId,
      },
    );
  }

  static void leaveRoad(
    int km,
    int level,
    String userName,
    int userId,
    String roadName,
    int roadId,
  ) async {
    await analytics.logEvent(
      name: LEAVE_RODADA,
      parameters: <String, dynamic>{
        'km': km,
        'level': level,
        'userName': userName,
        'userId': userId,
        'roadName': roadName,
        'roadId': roadId,
      },
    );
  }
}
