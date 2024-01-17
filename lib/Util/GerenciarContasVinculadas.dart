import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GerenciarContasVinculadas{

  static vincularContaGoogle(User fuser, context) async{
    var login = GoogleSignIn();
    final signin = await login.signIn();
    GoogleSignInAuthentication gauth = await signin.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(accessToken: gauth.accessToken,idToken: gauth.idToken);
    fuser.linkWithCredential(credential).then((value) {
      _alterarBancoLogin("Google", signin.id);
      _alterarBoolGoogle(true, context, fuser.uid);
    });
  }

  static desvincularConta(String id, User fuser, context, String dataUid){
    fuser.unlink(id).
    then((_) {
      FirebaseFirestore db = FirebaseFirestore.instance;
      if(id=="facebook.com"){
        db.collection("Facebook").doc(dataUid).delete();
        _alterarBoolFacebook(false, context, fuser.uid);
      }else{
        db.collection("Google").doc(dataUid).delete();
        _alterarBoolGoogle(false, context, fuser.uid);
      }
    });
  }

  static _alterarBancoLogin(String plataforma, String id){
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection(plataforma).doc(id).set({"exists":true});
  }

  static _alterarBoolGoogle(bool b, context, uid)async{
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("usuarios").doc(uid).update({"hasContaGoogle" : b});
    Navigator.pushReplacementNamed(context, "/contaUsuario");
  }

  static _alterarBoolFacebook(bool b, context, uid){
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("usuarios").doc(uid).update({"hasContaFacebook" : b});
    Navigator.pushReplacementNamed(context, "/contaUsuario");
  }

  static vincularContaFacebook(User fuser, context) async{
    var login = FacebookLogin();
    final result = await login.logIn(['email', 'public_profile']);
    if(result.status == FacebookLoginStatus.loggedIn) {
      final FacebookAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(result.accessToken.token);
      fuser.linkWithCredential(facebookAuthCredential).then((value) {
        _alterarBancoLogin("Facebook", result.accessToken.userId);
        _alterarBoolFacebook(true, context, fuser.uid);
      });
    }
  }
}