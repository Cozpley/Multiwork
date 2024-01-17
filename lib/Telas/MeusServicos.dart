import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Model/Servico.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';

class MeusServicos extends StatefulWidget {
  @override
  _MeusServicosLogica createState() => _MeusServicosLogica();
}

class _MeusServicosLogica extends State<MeusServicos>{
  String _uid;

  Future<List<Servico>> _chamarServicos() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<Servico> retorno = List();
    QuerySnapshot qs = await db.collection("servicos")
        .where("idPrestador", isEqualTo: _uid).get();

    for(DocumentSnapshot ds in qs.docs){
      Servico servico = Servico.retornarServico(ds["descricao"],ds["titulo"], _uid,
          ds.id, ds["modalidade"],ds["oculto"]);
      retorno.add(servico);
    }
    return retorno;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    try{
      _uid =VerificarLogin.verificarLogin(context).uid;
    }catch(_){}
  }

  @override
  Widget build(BuildContext context) =>_MeusServicosTela(this);
}

class _MeusServicosTela extends WidgetView<MeusServicos, _MeusServicosLogica> {
  _MeusServicosTela(_MeusServicosLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(padding: EdgeInsets.only(right: 16),
            child: IconButton(icon: Icon(Icons.add_circle, size: 35,), onPressed: (){
              Navigator.pushNamed(context, "/adicionarServico");
            }),
          )
        ],
        title: Text("Meus Serviços"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: FutureBuilder<List<Servico>>(
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
                                color: dados[index].oculto ? Colors.white38:Colors.transparent,
                                child: Padding(
                                padding: EdgeInsets.all(16),
                                  child:Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: Text(dados[index].titulo, style: TextStyle(fontSize: 20, color: Colors.white), maxLines: null),),
                                          dados[index].oculto ? Text("Oculto", style: TextStyle(color:Colors.redAccent[100], fontWeight: FontWeight.bold),):Container()
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                            ),
                            onTap: (){
                              Navigator.pushNamed(context, "/exibirMeuServico", arguments: dados[index]);
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
        ),
      )
    );
  }
}
