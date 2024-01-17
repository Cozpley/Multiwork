import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Model/Proposta.dart';
import 'dart:async';
import 'package:flutter_multiwork/Util/GerenciarDatas.dart';
import 'package:flutter_multiwork/Model/Servico.dart';

class TelaNaoConcluidos extends StatefulWidget {
  String _uid;
  TelaNaoConcluidos(this._uid);

  @override
  _TelaNaoConcluidosLogica createState() => _TelaNaoConcluidosLogica();
}

class _TelaNaoConcluidosLogica extends State<TelaNaoConcluidos> {
  TextStyle _textStyle= TextStyle(color: Colors.white, fontSize: 20);
  TextStyle _textStyle2= TextStyle(color: Colors.white70, fontSize: 15);
  final _controler = StreamController<QuerySnapshot>.broadcast();
  String _data;

  void _listenerPropostas() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("propostas").doc(widget._uid).collection("propostasAtivas").where("status", isEqualTo:
    Proposta.AGENDADA)
        .where("data", isLessThan: _data).orderBy("data").orderBy("hora")
        .snapshots()
      ..listen((dados) {
        _controler.add(dados);
      });
  }

  Proposta _retornarProposta(DocumentSnapshot item, Servico serv){
    Proposta proposta= Proposta.retornarProposta(
        item.id, serv, item.data()["idCliente"], item.data()["nomeCliente"],
        item.data()["idPrestador"], item.data()["nomePrestador"]);
    proposta.precoMostrar=item.data()["precoMostrar"];
    proposta.preco=item.data()["preco"];
    proposta.data=item.data()["data"];
    proposta.hora=item.data()["hora"];
    return proposta;
  }

  @override
  void initState() {
    super.initState();
    _data  = GerenciarDatas.DataparaTextoFirebase(DateTime.now());
    _listenerPropostas();
  }

  @override
  void dispose() {
    _controler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>_TelaNaoConcluidosTela(this);
}

class _TelaNaoConcluidosTela extends WidgetView<TelaNaoConcluidos, _TelaNaoConcluidosLogica> {
  _TelaNaoConcluidosTela(_TelaNaoConcluidosLogica state): super(state);

  Card _returnCard(Proposta proposta){
    return Card(
        color: Colors.transparent,
        child: ListTile(
            title: Padding( padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Text(proposta.hora, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
                  Text(proposta.servico.titulo, style: state._textStyle, overflow: TextOverflow.ellipsis, maxLines: 1),
                ],
              ),),
            subtitle: proposta.idPrestador == widget._uid ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Prestador: Você",
                  style: state._textStyle2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(padding: EdgeInsets.only(top: 5, bottom: 5),
                  child: Text("Cliente: " + proposta.nomeCliente,
                    style: state._textStyle2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 5, bottom: 5),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text("R\$ ${proposta.precoMostrar}",
                        style: TextStyle(fontSize: 18, color: Colors.greenAccent[200], fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis
                    ),
                  ),
                )
              ],
            ): Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Prestador: "+ proposta.nomePrestador,
                  style: state._textStyle2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(padding: EdgeInsets.only(top:5, bottom: 5),
                  child: Text("Cliente: Você",
                    style: state._textStyle2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 5, bottom: 5),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text("R\$ ${proposta.precoMostrar}",
                        style: TextStyle(fontSize: 18, color: Colors.redAccent[100], fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis
                    ),
                  ),
                )
              ],
            )

        )
    );}

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: StreamBuilder(
            stream: state._controler.stream,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Carregando", style: state._textStyle,),
                          ),
                          CircularProgressIndicator()
                        ],
                      ));
                  break;
                default:
                  QuerySnapshot querySnapshot = snapshot.data;
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Erro ao  carregar dados", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    );
                  }else if(querySnapshot.docs.length==0){
                    return Center(
                      child: Text("Não há serviços pendentes", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    );
                  } else {
                    String data;
                    return  ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: querySnapshot.docs.length,
                        itemBuilder: (context, index) {
                          List<DocumentSnapshot> lista = querySnapshot.docs.toList();
                          DocumentSnapshot item = lista[index];
                          Servico serv= Servico.retornarBasico(item.data()["idServico"],
                              item.data()["tituloServico"]);
                          Proposta proposta = state._retornarProposta(item, serv);
                          if(data!=proposta.data){
                            data=proposta.data;
                            return Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Column(
                                children: [
                                  Padding(padding: EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text("__________", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                                          Text(GerenciarDatas.TextoFirebaseparaUsuario(proposta.data), style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),),
                                          Text("__________", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                                        ],
                                      )
                                  ),
                                  GestureDetector(
                                    child: proposta.idPrestador==widget._uid ? Stack(children: [
                                      _returnCard(proposta),
                                      Positioned(
                                          top: 5,
                                          right: 5,
                                          child: Container(
                                              child: Padding(padding: EdgeInsets.only(bottom: 8, top: 0), child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 26,),),
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: Colors.redAccent[700],
                                                  shape: BoxShape.circle
                                              )
                                          )
                                      )
                                    ],) :
                                    _returnCard(proposta),
                                    onTap: (){
                                      Navigator.pushNamed(context, "/propostaAgendada", arguments: proposta);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }else{
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: GestureDetector(
                                child: proposta.idPrestador==widget._uid ? Stack(children: [
                                  _returnCard(proposta),
                                  Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Container(
                                          child: Padding(padding: EdgeInsets.only(bottom: 8, top: 0), child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 26,),),
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              color: Colors.redAccent[700],
                                              shape: BoxShape.circle
                                          )
                                      )
                                  )
                                ],) :
                                _returnCard(proposta),
                                onTap: (){
                                  Navigator.pushNamed(context, "/propostaAgendada", arguments: proposta);
                                },
                              ),
                            );
                          }
                        }
                    );
                  }
                  break;
              }
            })
    );
  }
}
