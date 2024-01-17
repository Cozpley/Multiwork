import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Model/Servico.dart';
import 'package:flutter_multiwork/Util/Indexer.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';
import 'package:flutter_multiwork/Util/Modalidades.dart';

class EditarServico extends StatefulWidget {
  Servico _servico;
  EditarServico(this._servico);

  @override
  _EditarServicoLogica createState() => _EditarServicoLogica();
}

class _EditarServicoLogica extends State<EditarServico>{
  bool _loading=false;
  TextStyle _textStyle= TextStyle(color: Colors.white, fontSize: 20);
  String _dropdownValue;
  List<String> _listaModalidadesExibir;
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController _contrDescricao =TextEditingController();
  TextEditingController _contrTitulo = TextEditingController();
  String _uid;
  bool _oculto;

  _editarServico() async{
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot ds = await db.collection("usuarios").doc(_uid).get();
    db.collection("servicos").doc(widget._servico.id).update({
      "titulo": _contrTitulo.text,
      "descricao": _contrDescricao.text,
      "modalidade": _dropdownValue,
      "oculto":_oculto,
      "index": Indexer.indice(_contrTitulo.text),
      "latitude": ds.data()["latitude"],
      "longitude": ds.data()["longitude"]
    });

    await db.collection("propostas").doc(_uid).collection("propostasAtivas").where("idServico", isEqualTo: widget._servico.id).get().then((value) async{
      for(DocumentSnapshot d in value.docs){
        await db.collection("propostas").doc(d.data()["idPrestador"]).collection("propostasAtivas").doc(d.id).update({"tituloServico" : _contrTitulo.text});
        await db.collection("propostas").doc(d.data()["idCliente"]).collection("propostasAtivas").doc(d.id).update({"tituloServico" : _contrTitulo.text});
      }
    });

    await db.collection("propostas").doc(_uid).collection("propostasConcluidas").where("idServico", isEqualTo: widget._servico.id).get().then((value) async{
      for(DocumentSnapshot d in value.docs){
        await db.collection("propostas").doc(d.data()["idPrestador"]).collection("propostasConcluidas").doc(d.id).update({"tituloServico" : _contrTitulo.text});
        await db.collection("propostas").doc(d.data()["idCliente"]).collection("propostasConcluidas").doc(d.id).update({"tituloServico" : _contrTitulo.text});
      }
    });

    setState(() {
      _loading=false;
    });
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, "/meusServicos");
  }

  _carregarDados(){
    setState(() {
      _listaModalidadesExibir=GerenciarModalidades.listaExibicao();
      _dropdownValue=widget._servico.modalidade;
    });
    _contrDescricao.text=widget._servico.descricao;
    _contrTitulo.text=widget._servico.titulo;
    _oculto=widget._servico.oculto;
  }

  _changeValueDropdown(String value){
    setState(() {
      _dropdownValue = value;
    });
  }

  _changeValueOculto(bool value){
    setState(() {
      _oculto = value;
    });
  }

  _salvarPressionado(){
    if(_key.currentState.validate()){
      setState(() {
        _loading=true;
      });
      _editarServico();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    try{
      _uid=VerificarLogin.verificarLogin(context).uid;
    }catch(_){}
    _carregarDados();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _contrDescricao.dispose();
    _contrTitulo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>_EditarServicoTela(this);
}

class _EditarServicoTela extends WidgetView<EditarServico, _EditarServicoLogica> {
  _EditarServicoTela(_EditarServicoLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Serviço"),
      ),

      body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(padding: EdgeInsets.only(bottom:10),
                  child: Text("Selecione uma categoria:", textAlign: TextAlign.center, style: state._textStyle),
                ),
                DropdownButton<String>(
                  value: state._dropdownValue,
                  icon: Padding(padding: EdgeInsets.only(bottom: 10),
                    child: Icon(Icons.arrow_downward, color: Colors.cyan[200],),
                  ),
                  iconSize: 24,
                  isExpanded: true,
                  style: state._textStyle,
                  dropdownColor: Colors.grey[700],
                  underline: Container(
                    height: 1.5,
                    color: Colors.cyan[200],
                  ),
                  onChanged: (String value) {
                    state._changeValueDropdown(value);
                  },
                  items: state._listaModalidadesExibir
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: EdgeInsets.only(left: 32, right: 32, bottom: 10),
                        child: Text(value),
                      ),
                    );
                  }).toList(),
                ),
                Form(
                    key: state._key,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top:16, bottom: 16),
                          child: TextFormField(
                            controller: state._contrTitulo,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: "Insira um Título",
                            ),
                            style: TextStyle(fontSize: 20),
                            validator: ((value){
                              if(value.isEmpty){
                                return "Insira um Título";
                              }
                            }),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: TextFormField(
                            maxLines: null,
                            controller: state._contrDescricao,
                            keyboardType: TextInputType.multiline,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: "Insira uma Descrição",
                            ),
                            style: TextStyle(fontSize: 20),
                            validator: ((value){
                              if(value.isEmpty){
                                return "Insira uma Descrição";
                              }
                            }),
                          ),
                        ),
                      ],
                    )
                ),

                Padding(
                  padding: EdgeInsets.only(top:8, bottom: 8),
                  child: SwitchListTile(
                      contentPadding: EdgeInsets.all(2),
                      title: Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          "Deseja ocultar seu serviço para outros usuários?",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      inactiveThumbColor: Color.fromRGBO(240, 240, 240, 1),
                      inactiveTrackColor: Color.fromRGBO(150, 150, 150, 1),
                      subtitle: state._oculto?
                      Text("Seu serviço está oculto. Lembre-se de apertar o botão \"Salvar\" para aplicar mudanças", style: TextStyle(fontSize: 15, color: Colors.white70)):
                      Text("Seu serviço não está oculto. Lembre-se de apertar o botão \"Salvar\" para aplicar mudanças", style: TextStyle(fontSize: 15, color: Colors.white70)),
                      value: state._oculto,
                      onChanged: (value){
                        state._changeValueOculto(value);
                      }
                  ),
                ),

                state._loading ? Center(child: CircularProgressIndicator(),) :
                RaisedButton(
                  onPressed: state._salvarPressionado,
                  child: Text("Salvar", style: state._textStyle,),
                )
              ],
            ),
          )
      )
    );
  }
}


