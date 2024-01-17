import 'package:brasil_fields/brasil_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Model/Usuario.dart';
import 'package:flutter_multiwork/Util/UserController.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';
import 'package:flutter_multiwork/Util/VerificarSenha.dart';

class EditTelefone extends StatefulWidget {
  Usuario user;
  int index;


  EditTelefone(Map<String, dynamic> map){
    user=map["user"];
    index=map["index"];
  }
  @override
  _EditTelefoneLogica createState() => _EditTelefoneLogica();
}

class _EditTelefoneLogica extends State<EditTelefone>{
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController _senha =TextEditingController();
  TextEditingController _telefone = TextEditingController();
  String _erro;
  String _uid;
  User _Fuser;

  _EditTelefoneLogica(){
    _Fuser = VerificarLogin.verificarLogin(context);
    _uid=_Fuser.uid;
  }


  _editTelefoneBanco(List<String> tel){
    UserController.updateTelefones(_uid, tel);
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, "/contaUsuario");
  }

  _botaoPressionado()async{
    if(_key.currentState.validate()){
      if(await VerificarSenha.verificarSenha(_senha.text, widget.user.email, _Fuser)){
        setState(() {
          _erro=null;
          widget.user.telefones[widget.index] = _telefone.text;
        });
        _editTelefoneBanco(widget.user.telefones);
      }else{
        setState(() {
          _erro="Senha incorreta";
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
    _telefone.dispose();
    _senha.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _telefone.text = widget.user.telefones[widget.index];
  }

  @override
  Widget build(BuildContext context) => _EditTelefoneTela(this);
}


class _EditTelefoneTela extends WidgetView<EditTelefone, _EditTelefoneLogica> {
  _EditTelefoneTela(_EditTelefoneLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Telefone"),
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
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TelefoneInputFormatter(),
                  ],
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "Edite o telefone",
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
                RaisedButton(onPressed: state._botaoPressionado,
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
