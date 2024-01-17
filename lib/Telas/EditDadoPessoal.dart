import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Util/UserController.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';

class EditDadoPessoal extends StatefulWidget {
  String _tipoDado;
  String _dadoAntigo;
  String _email;

  EditDadoPessoal(Map<String, dynamic> map){
    _tipoDado=map["tipoDado"];
    _dadoAntigo=map["dadoAntigo"];
    _email = map["email"];
  }

  @override
  _EditDadoPessoalLogica createState() => _EditDadoPessoalLogica();
}


class _EditDadoPessoalLogica extends State<EditDadoPessoal>{

  GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController _senha =TextEditingController();
  TextEditingController _dadoNovo = TextEditingController();
  String _erro;
  String _uid;
  User _Fuser;

  Future<bool> _verificarSenha(String senha, String email) async {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: senha);
    UserCredential uc= await _Fuser.reauthenticateWithCredential(credential).catchError((_){});
    if(uc!=null){
      return true;
    }else{
      return false;
    }
  }

  _editDadoBanco(String novo) async{
    UserController.updateDadoPessoal(widget._tipoDado, novo, _uid);
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, "/contaUsuario");
  }

  String _maiuscula(String str){
    str = str[0].toUpperCase() + str.substring(1);
    return str;
  }

  String _verificarCampo(String value){
    if(value.isEmpty && widget._tipoDado!="complemento"){
      return "Preencha o campo";
    }
  }

  _botaoPressionado ()async{
    if(_key.currentState.validate()){
      if(await _verificarSenha(_senha.text, widget._email)){
        setState(() {
          _erro=null;
        });
        _editDadoBanco(_dadoNovo.text);
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
    _dadoNovo.dispose();
    _senha.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dadoNovo.text = widget._dadoAntigo;
    _Fuser = VerificarLogin.verificarLogin(context);
    _uid=_Fuser.uid;
  }
  @override
  Widget build(BuildContext context) => _EditDadoPessoalTela(this);
}


class _EditDadoPessoalTela extends WidgetView<EditDadoPessoal, _EditDadoPessoalLogica> {
  _EditDadoPessoalTela(_EditDadoPessoalLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar ${ widget._tipoDado=="numero" ? "Número R." :
        state._maiuscula(widget._tipoDado)}"),
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
                  controller: state._dadoNovo,
                  keyboardType: widget._tipoDado=="numero" ? TextInputType.number :
                  TextInputType.text,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: widget._tipoDado=="numero" ? "Número Residencial" :
                    state._maiuscula(widget._tipoDado),
                  ),
                  style: TextStyle(fontSize: 20),
                  validator: ((value){
                    return state._verificarCampo(value);
                  }
                    ),
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