import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Model/Usuario.dart';
import 'package:flutter_multiwork/Util/UserController.dart';
import 'package:flutter_multiwork/Util/GerenciarDatas.dart';

class OutroUsuario extends StatefulWidget {
  String _id;
  String _nome;

  OutroUsuario(Map<String, dynamic> map){
    this._id = map["id"];
    this._nome = map ["nome"];
  }

  @override
  _OutroUsuarioLogica createState() => _OutroUsuarioLogica();
}

class _OutroUsuarioLogica extends State<OutroUsuario> {
  TextStyle _dadosTextStyle = TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w700);
  TextStyle _dadosTelStyle = TextStyle(fontSize: 18, color: Colors.white);

  Future<Usuario> _returnUsuario() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snap = await db.collection("usuarios").doc(widget._id).get();
    if(snap.exists){
      Map<String, dynamic> dados = snap.data();
      List<String> listaTelefones=[];
      dados["telefones"].forEach(
              (item)=>listaTelefones.add(item.toString())
      );
      bool mostrarEnd = dados["mostrarEndereco"];
      Usuario user;
      if(mostrarEnd){
        user = Usuario.UsuarioComEndereco(listaTelefones, dados["nome"], dados["data"], dados["estado"],
            dados["cidade"],dados["rua"], dados["numero"], dados["complemento"], dados["email"], mostrarEnd, null, null);
      }else{
        user = Usuario.UsuarioSemEndereco(listaTelefones, dados["nome"],dados["data"],
            dados["email"], mostrarEnd);
      }
      user.id = widget._id;

      return user;
    }
    else{
      return null;
    }

  }

  @override
  Widget build(BuildContext context) => _OutroUsuarioTela(this);
}

class _OutroUsuarioTela extends WidgetView<OutroUsuario, _OutroUsuarioLogica> {
  _OutroUsuarioTela(_OutroUsuarioLogica state): super(state);

  Column _mostrarEndereco(Usuario user){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8),
          child: Text("Estado: ${user.estado}", style: state._dadosTextStyle,maxLines: null),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8),
          child: Text("Cidade: ${user.cidade}", style: state._dadosTextStyle,maxLines: null),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8),
          child: Text("Rua: ${user.rua}", style: state._dadosTextStyle,maxLines: null),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8),
          child: Text("Número Residencial: ${user.numero}", style: state._dadosTextStyle,maxLines: null),
        ),

        user.complemento != "" ? Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8),
          child: Text("Complemento: ${user.complemento}", style: state._dadosTextStyle,maxLines: null),
        ) : Container()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._nome),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: FutureBuilder<Usuario>(
          future: state._returnUsuario(),
          builder: (context, snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
                break;
              default:
                if(!snapshot.hasError && snapshot.hasData){
                  Usuario user = snapshot.data;
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: 16, bottom: 8),
                            child: Text("Nome: ${user.nome}", style: state._dadosTextStyle,maxLines: null),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 8),
                            child: Text("Email: ${user.email}", style: state._dadosTextStyle,maxLines: null),
                        ),

                        Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 8),
                            child:  Text("Data de Nascimento: ${GerenciarDatas.TextoFirebaseparaUsuario(user.dataNasc)}", style: state._dadosTextStyle,),
                        ),

                        Padding(
                          padding: EdgeInsets.only( top: 4, left:16, right: 6),
                          child: Text("Telefones", style: state._dadosTextStyle,),
                        ),

                        Padding(
                          padding:EdgeInsets.only(bottom: 8),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white70,
                                    width: 2)
                            ),
                            child: ListView.separated(
                                separatorBuilder: (_, index){
                                  return Container(
                                      color: Colors.grey,
                                      height: 0.5);
                                },
                                shrinkWrap: true,
                                itemCount: user.telefones.length,
                                itemBuilder: (context, index){
                                  return ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.only(left: 16),
                                      title: Text(user.telefones[index], style: state._dadosTelStyle),
                                  );
                                }
                            ),
                          ),
                        ),

                        user.mostrarEndereco ? _mostrarEndereco(user) : Container(),
                        Padding(padding: EdgeInsets.only(top:16),
                          child: RaisedButton.icon(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.transparent)),
                            onPressed: (){
                              Navigator.pushReplacementNamed(context, "/mensagens", arguments: user);
                            },
                            icon: Icon(Icons.chat, color: Colors.white),
                            label: Expanded(child: Text("Conversar", style: TextStyle(color: Colors.white, fontSize: 20),textAlign: TextAlign.center,),),
                            padding: EdgeInsets.fromLTRB(16,10,16,10),
                          ),
                        ),
                      ],
                    ),
                  );
                }else{
                  if(snapshot.hasError){
                    return Center(
                        child: Text("Erro", style: TextStyle(color: Colors.redAccent, fontSize: 30),)
                    );
                  }
                  return Container();
                }
                break;
            }
          },
        ),
      ),
    );
  }
}
