import 'package:firebase_auth/firebase_auth.dart';

class VerificarSenha{
  static Future<bool> verificarSenha(String senha, String email, fuser) async {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: senha);
    UserCredential uc;
    try{
      uc = await fuser.reauthenticateWithCredential(credential);
    }catch(_){}
    if(uc!=null){
      return true;
    }else{
      return false;
    }
  }

}