import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Model/Proposta.dart';
import 'package:flutter_multiwork/Model/Servico.dart';
import 'package:flutter_multiwork/Util/GerenciarDatas.dart';

class RelatorioServicos extends StatefulWidget {
  String _uid;
  RelatorioServicos(this._uid);
  @override
  _RelatorioServicosLogica createState() => _RelatorioServicosLogica();
}

class _RelatorioServicosLogica extends State<RelatorioServicos> {
  TextStyle _textStyle= TextStyle(color: Colors.white, fontSize: 20);
  TextStyle _textStyle2= TextStyle(color: Colors.white70, fontSize: 15);

  Future<List<Proposta>> _chamarPropostas() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<Proposta> retorno = List();
    QuerySnapshot qs = await db.collection("propostas").doc(widget._uid).collection("propostasConcluidas").
    orderBy("data",descending: true).orderBy("hora", descending: true).get();
    for(DocumentSnapshot documento in qs.docs){
      Servico serv= Servico.retornarBasico(documento.data()["idServico"],
          documento.data()["tituloServico"]);

      Proposta p= Proposta.retornarProposta(
          documento.id, serv, documento.data()["idCliente"], documento.data()["nomeCliente"],
          documento.data()["idPrestador"], documento.data()["nomePrestador"]);
      p.data=documento.data()["data"];
      p.hora=documento.data()["hora"];
      p.precoMostrar= documento.data()["precoMostrar"];
      p.preco = documento.data()["preco"];
      retorno.add(p);
    }
    return retorno;
  }
  @override
  Widget build(BuildContext context) =>_RelatorioServicosTela(this);
}

class _RelatorioServicosTela extends WidgetView<RelatorioServicos, _RelatorioServicosLogica> {
  _RelatorioServicosTela(_RelatorioServicosLogica state): super(state);

  Container _returnCard(Proposta proposta){
    return Container(
      padding: EdgeInsets.only(bottom: 16),
      child: Card(
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
      ),
    );}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Relatório de Serviços"),),
      body: FutureBuilder<List<Proposta>>(
        future: state._chamarPropostas(),
        builder: (context, snap) {
          switch (snap.connectionState) {
            case ConnectionState.waiting:
              return Padding(padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
              break;
            default:
              if(!snap.hasError && snap.hasData) {
                String data;
                return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: snap.data.length,
                    itemBuilder: (context, index) {;
                      Proposta proposta= snap.data[index];

                      if(data!=proposta.data){
                        data=proposta.data;
                        return Column(
                          children: [
                            Padding(padding: EdgeInsets.only(top: index==0?16:4, bottom: 8),
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
                              child: _returnCard(proposta),
                              onTap: (){
                                Navigator.pushNamed(context, "/servicoRelatorioServico", arguments: proposta);
                              },
                            ),
                          ],
                        );
                      }else{
                        return GestureDetector(
                          child: _returnCard(proposta),
                          onTap: (){
                            Navigator.pushNamed(context, "/servicoRelatorioServico", arguments: proposta);
                          },
                        );
                      }
                    }
                );
              }else{
                if(snap.hasError){
                  return Container();
                }else{
                  return Center(
                    child: Text(
                        "Não há serviços concluídos",
                      style: state._textStyle,
                    ),
                  );
                }
              }
          }
        },
      )
    );
  }
}
