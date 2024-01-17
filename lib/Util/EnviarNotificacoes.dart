import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
class PushNotificationsManager{


  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance = PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging()..configure(
    onResume: (message) async{
    },
    onLaunch: (message)async{

    },

  );

  bool _initialized = false;



  Future<void> init(String uid) async {
    if (!_initialized) {

      _firebaseMessaging.configure();

      String token = await _firebaseMessaging.getToken();
      _initialized = true;
      FirebaseFirestore db =await FirebaseFirestore.instance;
      await db.collection("usuarios").doc(uid).update({"MessageToken":token});
    }
  }


}