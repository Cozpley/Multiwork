import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Model/Proposta.dart';
import 'package:flutter_multiwork/Model/Servico.dart';

class TelaPropostasRecebidas extends StatefulWidget {
  String _uid;
  TelaPropostasRecebidas(this._uid);

  @override
  _TelaPropostasRecebidasLogica createState() => _TelaPropostasRecebidasLogica();
}

class _TelaPropostasRecebidasLogica extends State<TelaPropostasRecebidas>{

  TextStyle _textStyle= TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
  TextStyle _textStyle2= TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold);
  final _controler = StreamController<QuerySnapshot>.broadcast();

  void _listenerPropostas() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("propostas").doc(widget._uid).collection("propostasAtivas").where("status", isEqualTo: Proposta.REQUISITADA)
        .snapshots()
      ..listen((dados) {
       if(!_controler.isClosed){
         _controler.add(dados);
       }
      });
  }

  Card _returnCard(Proposta proposta){
    return Card(
        color: Colors.transparent,
        child: ListTile(
            title: Padding( padding: EdgeInsets.symmetric(vertical: 8), child: Text(proposta.servico.titulo, style: _textStyle, overflow: TextOverflow.ellipsis, maxLines: 1,),),
            subtitle: proposta.idPrestador == widget._uid ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Prestador: Você",
                  style: _textStyle2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(padding: EdgeInsets.only(top: 5, bottom: 5),
                  child: Text("Cliente: " + proposta.nomeCliente,
                    style: _textStyle2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ): Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Prestador: "+ proposta.nomePrestador,
                  style: _textStyle2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(padding: EdgeInsets.only(top:5, bottom: 5),
                  child: Text("Cliente: Você",
                    style: _textStyle2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            )

        )
    );}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listenerPropostas();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>_TelaPropostasRecebidasTela(this);
}

class _TelaPropostasRecebidasTela extends WidgetView<TelaPropostasRecebidas, _TelaPropostasRecebidasLogica> {
  _TelaPropostasRecebidasTela(_TelaPropostasRecebidasLogica state): super(state);

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
                    child: Text("Erro ao  carregar dados", style: state._textStyle),
                  );
                }else if(querySnapshot.docs.length==0){
                  return Center(
                    child: Text("Não há solicitações de serviço", style: state._textStyle),
                  );
                } else {
                  return  ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: querySnapshot.docs.length,
                        itemBuilder: (context, index) {
                          List<DocumentSnapshot> lista = querySnapshot.docs.toList();
                          DocumentSnapshot item = lista[index];
                          Servico serv= Servico.retornarBasico(item.data()["idServico"],
                              item.data()["tituloServico"]);

                          Proposta proposta= Proposta.retornarProposta(
                              item.id, serv, item.data()["idCliente"], item.data()["nomeCliente"],
                              item.data()["idPrestador"], item.data()["nomePrestador"]);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: GestureDetector(
                              child: proposta.idPrestador==widget._uid ? Stack(children: [
                                state._returnCard(proposta),
                                Positioned(
                                    top: 5,
                                    right: 5,
                                    child: Container(
                                        child: Padding(padding: EdgeInsets.only(bottom: 8, top: 0),
                                          child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 26,),),
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                            color: Colors.redAccent[700],
                                            shape: BoxShape.circle
                                        )
                                    )
                                )
                              ],) :
                              state._returnCard(proposta),
                              onTap: (){
                                Navigator.pushNamed(context, "/propostaRequisitada", arguments: proposta);
                              },
                            ),
                          );
                        }
                  );
                }
                break;
            }
          })
    );
  }
}
