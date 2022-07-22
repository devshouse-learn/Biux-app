import 'package:firebase_analytics/firebase_analytics.dart';
final analytics = FirebaseAnalytics.instance;

/*static String  = '';*/
class Analitycs {
  static String SIGN_UP = 'sing_up';
  static String LOGIN = 'login';
  static String VIEW_RODADA = 'view_rodada';
  static String JOIN_RODADA = 'join_rodada';
  static String LEAVE_RODADA = 'leave_rodada';
  static String EDIT_USER = 'edit_user';
  static String CREATE_GROUP = 'create_group';
  static String CREATE_RODADA = 'create_rodada';
  static String POST_HISTORY = 'post_history';
  static String LIKE_HISTORY = 'like_history';
  static String DELETE_HISTORY = 'delete_history';
  static String SHARE_RODADA = 'share_rodada';
  static String DELETE_RODADA = 'delete_rodada';

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
    String userId,
    String roadId,
    String meeting,
  ) async {
    await analytics.logEvent(
      name: VIEW_RODADA,
      parameters: <String, dynamic>{
        'userName': userName,
        'roadName': roadName,
        'userId': userId,
        'roadId': roadId,
        'meeting': meeting,
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
    String meeting,
    int participants,
  ) async {
    await analytics.logEvent(name: JOIN_RODADA, parameters: <String, dynamic>{
      'km': km,
      'level': level,
      'userName': userName,
      'userId': userId,
      'roadName': roadName,
      'roadId': roadId,
      'meeting': meeting,
      'participants': participants
    });
  }

  static void leaveRoad(
    int km,
    int level,
    String userName,
    int userId,
    String roadName,
    int roadId,
    String meeting,
    int participants,
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
        'meeting': meeting,
        'participants': participants,
      },
    );
  }

  static void editUser(
    String userName,
    String userId,
  ) async {
    await analytics.logEvent(name: EDIT_USER, parameters: <String, dynamic>{
      'userName': userName,
      'userId': userId,
    });
  }

//
  static void createGroup(
    String userName,
    String userId,
    String groupName,
    String city,
  ) async {
    await analytics.logEvent(
      name: CREATE_GROUP,
      parameters: <String, dynamic>{
        'userName': userName,
        'userId': userId,
        'groupName': groupName,
        'city': city,
      },
    );
  }

  static void createRoad(
    String userName,
    String userId,
    String roadName,
    double km,
    int level,
    String groupName,
    String city,
    String meeting,
  ) async {
    await analytics.logEvent(
      name: CREATE_RODADA,
      parameters: <String, dynamic>{
        'userName': userName,
        'userId': userId,
        'roadName': roadName,
        'km': km,
        'level': level,
        'groupName': groupName,
        'city': city,
        'meeting': meeting,
      },
    );
  }

  static void postStory(
    String userName,
    String userId,
    String type,
  ) async {
    await analytics.logEvent(
      name: POST_HISTORY,
      parameters: <String, dynamic>{
        'userName': userName,
        'userId': userId,
        'type': type,
      },
    );
  }

  static void likeStory(
    String userName,
    String userId,
    String image,
    String userImage,
  ) async {
    await analytics.logEvent(
      name: LIKE_HISTORY,
      parameters: <String, dynamic>{
        'userName': userName,
        'userId': userId,
        'image': image,
        'userImage': userImage
      },
    );
  }

  static void deleteStory(
    String userName,
    String userId,
    String image,
    String userImage,
  ) async {
    await analytics.logEvent(
      name: DELETE_HISTORY,
      parameters: <String, dynamic>{
        'userName': userName,
        'userId': userId,
        'image': image,
        'userImage': userImage,
      },
    );
  }

  static void shareRoad(
    String userName,
    String userId,
    String roadName,
    double km,
    int level,
    String groupName,
    String city,
    String meeting,
    int participants,
  ) async {
    await analytics.logEvent(
      name: SHARE_RODADA,
      parameters: <String, dynamic>{
        'userName': userName,
        'userId': userId,
        'roadName': roadName,
        'km': km,
        'level': level,
        'groupName': groupName,
        'city': city,
        'meeting': meeting,
        'participants': participants,
      },
    );
  }

  static void deleteRoad(
    String userName,
    String userId,
    String roadName,
    double km,
    int level,
    String groupName,
    String city,
    String meeting,
    int participants,
  ) async {
    await analytics.logEvent(
      name: SHARE_RODADA,
      parameters: <String, dynamic>{
        'userName': userName,
        'userId': userId,
        'roadName': roadName,
        'km': km,
        'level': level,
        'groupName': groupName,
        'city': city,
        'meeting': meeting,
        'participants': participants,
      },
    );
  }
}
