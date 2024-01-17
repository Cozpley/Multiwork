import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Model/Proposta.dart';
import 'package:flutter_multiwork/Model/Servico.dart';
import 'package:flutter_multiwork/Util/EnviarMensagem.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';

class ServicoOutroUsuario extends StatefulWidget {
  Servico _servico;
  ServicoOutroUsuario(this._servico);

  @override
  _ServicoOutroUsuarioLogica createState() => _ServicoOutroUsuarioLogica();
}

class _ServicoOutroUsuarioLogica  extends State<ServicoOutroUsuario> {
  TextStyle _textStyle =TextStyle(color: Colors.white, fontSize: 20);
  TextStyle _textStyle2 =TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
  String _nomePrestador;
  String _token;
  String _nomeLogado;
  String _uid;
  bool _pendente=false;
  StreamSubscription<QuerySnapshot> _listener;
  bool _oculto=true;
  bool _ready =false;
  FirebaseFirestore _db;

  _carregarDadosPrestador() async{
    DocumentSnapshot ds = await _db.collection("usuarios").doc(widget._servico.idPrestador).get();
    _nomePrestador = ds.data()["nome"];
    _token = ds.data()["MessageToken"];
  }

  _setListener(){
    _listener = _db.collection("propostas").doc(_uid).collection("propostasAtivas")
        .snapshots().listen((event) {
      bool flag = false;
      event.docs.forEach((element) {
        if (element.data()["status"]==Proposta.REQUISITADA && element.data()["idServico"] ==widget._servico.id){
          flag=true;
          setState(() {
            _pendente=true;
          });
        }
      });
      if(flag==false){
        setState(() {
          _pendente=false;
        });
      }
    });
    setState(() {
      _ready= true;
    });
  }

  _carregarDados() async {
    _db = FirebaseFirestore.instance;
    await _carregarDadosPrestador();

    _db.collection("servicos").doc(widget._servico.id).get().then((value){
      setState(() {
        _oculto = value.data()["oculto"];
      });
    });

    User user = VerificarLogin.verificarLogin(context);
    if(user!=null){
      DocumentSnapshot ds= await _db.collection("usuarios").doc(user.uid).get();
      _uid=user.uid;
      _nomeLogado=ds.data()["nome"];

      _setListener();
    }else{
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
    }
  }

  _solicitarServico()async{
    if(_ready){
      FirebaseFirestore db = FirebaseFirestore.instance;
      Map<String, dynamic> mapa ={
        "idServico": widget._servico.id,
        "tituloServico":widget._servico.titulo,
        "idPrestador": widget._servico.idPrestador,
        "nomePrestador": _nomePrestador,
        "idCliente": _uid,
        "nomeCliente": _nomeLogado,
        "status": Proposta.REQUISITADA
      };
      db.collection("propostas").doc(widget._servico.idPrestador).collection("propostasAtivas").add(mapa).
      then((value)async{
        await db.collection("propostas").doc(_uid).collection("propostasAtivas").doc(value.id).set(mapa);
        SendMessage("Serviço Requisitado","${widget._servico.titulo} foi requisitado", _token).send();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>_ServicoOutroUsuarioTela(this);
}

class _ServicoOutroUsuarioTela extends WidgetView<ServicoOutroUsuario, _ServicoOutroUsuarioLogica> {
  _ServicoOutroUsuarioTela(_ServicoOutroUsuarioLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                      children: [
                        TextSpan(text: "Título: ", style: state._textStyle2),
                        TextSpan(text: widget._servico.titulo, style: state._textStyle),
                      ]
                  ),),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: RichText(
                        maxLines: null,
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                            children: [
                              TextSpan(text: "Prestador: ", style: state._textStyle2),
                              TextSpan(text: state._nomePrestador, style: state._textStyle),
                            ]
                        ),),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: IconButton(
                        icon: Icon(Icons.person, color: state._oculto ? Colors.grey[300]: Colors.cyanAccent[400],size: 30),
                        onPressed: (){
                          if(!state._oculto){
                            Navigator.pushNamed(context, "/outroUsuario", arguments:
                            {"id":widget._servico.idPrestador,"nome":state._nomePrestador});
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                      children: [
                        TextSpan(text: "Modalidade: ", style: state._textStyle2),
                        TextSpan(text: widget._servico.modalidade, style: state._textStyle),
                      ]
                  ),),
              ),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                    children: [
                      TextSpan(text: "Descrição: ", style: state._textStyle2),
                      TextSpan(text: widget._servico.descricao, style: state._textStyle),
                    ]
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 32),
                child: state._pendente ? Center(
                  child: Text("Aguardando aprovação", style: TextStyle(fontSize: 20, color: Colors.cyanAccent, fontWeight: FontWeight.bold),),
                ): !state._oculto?
                RaisedButton(
                  onPressed: state._solicitarServico,
                  child: Text("Solicitar Serviço", style: TextStyle(fontSize: 20,color:Colors.white)),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: Colors.transparent
                    )
                  ),
                ): Container()
              )
            ],
          ),
        ),
      ),
    );
  }
}
