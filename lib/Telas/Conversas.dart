import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Model/Conversa.dart';
import 'package:flutter_multiwork/Model/Usuario.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';

class Conversas extends StatefulWidget {
  @override
  _ConversasLogica createState() => _ConversasLogica();
}

class _ConversasLogica extends State<Conversas> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  String _idLogado;
  final _controler = StreamController<QuerySnapshot>.broadcast();

  Stream<QuerySnapshot> _listenerConversas() {
    Stream<QuerySnapshot> stream = db.collection("conversas")
        .doc(_idLogado)
        .collection("ultimaConversa").orderBy("data", descending: true)
        .snapshots()
      ..listen((dados) {
        if(!_controler.isClosed){
          _controler.add(dados);
        }
      });
  }

  _recuperarDados() async {
    User user = VerificarLogin.verificarLogin(context);
    _idLogado = user.uid;
    _listenerConversas();
  }

  _tilePressionado(DocumentSnapshot item, Conversa conversa){
    Usuario user = Usuario();
    user.nome = conversa.nome;
    user.id = item.id;
    Navigator.pushNamed(context, "/mensagens", arguments: user);
  }

  Conversa _returnConversa(DocumentSnapshot item){
    Conversa conversa = Conversa();
    conversa.idRemetente = item["idRemetente"];
    conversa.tipo = item["tipo"];
    conversa.nome = item["nome"];
    conversa.mensagem = item["mensagem"];
    conversa.visualizada = item["visualizada"];
    return conversa;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarDados();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controler.close();
  }

  @override
  Widget build(BuildContext context) => _ConversasTela(this);
}


class _ConversasTela extends WidgetView<Conversas, _ConversasLogica> {
  _ConversasTela(_ConversasLogica state): super(state);

  ListTile _listTile(DocumentSnapshot item, Conversa conversa){
    return ListTile(
        onTap: () { state._tilePressionado(item, conversa);},
        contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
        title: Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            conversa.nome, style: TextStyle(fontWeight: FontWeight
              .bold, fontSize: 18, color: Colors.white),),
        ),
        subtitle: conversa.tipo == "texto" ?
          conversa.idRemetente ==state._idLogado ?
            Text("Você: "+ conversa.mensagem, style: TextStyle(color: Colors.grey,
            fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis,)
            : Text("${conversa.nome}: "+ conversa.mensagem, style: TextStyle(color: Colors.grey,
            fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis,)
          : conversa.idRemetente ==state._idLogado ?
            Text("Você enviou uma imagem", style: TextStyle(color: Colors.grey, fontSize: 16),)
            : Text("${conversa.nome} enviou uma imagem", style: TextStyle(color: Colors.grey, fontSize: 16),)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conversas"),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: state._controler.stream,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Center(child: Text("Carregando", style: TextStyle(color: Colors.white),),),
                        ),
                        CircularProgressIndicator()
                      ],
                    ));
                break;
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Erro ao  carregar dados"),
                  );
                } else {
                  if (snapshot.hasData) {
                    QuerySnapshot querySnapshot = snapshot.data;
                    if (querySnapshot.docs.length == 0) {
                      return Center(
                        child: Text("Você não tem nenhuma conversa ainda"),
                      );
                    } else {
                      return ListView.separated(
                          separatorBuilder: (context, index) {
                            return Container(
                              color: Colors.white70,
                              height: 1,
                              width: double.maxFinite,
                            );
                          },
                          itemCount: querySnapshot.docs.length,
                          itemBuilder: (context, index) {
                            List<DocumentSnapshot> lista = querySnapshot.docs
                                .toList();
                            DocumentSnapshot item = lista[index];
                            Conversa conversa= state._returnConversa(item);
                            return conversa.visualizada ? _listTile(item, conversa):
                            Stack(children: [
                              _listTile(item, conversa),
                              Positioned(
                                  top: 20,
                                  right: 5,
                                  child: Container(
                                      child: Padding(padding: EdgeInsets.only(bottom: 8, top: 0), child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 30,),),
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          color: Colors.redAccent[700],
                                          shape: BoxShape.circle
                                      )
                                  )
                              )
                            ],)
                            ;
                          }
                      );
                    }
                  }
                  return Container();
                }
                break;
            }
          }
      ),
    );
  }
}