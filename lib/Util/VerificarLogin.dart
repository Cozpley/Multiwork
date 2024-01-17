import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class VerificarLogin{

  static verificarLoginInicio(context) async {
    await Firebase.initializeApp();
    User user = verificarLogin(context);
    if(user!=null){
      Navigator.pushReplacementNamed(context, "/home");
    }

  }

  static User verificarLogin(context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser;
    if (user != null) {
      return user;
    } else {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

}