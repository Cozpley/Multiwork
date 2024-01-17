import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Util/UserController.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';
import 'package:flutter_multiwork/Util/VerificarSenha.dart';

class ExcluirConta extends StatefulWidget {
  UserInfo _userFacebookData;
  UserInfo _userGoogleData;
  String email;
  ExcluirConta(Map<String, dynamic> map){
    this.email = map["email"];
    this._userFacebookData = map["facebook"];
    this._userGoogleData=map["google"];
  }
  @override
  _ExcluirContaLogica createState() => _ExcluirContaLogica();
}

class _ExcluirContaLogica extends State<ExcluirConta> {
  User _Fuser;
  String _erro;
  TextEditingController _senha = TextEditingController();

  _botaoPressionado() async {
    if(await VerificarSenha.verificarSenha(_senha.text, widget.email, _Fuser)){
      setState(() {
        _erro=null;
      });
      UserController.excluirConta(_Fuser, widget._userGoogleData, widget._userFacebookData, context);
    }else{
      setState(() {
        _erro="Senha incorreta";
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _Fuser=VerificarLogin.verificarLogin(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _senha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ExcluirContaTela(this);
}

class _ExcluirContaTela extends WidgetView<ExcluirConta, _ExcluirContaLogica> {
  _ExcluirContaTela(_ExcluirContaLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Excluir Conta"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top:16, bottom: 16),
              child: Text(
                "Deseja excluir sua conta? Esta ação não pode ser desfeita",
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),

            Padding(padding: EdgeInsets.only(top:16, bottom: 16),
              child: TextField(
                controller: state._senha,
                obscureText: true,
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Insira a senha",
                ),
                style: TextStyle(fontSize: 20),
              ),
            ),

            state._erro == null
                ? Container()
                : Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Center(
                child: Text(
                  state._erro,
                  textAlign: TextAlign.center,
                  style:
                  TextStyle(fontSize: 20, color: Colors.redAccent),
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RaisedButton(onPressed: (){
                  Navigator.of(context).pop();
                },
                  child: Text("Cancelar", style: TextStyle(color:Colors.white),),
                  color: Colors.red,
                ),
                RaisedButton(onPressed: state._botaoPressionado,
                  color: Colors.red,
                  child: Text("Confirmar", style: TextStyle(color:Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}