import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Login extends StatefulWidget {
  @override
  _LoginLogica createState() => _LoginLogica();
}

class _LoginLogica extends State<Login>{

  String _erro;
  bool _isLoading = false;
  TextStyle _formText = TextStyle(fontSize: 16, color: Colors.black);
  TextEditingController _contrEmail = TextEditingController();
  TextEditingController _contrSenha = TextEditingController();

  _logarEmail(String email, String senha) async {
    setState(() {
      _isLoading = true;
    });
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth
        .signInWithEmailAndPassword(email: email, password: senha)
        .catchError((_) {
      setState(() {
        _erro = "Não foi possível realizar o login";
      });
    });
    setState(() {
      _isLoading = false;
    });
    if (auth.currentUser != null) {
      setState(() {
        _erro = null;
      });
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  _logarContaGoogle() async {
    setState(() {
      _isLoading = true;
    });
    var login = GoogleSignIn();
    final signin = await login.signIn();
    GoogleSignInAuthentication gauth = await signin.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gauth.accessToken, idToken: gauth.idToken);
    FirebaseAuth auth = await FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot ds = await db.collection("Google").doc(signin.id).get();
    if (ds.exists) {
      await auth.signInWithCredential(credential).catchError((_) {
        setState(() {
          _erro = "Não foi possível realizar o login";
        });
      });
      setState(() {
        _isLoading = false;
      });
      if (auth.currentUser != null) {
        setState(() {
          _erro = null;
        });
        Navigator.pushReplacementNamed(context, "/home");
      }
    } else {
      bool value = await _verificarEmail(signin.email);
      if(value){
        setState(() {
          _isLoading = false;
          _erro = null;
        });
        Navigator.pushNamed(context, "/cadastro", arguments: {"google":credential, "googleid": signin.id});
      } else{
        setState(() {
          _erro = "Esta conta Google possui um email já em uso, mas não está vinculada. Vincule-a para realizar o login.";
          _isLoading=false;
        });
      }

    }
  }

  Future<bool> _verificarEmail(String email) async {
    FirebaseFirestore firestore =FirebaseFirestore.instance;
    var ds = await firestore.collection("usuarios").where("email", isEqualTo: email).get();
    print(ds.toString());
    if(ds.docs.isEmpty){
      return true;
    }else{
      return false;
    }
  }

  _logarContaFacebook() async {
    setState(() {
      _isLoading = true;
    });
    var login = FacebookLogin();
    final result = await login.logIn(['email', 'public_profile']);
    FirebaseAuth auth = FirebaseAuth.instance;
    if (result.status == FacebookLoginStatus.loggedIn) {
      final FacebookAuthCredential facebookAuthCredential =
      FacebookAuthProvider.credential(result.accessToken.token);
      FirebaseFirestore db = FirebaseFirestore.instance;
      DocumentSnapshot ds =
      await db.collection("Facebook").doc(result.accessToken.userId).get();
      if (ds.exists) {
        await auth.signInWithCredential(facebookAuthCredential).catchError((_) {
          setState(() {
            _erro = "Não foi possível realizar o login";
          });
        });
        setState(() {
          _isLoading = false;
        });
        if (auth.currentUser != null) {
          setState(() {
            _erro = null;
          });
          Navigator.pushReplacementNamed(context, "/home");
        }
      }else{
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=email&access_token=${result.accessToken.token}');
        final profile = jsonDecode(graphResponse.body);
        bool value = await _verificarEmail(profile["email"]);
        if(value){
          setState(() {
            _isLoading = false;
            _erro = null;
          });
          Navigator.pushNamed(context, "/cadastro", arguments: {"facebook":facebookAuthCredential, "facebookid": result.accessToken.userId});
        }else{
          setState(() {
            _erro = "Esta conta Facebook possui um email já em uso, mas não está vinculada. Vincule-a para realizar o login.";
            _isLoading=false;
          });
        }

      }
    }else{
      setState(() {
        _isLoading = false;
        _erro = "Não foi possível logar";
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _contrSenha.dispose();
    _contrEmail.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) => _LoginTela(this);
}

class _LoginTela extends WidgetView<Login,_LoginLogica> {
  _LoginTela(_LoginLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey[850], Colors.black])),
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "multiwork",
                    style: TextStyle(
                        fontSize: 28,
                        color: Color.fromRGBO(60, 235, 255, 1),
                        letterSpacing: 15),
                    textAlign: TextAlign.center,
                  ),
                ),
                Center(
                  child: Image.asset(
                    "img/logo.png",
                    width: MediaQuery.of(context).size.width / 2,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8, top: 8),
                  child: TextField(
                      controller: state._contrEmail,
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "Insira o email",
                      ),
                      style: state._formText),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                      controller: state._contrSenha,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "Insira a senha",
                      ),
                      style: state._formText),
                ),
                state._erro == null
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          state._erro,
                          style: TextStyle(color: Colors.redAccent, fontSize: 15),
                        ),
                      ),
                !state._isLoading
                    ? Container()
                    : Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                !state._isLoading
                    ? RaisedButton(
                        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                        color: Colors.cyan[600],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(color: Colors.transparent)),
                        child: Text(
                          "Entrar",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: (){
                          state._logarEmail(state._contrEmail.text, state._contrSenha.text);
                        })
                    : Container(),
                !state._isLoading
                    ? Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 12),
                        child: GestureDetector(
                          child: Text(
                            "Recuperar Senha",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Color.fromRGBO(60, 235, 255, 1)),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, "/recuperarSenha");
                          },
                        ),
                      )
                    : Container(),
                !state._isLoading
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: RaisedButton(
                            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(
                                    color: Color.fromRGBO(60, 235, 255, 1))),
                            color: Colors.transparent,
                            child: Text(
                              "Logar com Google",
                              style: TextStyle(
                                  color: Color.fromRGBO(60, 235, 255, 1),
                                  fontSize: 16),
                            ),
                            onPressed: state._logarContaGoogle
                        ))
                    : Container(),
                !state._isLoading
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: RaisedButton(
                            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(
                                    color: Color.fromRGBO(60, 235, 255, 1))),
                            color: Colors.transparent,
                            child: Text(
                              "Logar com Facebook",
                              style: TextStyle(
                                  color: Color.fromRGBO(60, 235, 255, 1),
                                  fontSize: 16),
                            ),
                            onPressed: state._logarContaFacebook
                              ))
                    : Container(),
                !state._isLoading
                    ? RaisedButton(
                        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                                color: Color.fromRGBO(60, 235, 255, 1))),
                        color: Colors.transparent,
                        child: Text(
                          "Criar Nova Conta",
                          style: TextStyle(
                              color: Color.fromRGBO(60, 235, 255, 1),
                              fontSize: 16),
                        ),
                        onPressed: () {
                          Map<String, dynamic> map = {};
                          Navigator.pushNamed(context, "/cadastro",
                              arguments: map);
                        })
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
