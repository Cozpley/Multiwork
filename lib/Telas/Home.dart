import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Model/Proposta.dart';
import 'package:flutter_multiwork/Util/Deslogar.dart';
import 'package:flutter_multiwork/Util/GerenciarDatas.dart';
import 'package:flutter_multiwork/Util/GerenciarPosicoes.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_multiwork/Util/EnviarNotificacoes.dart';

class Home extends StatefulWidget {
  @override
  _HomeLogica createState() => _HomeLogica();
}


class _HomeLogica extends State<Home>{

  TextEditingController _contrUsuarios = TextEditingController();
  TextStyle _textBotao = TextStyle(color: Colors.white, fontSize: 20);
  List<String> _listMenuLateral =  ["Deslogar"];
  bool _notifyAgenda=false;
  bool _notifyAgenda2=false;
  bool _notifyConversa=false;
  StreamSubscription<QuerySnapshot> _listener;
  StreamSubscription<QuerySnapshot> _listener2;
  StreamSubscription<QuerySnapshot> _listenerConversas;
  String _uid;
  String _data;

  _addListenerConversas(){
    _listenerConversas =  FirebaseFirestore.instance.collection("conversas").doc(_uid).collection("ultimaConversa").where("visualizada", isEqualTo: false).snapshots().listen((event) {
      bool flag = false;
      event.docs.forEach((element) {
        flag=true;
        setState(() {
          _notifyConversa=true;
        });
      });
      if(flag==false){
        setState(() {
          _notifyConversa=false;
        });
      }
    });
  }


  _messageToken(String id)async{
    PushNotificationsManager().init(id);
  }

  _inicializar(context) async{
    String dataTemp = GerenciarDatas.carregarData();
    User userTemp = VerificarLogin.verificarLogin(context);
    setState((){
      _data = dataTemp;
      User user = userTemp;
      _uid=user.uid;
    });
    _listener =  FirebaseFirestore.instance.collection("propostas").doc(_uid).collection("propostasAtivas").where("idPrestador", isEqualTo: _uid).snapshots().listen((event) {
      bool flag = false;
      event.docs.forEach((element) {
        if(element["status"]==Proposta.REQUISITADA){
          flag=true;
          setState(() {
            _notifyAgenda=true;
          });
        }
      });
      if(flag==false){
        setState(() {
          _notifyAgenda=false;
        });
      }
    });
    _listener2 =  FirebaseFirestore.instance.collection("propostas").doc(_uid).collection("propostasAtivas").where("idPrestador", isEqualTo: _uid).where("status", isEqualTo: Proposta.AGENDADA)
        .where("data", isLessThan: _data).snapshots().listen((event) {
      if(event.docs.length!=0){
        setState(() {
          _notifyAgenda2=true;
        });
      }else{
        _notifyAgenda2=false;
      }
    });
    _addListenerConversas();
    await GerenciarPosicoes.registrarPosicao(_uid);
    await _messageToken(_uid);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _contrUsuarios.dispose();
    _listener.cancel();
    _listener2.cancel();
    _listenerConversas.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _inicializar(context);
  }

  @override
  Widget build(BuildContext context) => _HomeTela(this);
}




