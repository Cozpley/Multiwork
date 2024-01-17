import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Model/Proposta.dart';
import 'package:flutter_multiwork/Model/Servico.dart';
import 'package:flutter_multiwork/Util/GerenciarDatas.dart';
import 'package:flutter_multiwork/Util/EnviarMensagem.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';

class PropostaAgendada extends StatefulWidget {
  Proposta proposta;
  PropostaAgendada(this.proposta);

  @override
  _PropostaAgendadaLogica createState() => _PropostaAgendadaLogica();
}

class _PropostaAgendadaLogica extends State<PropostaAgendada>{
  TextStyle _textStyle =TextStyle(color: Colors.white, fontSize: 20);
  TextStyle _textStyle2 =TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
  Servico _serv;
  String _uid;
  bool _loading=false;
  String _tokenPrestador;
  String _tokenCliente;
  bool _oculto=true;

  void _carregarDados(){
    User user = VerificarLogin.verificarLogin(context);
    _uid=user.uid;
    FirebaseFirestore db=FirebaseFirestore.instance;
    db.collection("usuarios").doc(widget.proposta.idCliente).get().then((value){
      _tokenCliente=value.data()["MessageToken"];
    });
    db.collection("usuarios").doc(widget.proposta.idPrestador).get().then((value) {
      _tokenPrestador=value.data()["MessageToken"];
    });

    Servico serv;
    FirebaseFirestore.instance.collection("servicos").doc(widget.proposta.servico.id).get().then((value) {
      serv = Servico.retornarServico(value.data()["descricao"], value.data()["titulo"],
          value.data()["idPrestador"], widget.proposta.servico.id, value.data()["modalidade"], value.data()["oculto"]);
      _serv=serv;
      _oculto = _serv.oculto;
    });
  }

  _cancelarProposta(bool MensagemParaPrestador) async{
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("propostas").doc(widget.proposta.idPrestador).collection("propostasAtivas").doc(widget.proposta.id).delete();
    await db.collection("propostas").doc(widget.proposta.idCliente).collection("propostasAtivas").doc(widget.proposta.id).delete();
    if(MensagemParaPrestador){
      SendMessage("Uma solicitação de serviço foi cancelada!", "${widget.proposta.nomeCliente} cancelou a "
          "solicitação de ${widget.proposta.servico.titulo}", _tokenPrestador).send();
    }else{
      SendMessage("Uma solicitação de serviço foi cancelada!", "${widget.proposta.nomePrestador} cancelou a "
          "solicitação de ${widget.proposta.servico.titulo}", _tokenCliente).send();
    }
    Navigator.pop(context);
  }

  _concluir()async{
    FirebaseFirestore db = FirebaseFirestore.instance;
    Map<String, dynamic> mapa ={
      "idServico": widget.proposta.servico.id,
      "tituloServico":widget.proposta.servico.titulo,
      "idPrestador": widget.proposta.idPrestador,
      "nomePrestador": widget.proposta.nomePrestador,
      "idCliente": widget.proposta.idCliente,
      "nomeCliente": widget.proposta.nomeCliente,
      "status": Proposta.CONCLUIDA,
      "preco": widget.proposta.preco,
      "precoMostrar": widget.proposta.precoMostrar,
      "data" :widget.proposta.data,
      "hora":widget.proposta.hora
    };
    await db.collection("propostas").doc(widget.proposta.idPrestador).collection("propostasAtivas").doc(widget.proposta.id).delete();
    await db.collection("propostas").doc(widget.proposta.idCliente).collection("propostasAtivas").doc(widget.proposta.id).delete();
    await db.collection("propostas").doc(widget.proposta.idPrestador).collection("propostasConcluidas").doc(widget.proposta.id).set(mapa);
    await db.collection("propostas").doc(widget.proposta.idCliente).collection("propostasConcluidas").doc(widget.proposta.id).set(mapa);
    SendMessage("Uma solicitação de serviço foi concluida!", "${widget.proposta.nomePrestador} concluiu a "
        "solicitação de ${widget.proposta.servico.titulo}", _tokenCliente).send();
    Navigator.pop(context);
  }

  _setLoading(bool value){
    setState(() {
      _loading=value;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) =>_PropostaAgendadaTela(this);
}

class _PropostaAgendadaTela extends WidgetView<PropostaAgendada, _PropostaAgendadaLogica> {
  _PropostaAgendadaTela(_PropostaAgendadaLogica state): super(state);
  _mostrarPopup(String mensagem, Function f, context){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(mensagem, textAlign: TextAlign.justify),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RaisedButton(onPressed: (){
                  state._setLoading(false);
                  Navigator.of(context).pop();
                },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.transparent)
                  ),
                  child: Text("Fechar", style: TextStyle(color:Colors.white)),
                ),
                RaisedButton(onPressed: (){
                  f();
                  Navigator.of(context).pop();
                },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.transparent)
                  ),
                  child: Text("Confirmar", style: TextStyle(color:Colors.white),),
                ),
              ],
            ),
          );
        }
    );
  }


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
                state._setLoading(true);
                _mostrarPopup("Deseja cancelar esta prestação de serviço? Essa ação não pode ser desfeita!", (){state._cancelarProposta(false);}, state.context);
              },
              child: Text("Cancelar", style: state._textStyle,),
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
                state._setLoading(true);
                _mostrarPopup("Deseja concluir este serviço?",(){ state._concluir();}, state.context);
              },
              child: Text("Concluir", style: state._textStyle,),
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
            state._setLoading(true);
            _mostrarPopup("Deseja cancelar esta prestação de serviço? Essa ação não pode ser desfeita!", (){state._cancelarProposta(true);}, state.context);
          },
          color: Colors.red[700],
          child: Text("Cancelar Agendamento", style: state._textStyle,),
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
      appBar: AppBar(title: Text("Serviço Agendado")),
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
                        icon: Icon(Icons.home_repair_service, color: Colors.cyanAccent[400],size: 30,),
                        onPressed: (){
                          if(widget.proposta.idPrestador==state._uid){
                            Navigator.pushNamed(context, "/exibirMeuServico", arguments: state._serv);
                          }else{
                            Navigator.pushNamed(context, "/servicoOutroUsuario", arguments: state._serv);

                          }

                        },
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
                        icon: Icon(Icons.person, color:state._oculto ? Colors.grey[200] :  Colors.cyanAccent[400],size: 30,),
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
                padding: EdgeInsets.only(bottom: 16),
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

              Padding(
                padding: EdgeInsets.only(bottom: 24),
                child:RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                      children: [
                        TextSpan(text: "Preço: ", style: state._textStyle2),
                        TextSpan(text: "R\$ "+ widget.proposta.precoMostrar, style: state._textStyle),
                      ]
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(bottom: 24),
                child:RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                      children: [
                        TextSpan(text: "Data: ", style: state._textStyle2),
                        TextSpan(text: GerenciarDatas.TextoFirebaseparaUsuario(widget.proposta.data), style: state._textStyle),
                      ]
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(bottom: 32),
                child:RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                      children: [
                        TextSpan(text: "Hora: ", style: state._textStyle2),
                        TextSpan(text: widget.proposta.hora, style: state._textStyle),
                      ]
                  ),
                ),
              ),

              _returnBotoes(),

              Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(" Caso desejem alterar o preço, data ou hora da prestação de serviço já agendada, é necessário excluir-la e criar outra.",
                  style: TextStyle(color: Colors.white70), textAlign: TextAlign.justify,)
              ),

            ],
          ),
        ),
      ),
    );
  }
}
