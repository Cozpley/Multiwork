import 'package:brasil_fields/brasil_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Model/Usuario.dart';
import 'package:flutter_multiwork/Util/UserController.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';
import 'package:flutter_multiwork/Util/VerificarSenha.dart';

class AddTelefone extends StatefulWidget {
  Usuario user;

  AddTelefone(this.user);

  @override
  _AddTelefoneLogica createState() => _AddTelefoneLogica();
}

class _AddTelefoneLogica extends State<AddTelefone>{
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController _senha =TextEditingController();
  TextEditingController _telefone = TextEditingController();
  String _erro;
  User _Fuser;


  _AddTelefoneLogica(){
    _Fuser = VerificarLogin.verificarLogin(context);
  }

  addTelefoneBanco(List<String> tel){
    UserController.updateTelefones(_Fuser.uid, tel);
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, "/contaUsuario");
  }

  _buttonPressed()async{
    if(_key.currentState.validate()) {
      if (await VerificarSenha.verificarSenha(_senha.text, widget.user.email, _Fuser)) {
        setState(() {
          _erro = null;
        });
        widget.user.telefones.add(_telefone.text);
        addTelefoneBanco(widget.user.telefones);
      } else {
        setState(() {
          _erro = "Senha incorreta";
        });
      }
    }
  }

  String _validarTelefone(String value){
    if(value.isEmpty){
      return "Insira um número";
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _senha.dispose();
    _telefone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AddTelefoneTela(this);
}


class _AddTelefoneTela extends WidgetView<AddTelefone,_AddTelefoneLogica> {
  _AddTelefoneTela(_AddTelefoneLogica state): super(state);
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Adicionar Telefone"),
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
                  controller: state._telefone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TelefoneInputFormatter(),
                  ],
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "Insira o novo telefone",
                  ),
                  style: TextStyle(fontSize: 20),
                  validator: ((value){
                    return state._validarTelefone(value);
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
                RaisedButton(onPressed: () async{
                  state._buttonPressed();
                },
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