class _HomeTela extends WidgetView<Home, _HomeLogica> {
  _HomeTela(_HomeLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("multiwork", style: TextStyle(letterSpacing: 12, fontSize: 20, color: Colors.white),),
        leading: IconButton(
          icon: Icon(Icons.account_circle_outlined, size: 30),
          onPressed: (){
            Navigator.pushNamed(context, "/contaUsuario");
          },
        ),

        actions: [
          PopupMenuButton<String>(
            onSelected: (item){
              switch(item){
                case"Deslogar":
                  Deslogar.deslogar(context);
              }
            },
            itemBuilder: (context){
              return state._listMenuLateral.map((e) {
                return PopupMenuItem<String>(
                    value: e,
                    child: Text(e)
                );
              }
              ).toList();
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                style: TextStyle(fontSize: 18, color: Colors.black),
                controller: state._contrUsuarios,
                decoration: InputDecoration(
                  prefixIconConstraints:BoxConstraints(minWidth: 24, maxHeight: 24),
                  suffixIconConstraints: BoxConstraints(minWidth: 24, maxHeight: 24),
                  contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  prefixIcon: IconButton(
                    padding: EdgeInsets.only(right: 4),
                    icon: Icon(Icons.clear),
                    onPressed: (){
                      state._contrUsuarios.clear();
                    },
                  ),
                  suffixIcon: IconButton(
                    padding: EdgeInsets.only(left: 4),
                    icon: Icon(Icons.search),
                    onPressed: (){
                      Navigator.pushNamed(context, "/pesquisarUsuarios", arguments: state._contrUsuarios.text);
                    },
                  ),
                  hintText: "Pesquisar por pessoas",
                ),
              ),
              Padding(padding: EdgeInsets.only(top:32),
                child: RaisedButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.transparent)),
                  onPressed: (){
                    Navigator.pushNamed(context, "/meusServicos");
                  },
                  icon: Row(children: [
                    Icon(Icons.account_circle, color: Colors.white),
                    Icon(Icons.home_repair_service, color: Colors.white)
                  ],),
                  label: Expanded(child: Text("Meus Serviços", style: state._textBotao,textAlign: TextAlign.center,),),
                  padding: EdgeInsets.fromLTRB(16,10,16,10),
                ),
              ),
              Padding(padding: EdgeInsets.only(top:16),
                child: RaisedButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.transparent)),
                  onPressed: (){
                    Navigator.pushNamed(context, "/procurarServico");
                  },
                  icon: Row(
                    children: [
                    Icon(Icons.search, color: Colors.white),
                    Icon(Icons.home_repair_service, color: Colors.white)
                  ],),
                  label: Expanded(child: Text("Procurar Serviços", style: state._textBotao,textAlign: TextAlign.center,),),
                  padding: EdgeInsets.fromLTRB(16,10,16,10),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top:16),
                child: RaisedButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.transparent)),
                  onPressed: (){
                    Navigator.pushNamed(context, "/agenda", arguments: state._uid);
                  },
                  icon: Icon(Icons.calendar_today, color: Colors.white,),
                  label: (state._notifyAgenda || state._notifyAgenda2) ? Expanded(child:
                  Row(children: [
                    Expanded(child: Text("Gestão de Propostas", style: state._textBotao,textAlign: TextAlign.center),),
                    Container(
                      child: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22,),),
                      width: 27,
                      height: 27,
                      decoration: BoxDecoration(
                        color: Colors.redAccent[700],
                        shape: BoxShape.circle
                      ),
                    )
                  ],))
                      :Expanded(child: Text("Gestão de Propostas", style: state._textBotao,textAlign: TextAlign.center),),
                  padding: EdgeInsets.fromLTRB(16,10,16,10),
                ),
              ),
              Padding(padding: EdgeInsets.only(top:16),
                child: RaisedButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.transparent)),
                  onPressed: (){
                    Navigator.pushNamed(context, "/relatorioServicos", arguments: state._uid);
                  },
                  icon: Row(
                    children: [
                      Icon(Icons.analytics_outlined, color: Colors.white),
                      Icon(Icons.home_repair_service, color: Colors.white)
                    ],),
                  label: Expanded(child: Text("Relatório de Serviços", style: state._textBotao,textAlign: TextAlign.center,),),
                  padding: EdgeInsets.fromLTRB(16,10,16,10),
                ),
              ),
              Padding(padding: EdgeInsets.only(top:16),
                child: RaisedButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.transparent)),
                  onPressed: (){
                    Navigator.pushNamed(context, "/relatorioFinanceiro", arguments: state._uid);
                  },
                  icon: Row(
                    children: [
                      Icon(Icons.analytics_outlined, color: Colors.white),
                      Icon(Icons.monetization_on, color: Colors.white)
                    ],),
                  label: Expanded(child: Text("Relatório Financeiro", style: state._textBotao,textAlign: TextAlign.center,),),
                  padding: EdgeInsets.fromLTRB(16,10,16,10),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top:16),
                child: RaisedButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.transparent)),
                  onPressed: (){
                    Navigator.pushNamed(context, "/conversas");
                  },
                  icon: Icon(Icons.chat, color: Colors.white,),
                  label: (state._notifyConversa) ? Expanded(child:
                  Row(children: [
                    Expanded(child: Text("Conversas", style: state._textBotao,textAlign: TextAlign.center),),
                    Container(
                      child: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22,),),
                      width: 27,
                      height: 27,
                      decoration: BoxDecoration(
                          color: Colors.redAccent[700],
                          shape: BoxShape.circle
                      ),
                    )
                  ],))
                      :Expanded(child: Text("Conversas", style: state._textBotao,textAlign: TextAlign.center),),
                  padding: EdgeInsets.fromLTRB(16,10,16,10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
