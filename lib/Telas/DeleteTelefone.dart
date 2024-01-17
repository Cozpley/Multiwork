import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Util/UserController.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';
import 'package:flutter_multiwork/Util/VerificarSenha.dart';
import 'package:flutter_multiwork/Model/Usuario.dart';

class DeleteTelefone extends StatefulWidget {
  Usuario user;
  int index;


  DeleteTelefone(Map<String, dynamic> map){
    user=map["user"];
    index=map["index"];
  }

  @override
  _DeleteTelefoneLogica createState() => _DeleteTelefoneLogica();

}

class _DeleteTelefoneLogica extends State<DeleteTelefone>{

  TextEditingController _senha =TextEditingController();
  String _erro;
  String _uid;
  User _Fuser;
  bool _deleted=false;

  _carregarLogin() async {
    _Fuser=VerificarLogin.verificarLogin(context);
    _uid=_Fuser.uid;
  }


  _deleteTelefoneBanco(List<String> tel){
    _deleted=true;
    UserController.updateTelefones(_uid, tel);
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, "/contaUsuario");
  }

  _botaoPressionado() async{
    if(await VerificarSenha.verificarSenha(_senha.text, widget.user.email, _Fuser)){
      setState(() {
        _erro=null;
        widget.user.telefones.removeAt(widget.index);
      });
      _deleteTelefoneBanco(widget.user.telefones);
    }else{
      setState(() {
        _erro="Senha incorreta";
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _senha.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _carregarLogin();
  }

  @override
  Widget build(BuildContext context) => _DeleteTelefoneTela(this);
}


class _DeleteTelefoneTela extends WidgetView<DeleteTelefone, _DeleteTelefoneLogica> {
  _DeleteTelefoneTela(_DeleteTelefoneLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Excluir Telefone"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.only(top:16, bottom: 16),
                child: state._deleted ? Text("") : Text(
                  "Deseja excluir o telefone ${widget.user.telefones[widget.index]}?",
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
