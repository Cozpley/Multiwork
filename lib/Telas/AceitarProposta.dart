import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Model/Proposta.dart';
import 'package:flutter_multiwork/Util/GerenciarDatas.dart';
import 'package:flutter_multiwork/Util/EnviarMensagem.dart';

class AceitarProposta extends StatefulWidget {
  Proposta proposta;
  String tokenCliente;
  AceitarProposta(Map<String, dynamic> mapa){
    this.proposta = mapa["proposta"];
    this.tokenCliente = mapa["token"];
  }

  @override
  _AceitarPropostaLogica createState() => _AceitarPropostaLogica();
}

class _AceitarPropostaLogica extends State<AceitarProposta>{
  String _dataStr = "Escolha uma data";
  String _dataFirebase;
  bool _carregando=false;
  String _timeStr = "Escolha uma hora";
  String _text;
  TextEditingController _controller= TextEditingController();

  _selecionarHora()async {
    TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeStr = picked.format(context);
      });
    }
  }

  _selecionarData()async{
    DateTime date =DateTime.now();
    DateTime picked = await showDatePicker(
        locale: Locale("pt", "BR"),
        context: context,
        fieldLabelText: "",
        initialDate: date,
        firstDate: date,
        lastDate: DateTime(date.year+1,date.month,date.day));
    if (picked != null) {
      String data = GerenciarDatas.DataparaTextoUsuario(picked);
      setState(() {
        _dataStr = data;
      });
      _dataFirebase = GerenciarDatas.DataparaTextoFirebase(picked);
    }
  }

  void _salvar() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    double preco = double.parse(_controller.text.replaceAll(".", "").replaceAll(",", "."));
    Map<String, dynamic> mapa ={
      "status" : Proposta.AGENDADA,
      "precoMostrar" : _controller.text,
      "preco" : preco,
      "data" : _dataFirebase,
      "hora":_timeStr
    };

    await db.collection("propostas").doc(widget.proposta.idPrestador).collection("propostasAtivas").
    doc(widget.proposta.id).update(mapa);

    await db.collection("propostas").doc(widget.proposta.idCliente).collection("propostasAtivas").
    doc(widget.proposta.id).update(mapa);

    SendMessage("Uma solicitação de serviço foi aceita!", "${widget.proposta.nomePrestador} aceitou a solicitação de ${widget.proposta.servico.titulo}", widget.tokenCliente).send();

    Navigator.pop(context);
    Navigator.pop(context);
  }

  _botaoSalvarPressionado(){
    if ( _dataFirebase!=null && _controller.text!="" && _timeStr!="Escolha uma hora"){
      setState(() {
        _carregando=true;
        _salvar();
      });
    } else {
      setState(() {
        _text = "Preencha todos os campos corretamente";
      });
    }
  }

  @override
  Widget build(BuildContext context) =>_AceitarPropostaTela(this);
}

class _AceitarPropostaTela extends WidgetView<AceitarProposta, _AceitarPropostaLogica> {
  _AceitarPropostaTela(_AceitarPropostaLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aceitar Proposta"),
      ),

      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text(state._dataStr, style:
                      TextStyle(fontSize: 18, color: Colors.white), textAlign: TextAlign.center,)
                  ),
                  RaisedButton(
                    child: Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.white,
                    ),
                    onPressed: state._selecionarData
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                      child: Text(state._timeStr, style: TextStyle(fontSize: 18, color: Colors.white), textAlign: TextAlign.center,)
                  ),
                  RaisedButton(
                      child: Icon(
                        Icons.access_time,
                        color: Colors.white,
                      ),
                      onPressed: state._selecionarHora
                  ),
                ],
              ),

              Padding(
                padding: EdgeInsets.only(top: 12, bottom: 16),
                child: Row(
                  children: [
                    Padding(padding: EdgeInsets.only(right: 8),
                      child: Text("Preço: ", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                    Expanded(child: TextField(
                      controller: state._controller,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 18),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        RealInputFormatter(centavos: true)
                      ],
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(8),
                          prefixText: "R\$ ",
                          hintText: "Insira o preço"
                      ),
                    ),)
                  ],
                )
              ),

              state._text == null ? Container() :
              Center(
                child: Text(
                  state._text,
                  textAlign: TextAlign.center,
                  style:
                  TextStyle(fontSize: 20, color: Colors.redAccent),
                ),
              ),
            !state._carregando ? Padding(
              padding: EdgeInsets.only(top: 16),
              child: RaisedButton(
                padding: EdgeInsets.fromLTRB(20, 6, 20, 6),
                child: Text(
                  "Agendar",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: state._botaoSalvarPressionado
              ),
            ) : Center(
              child: CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
