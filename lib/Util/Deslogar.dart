import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Deslogar {
  static deslogar(context) async{
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, "/");
  }
}