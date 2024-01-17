import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Model/Servico.dart';
import 'package:geolocator/geolocator.dart';

class ResultadosProcurarServico extends StatefulWidget {
  String _uid;
  String _pesquisa;
  String _modalidade;

  ResultadosProcurarServico(this._uid, this._pesquisa, this._modalidade);

  @override
  _ResultadosProcurarServicoLogica createState() => _ResultadosProcurarServicoLogica();
}

class _ResultadosProcurarServicoLogica extends State<ResultadosProcurarServico> {
  TextStyle _textStyle= TextStyle(color: Colors.white, fontSize: 20);
  TextStyle _textStyle2= TextStyle(color: Colors.white70, fontSize: 15);

  Future<List<Servico>> _chamarServicos() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<Servico> retorno = List();
    await db.collection("usuarios").doc(widget._uid).get().then((ds) async{
      Query query = db.collection("servicos");
      if(widget._pesquisa.length>0){
        List<String> strings = removeDiacritics(widget._pesquisa).toLowerCase().split(" ");
        for(String str in strings){
          if(str!=""){
            str="index.$str";
            query=query.where(str, isEqualTo: true);
          }
        }
      }
      if(widget._modalidade!=""){
        query=query.where("modalidade", isEqualTo: widget._modalidade);
      }
      QuerySnapshot qs = await query.get();
      for(DocumentSnapshot documento in qs.docs){
        if(documento.data()["oculto"]==false && documento.data()["idPrestador"]!=widget._uid){
          Servico servico = Servico.retornarServico (documento.data()["descricao"],
              documento.data()["titulo"],documento.data()["idPrestador"], documento.id,
              documento.data()["modalidade"], documento.data()["oculto"]);
          servico.distancia = Geolocator.distanceBetween(
              double.parse(ds.data()["latitude"]), double.parse(ds.data()["longitude"]),
              double.parse(documento.data()["latitude"]),
              double.parse(documento.data()["longitude"]));
          retorno.add(servico);
        }
      }
    });
    retorno.sort((a,b)=>a.distancia.compareTo(b.distancia));
    return retorno;
  }

  @override
  Widget build(BuildContext context) =>_ResultadosProcurarServicoTela(this);
}

class _ResultadosProcurarServicoTela extends WidgetView<ResultadosProcurarServico, _ResultadosProcurarServicoLogica> {
  _ResultadosProcurarServicoTela(_ResultadosProcurarServicoLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Servico>>(
      future: state._chamarServicos(),
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
              List<Servico> dados = snap.data;
              return Container(
                padding: EdgeInsets.only(top: 8),
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: dados.length,
                    itemBuilder: (context, index){
                      return GestureDetector(
                        child: Card(
                            color: Colors.transparent,
                            child: ListTile(
                              title: Text(dados[index].titulo, style: state._textStyle),
                              subtitle: Text(dados[index].descricao,
                                  style: state._textStyle2,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            )
                        ),
                        onTap: (){
                          Navigator.pushNamed(context, "/servicoOutroUsuario", arguments: dados[index]);
                        },
                      );
                    }
                ),
              );
            }else{
              return Container();
            }
        }
      },
    );
  }
}
