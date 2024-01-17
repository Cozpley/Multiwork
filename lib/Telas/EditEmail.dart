import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Util/UserController.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';
import 'package:flutter_multiwork/Util/VerificarSenha.dart';

class EditEmail extends StatefulWidget {
  String _email;

  EditEmail(this._email);

  @override
  _EditEmailLogica createState() => _EditEmailLogica();
}

class _EditEmailLogica extends State<EditEmail>{
  bool _loading=false;
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController _senha =TextEditingController();
  TextEditingController _contrEmail = TextEditingController();
  String _erro;
  User _Fuser;

  _editarEmail(String novo)async{
    String erro =await UserController.updateEmailBanco(novo, _Fuser);
    setState(() {
      _loading=false;
    });
    if(erro == null){
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, "/contaUsuario");
    }else{
      setState(() {
        _erro=erro;
      });
    }
  }

  _botaoPressionado() async{
    if(_key.currentState.validate()){
      if(await VerificarSenha.verificarSenha(_senha.text, widget._email, _Fuser)){
        setState(() {
          _loading=true;
        });
        setState(() {
          _erro=null;
        });
        _editarEmail(_contrEmail.text);
        }else{
        setState(() {
          _erro="Senha incorreta";
        });
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _contrEmail.dispose();
    _senha.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _contrEmail.text = widget._email;
    _Fuser = VerificarLogin.verificarLogin(context);
  }

  @override
  Widget build(BuildContext context) => _EditEmailTela(this);
}

class _EditEmailTela extends WidgetView<EditEmail, _EditEmailLogica> {
  _EditEmailTela(_EditEmailLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Email"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: state._key,
              child: Padding(
                padding: EdgeInsets.only(top:16, bottom: 16),
                child: TextFormField(
                  controller: state._contrEmail,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "Insira o email",
                  ),
                  style: TextStyle(fontSize: 20),
                  validator: ((value){
                    if(!value.contains("@")){
                      return "Insira um email válido";
                    }
                  }),
                ),
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
                ),
                state._loading ?  CircularProgressIndicator() : RaisedButton(onPressed: state._botaoPressionado,
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
