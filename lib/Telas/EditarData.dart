import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Util/GerenciarDatas.dart';
import 'package:flutter_multiwork/Util/UserController.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';
import 'package:flutter_multiwork/Util/VerificarSenha.dart';

class EditarData extends StatefulWidget {
  String  _email;
  DateTime _data;
  String _dataExibir;

  EditarData(Map<String, dynamic> map){
    _email =map["email"];
    _data =map["data"];
    _dataExibir =map["dataExibir"];
  }

  @override
  _EditarDataLogica createState() => _EditarDataLogica();
}

class _EditarDataLogica extends State<EditarData> {
  TextEditingController _senha = TextEditingController();
  String _erro;
  User _Fuser;
  String _uid;


  _alterarDataBanco(String data){
    UserController.updateDataNasc(_uid, data);
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, "/contaUsuario");
  }

  _selecionarData()async{
    DateTime picked = await showDatePicker(
        locale: Locale("pt", "BR"),
        context: context,
        fieldLabelText: "",
        initialDate: widget._data,
        firstDate: DateTime(1920),
        lastDate: DateTime.now());
    if (picked != null) {
      String data = GerenciarDatas.DataparaTextoUsuario(picked);
      setState(() {
        widget._dataExibir = data;
        widget._data = picked;
      });
    }
  }

  _botaoPressionado()async{
    if(await VerificarSenha.verificarSenha(_senha.text, widget._email,_Fuser)){
      setState(() {
        _erro=null;
      });
      _alterarDataBanco(GerenciarDatas.DataparaTextoFirebase(widget._data));
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
    _Fuser = VerificarLogin.verificarLogin(context);
    _uid=_Fuser.uid;
  }

  @override
  Widget build(BuildContext context) => _EditarDataTela(this);
}

class _EditarDataTela extends WidgetView<EditarData, _EditarDataLogica> {
  _EditarDataTela(_EditarDataLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Data"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(widget._dataExibir, style: TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center,)
                ),
                RaisedButton(
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    onPressed: state._selecionarData
                ),
              ],
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
