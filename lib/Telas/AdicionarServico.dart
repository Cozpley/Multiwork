import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Util/Indexer.dart';
import 'package:flutter_multiwork/Util/Modalidades.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';

class AdicionarServico extends StatefulWidget {
  @override
  _AdicionarServicoLogica createState() => _AdicionarServicoLogica();
}

class _AdicionarServicoLogica extends State<AdicionarServico>{
  bool _loading=false;
  TextStyle _textStyle= TextStyle(color: Colors.white, fontSize: 20);
  String _dropdownValue;
  List<String> _listaModalidadesExibir;
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController _contrDescricao =TextEditingController();
  TextEditingController _contrTitulo = TextEditingController();
  String _uid;

  _registrarServico() async{
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot ds = await db.collection("usuarios").doc(_uid).get();
    db.collection("servicos").add({
      "idPrestador":_uid,
      "titulo": _contrTitulo.text,
      "descricao": _contrDescricao.text,
      "modalidade": _dropdownValue,
      "oculto":false,
      "index": Indexer.indice(_contrTitulo.text),
      "latitude": ds.data()["latitude"],
      "longitude": ds.data()["longitude"]
    });
    setState(() {
      _loading=false;
    });
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, "/meusServicos");
  }

  _recuperarLista(){
    setState(() {
      _listaModalidadesExibir=GerenciarModalidades.listaExibicao();
      _dropdownValue=_listaModalidadesExibir[0];
    });
  }

  String _validarCampo(value){
    if(value.isEmpty){
      return "Insira uma Descrição";
    }
  }

  _botaoPressionado(){
    if(_key.currentState.validate()){
      setState(() {
        _loading=true;
      });
      _registrarServico();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    try{
      _uid = VerificarLogin.verificarLogin(context).uid;
    }catch(_){}
    _recuperarLista();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _contrDescricao.dispose();
    _contrTitulo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AdicionarServicoTela(this);
}

class _AdicionarServicoTela extends WidgetView<AdicionarServico, _AdicionarServicoLogica> {
  _AdicionarServicoTela(_AdicionarServicoLogica state): super(state);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Adicionar Serviço"),
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
              state.setState(() {
                state._dropdownValue = value;
              });
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
                          validator: (value){
                            return state._validarCampo(value);
                          },
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
                          validator: (value){
                            return state._validarCampo(value);
                          },
                        ),
                      ),
                    ],
                  )
              ),

              state._loading ? Center(child: CircularProgressIndicator(),) :
                RaisedButton(
                  onPressed: state._botaoPressionado,
                  child: Text("Criar", style: state._textStyle),
                )
            ],
          ),
        )
      ),
    );
  }
}
