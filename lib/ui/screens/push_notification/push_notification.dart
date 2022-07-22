// import 'package:firebase_messaging/firebase_messaging.dart';

// class PushNotificationsManager {
//   PushNotificationsManager._();
//   factory PushNotificationsManager() => _instance; 
//   static final PushNotificationsManager _instance =
//       PushNotificationsManager._();
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
//   bool _initialized = false;
//   String _token = '';
//   static dynamic _data;
//   Future<void> init() async {
//     if (!_initialized) {
//       // For iOS request permission first.
//       _firebaseMessaging.requestNotificationPermissions();
//       _firebaseMessaging.configure();
//       // For testing purposes print the Firebase Messaging token
//       String token = await _firebaseMessaging.getToken();
//       _initialized = true;
//       _token = token;
//       _data = null;
//     }
//   }

//   void onTokenRefresh() {
//     _firebaseMessaging.onTokenRefresh.listen((token) async {
//       if (_token != token) {
//         _token = token;
//         //Implementar logica de guardar en la bd
//       }
//     });
//   }

//   void subscribeToTopic(String topic) {
//     _firebaseMessaging.subscribeToTopic(topic);
//   }

//   void unSubscribeToTopic(String topic) {
//     _firebaseMessaging.unsubscribeFromTopic(topic);
//   }

//   void getMessage() {
//     _firebaseMessaging.configure(
//         onMessage: (Map<String, dynamic> message) async {
//           _data = message['data'];
//         },
//         onBackgroundMessage: myBackgroundMessageHandler,
//         onResume: (Map<String, dynamic> message) async {
//           _data = message['data'];
//         },
//         onLaunch: (Map<String, dynamic> message) async {
//           _data = message['data'];
//         });
//   }

//   static Future<dynamic> myBackgroundMessageHandler(
//       Map<String, dynamic> message) async {
//     _data = message['data'];
//   }
// }
