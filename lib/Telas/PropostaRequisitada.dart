import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Model/Proposta.dart';
import 'package:flutter_multiwork/Model/Servico.dart';
import 'package:flutter_multiwork/Util/EnviarMensagem.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';

class PropostaRequisitada extends StatefulWidget {
  Proposta proposta;
  PropostaRequisitada(this.proposta);

  @override
  _PropostaRequisitadaLogica createState() => _PropostaRequisitadaLogica();
}

class _PropostaRequisitadaLogica extends State<PropostaRequisitada>{
  TextStyle _textStyle =TextStyle(color: Colors.white, fontSize: 20);
  TextStyle _textStyle2 =TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
  Servico _serv;
  String _uid;
  bool _loading=false;
  String _tokenPrestador;
  String _tokenCliente;
  bool _oculto=true;

  void _carregarDados()async{
    User user = VerificarLogin.verificarLogin(context);
    _uid=user.uid;
    FirebaseFirestore db=FirebaseFirestore.instance;
    await db.collection("usuarios").doc(widget.proposta.idCliente).get().then((value){
      _tokenCliente=value.data()["MessageToken"];
    });
    await db.collection("usuarios").doc(widget.proposta.idPrestador).get().then((value){
      _tokenPrestador=value.data()["MessageToken"];
    });

    Servico serv = Servico();
    serv.id=widget.proposta.servico.id;
    FirebaseFirestore.instance.collection("servicos").doc(widget.proposta.servico.id).get().then((value) {
      serv.idPrestador = value.data()["idPrestador"];
      serv.modalidade = value.data()["modalidade"];
      serv.titulo = value.data()["titulo"];
      serv.descricao = value.data()["descricao"];
      serv.oculto =value.data()["oculto"];
      _serv=serv;
      _oculto =_serv.oculto;
    });
  }

  void _cancelarProposta(bool MensagemParaPrestador) async{
    setState(() {
      _loading=true;
    });
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("propostas").doc(widget.proposta.idPrestador)
        .collection("propostasAtivas").doc(widget.proposta.id).delete();
    await db.collection("propostas").doc(widget.proposta.idCliente)
        .collection("propostasAtivas").doc(widget.proposta.id).delete();
    if(MensagemParaPrestador){
      SendMessage("Uma solicitação de serviço foi cancelada!",
          "${widget.proposta.nomeCliente} cancelou a solicitação de ${widget.proposta.servico.titulo}", _tokenPrestador).send();
    }else{
      SendMessage("Uma solicitação de serviço foi cancelada!",
          "${widget.proposta.nomePrestador} não aceitou a solicitação de ${widget.proposta.servico.titulo}", _tokenCliente).send();
    }
    Navigator.pop(context);
  }



  _irParaServico(){
    if(widget.proposta.idPrestador==_uid){
      Navigator.pushNamed(context, "/exibirMeuServico", arguments: _serv);
    }else{
      Navigator.pushNamed(context, "/servicoOutroUsuario", arguments: _serv);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) =>_PropostaRequisitadaTela(this);
}

class _PropostaRequisitadaTela extends WidgetView<PropostaRequisitada, _PropostaRequisitadaLogica>{
  _PropostaRequisitadaTela(_PropostaRequisitadaLogica state): super(state);


  Widget _returnBotoes(){
    if(state._loading){
      return Center(
        child: CircularProgressIndicator(),
      );
    }else{
      if(widget.proposta.idPrestador==state._uid){
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RaisedButton(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              onPressed: (){
                state._cancelarProposta(false);
              },
              child: Text("Recusar", style: state._textStyle,),
              color: Colors.red[700],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                      color: Colors.transparent
                  )
              ),
            ),
            RaisedButton(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              onPressed: (){
                Navigator.pushNamed(state.context, "/aceitarProposta",
                    arguments: {"proposta":widget.proposta, "token":state._tokenCliente});
              },
              child: Text("Aceitar", style: state._textStyle,),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                      color: Colors.transparent
                  )
              ),
            )
          ],
        );
      }else{
        return RaisedButton(
          onPressed: (){
            state._cancelarProposta(true);
          },
          color: Colors.red[700],
          child: Text("Cancelar Solicitação", style: state._textStyle,),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                  color: Colors.transparent
              )
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Solicitação de Serviço")),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                            children: [
                              TextSpan(text: "Serviço: ", style: state._textStyle2),
                              TextSpan(text: widget.proposta.servico.titulo, style: state._textStyle),
                            ]
                        ),),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: IconButton(
                        icon: Icon(Icons.home_repair_service,  color: Colors.cyanAccent[400],size: 30,),
                        onPressed: state._irParaServico,
                      ),
                    )
                  ],
                ),
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
                              TextSpan(text: widget.proposta.nomePrestador, style: state._textStyle),
                            ]
                        ),),
                    ),
                    widget.proposta.idPrestador==state._uid? Container():Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: IconButton(
                        icon: Icon(Icons.person, color: state._oculto ? Colors.grey[200] : Colors.cyanAccent[400],size: 30,),
                        onPressed: (){
                          if(!state._oculto){
                            Navigator.pushNamed(context, "/outroUsuario", arguments: {"id":widget.proposta.idPrestador,"nome":widget.proposta.nomePrestador});
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 32),
                child: Row(
                  children: [
                    Expanded(
                      child: RichText(
                        maxLines: null,
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                            children: [
                              TextSpan(text: "Cliente: ", style: state._textStyle2),
                              TextSpan(text: widget.proposta.nomeCliente, style: state._textStyle),
                            ]
                        ),),
                    ),
                    widget.proposta.idCliente==state._uid? Container():
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: IconButton(
                        icon: Icon(Icons.person, color: Colors.cyanAccent[400],size: 30,),
                        onPressed: (){
                          Navigator.pushNamed(context, "/outroUsuario", arguments: {"id":widget.proposta.idCliente,"nome":widget.proposta.nomeCliente});
                        },
                      ),
                    )
                  ],
                ),
              ),
              _returnBotoes()
            ],
          ),
        ),
      ),
    );
  }
}
