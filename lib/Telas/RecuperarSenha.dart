import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Util/UserController.dart';

class RecuperarSenha extends StatefulWidget {

  @override
  _RecuperarSenhaLogica createState() => _RecuperarSenhaLogica();
}

class _RecuperarSenhaLogica extends State<RecuperarSenha>{
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController _contrEmail = TextEditingController();

  _botaoPressionado()async{
    if(_key.currentState.validate()){
      UserController.recuperarSenha(_contrEmail.text, context);
    }
  }

  _validarEmail(String value){
    if(!value.contains("@")){
      return "Insira um email válido";
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _contrEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _RecuperarSenhaTela(this);
}

class _RecuperarSenhaTela extends WidgetView<RecuperarSenha, _RecuperarSenhaLogica>{
  _RecuperarSenhaTela(_RecuperarSenhaLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recuperar Senha"),
      ),

      body: SingleChildScrollView(
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
                    return state._validarEmail(value);
                  }),
                ),
                ),
              ),
            RaisedButton(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                color: Colors.cyan[600],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: Colors.transparent)),
                child: Text(
                  "Confirmar",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: state._botaoPressionado
            )
          ],
        ),
      )
    );
  }
}
