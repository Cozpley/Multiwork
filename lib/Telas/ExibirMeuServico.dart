import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Model/Servico.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';

class ExibirMeuServico extends StatefulWidget {
  Servico _servico;
  ExibirMeuServico(this._servico);

  @override
  _ExibirMeuServicoLogica createState() => _ExibirMeuServicoLogica();
}

class _ExibirMeuServicoLogica extends State<ExibirMeuServico>{
  TextStyle _textStyle =TextStyle(color: Colors.white, fontSize: 20);
  TextStyle _textStyle2 =TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
  String _uid;

  _tentarDeletar()async{
    FirebaseFirestore db=FirebaseFirestore.instance;
    QuerySnapshot qs = await db.collection("propostas").doc(_uid).collection("propostasAtivas").where("idServico", isEqualTo: widget._servico.id).get();
    QuerySnapshot qs2 = await db.collection("propostas").doc(_uid).collection("propostasConcluidas").where("idServico", isEqualTo: widget._servico.id).get();
    if(qs.docs.isEmpty && qs2.docs.isEmpty){
      showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: Text("Deseja excluir o serviço? Esta ação não pode ser desfeita!",
                textAlign: TextAlign.justify,),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RaisedButton(onPressed: (){
                    Navigator.of(context).pop();
                  },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.transparent)
                    ),
                    child: Text("Cancelar", style: TextStyle(color:Colors.white),),
                  ),
                  RaisedButton(onPressed: (){
                    _deletarServico();
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(context, "/meusServicos");
                  },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.transparent)
                    ),
                    child: Text("Excluir", style: TextStyle(color:Colors.white)),
                  ),
                ],
              ),
            );
          }
      );
    }else{
      showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: Text("Você não pode excluir este serviço, pois propostas já foram feitas.\nEntretanto, "
                  "você pode o ocultar para clientes na página de edição do serviço.", style: TextStyle(color: Colors.red[600]),
                textAlign: TextAlign.justify,),
              actions: [
                RaisedButton(onPressed: (){
                  Navigator.of(context).pop();
                },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.transparent)
                  ),
                  child: Text("Entendi", style: TextStyle(color:Colors.white),),
                ),
              ],
            );
          }
      );
    }
  }

  _deletarServico()async{
    FirebaseFirestore db=FirebaseFirestore.instance;
    db.collection("servicos").doc(widget._servico.id).delete();
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    try{
      _uid=VerificarLogin.verificarLogin(context).uid;
    }catch(_){}
  }

  @override
  Widget build(BuildContext context) =>_ExibirMeuServicoTela(this);
}

class _ExibirMeuServicoTela extends WidgetView<ExibirMeuServico, _ExibirMeuServicoLogica> {
  _ExibirMeuServicoTela(_ExibirMeuServicoLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(icon: Icon(Icons.edit, color: Colors.white), onPressed: (){
            Navigator.pushNamed(context, "/editarServico", arguments: widget._servico);
          }),
          IconButton(icon: Icon(Icons.delete_forever, color: Colors.red[400]),
              onPressed:state._tentarDeletar),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              ),),
            ],
          ),
        ),
      ),
    );
  }
}
