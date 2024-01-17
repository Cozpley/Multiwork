import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Model/Proposta.dart';
import 'package:flutter_multiwork/Model/Servico.dart';
import 'package:flutter_multiwork/Util/GerenciarDatas.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';

class ServicoRelatorioServico extends StatefulWidget {
  Proposta proposta;
  ServicoRelatorioServico(this.proposta);
  @override
  _ServicoRelatorioServicoLogica createState() => _ServicoRelatorioServicoLogica();
}

class _ServicoRelatorioServicoLogica extends State<ServicoRelatorioServico>{
  TextStyle _textStyle =TextStyle(color: Colors.white, fontSize: 20);
  TextStyle _textStyle2 =TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
  Servico _serv;
  String _uid;
  bool _oculto=true;

  void _carregarDados(){
    User user = VerificarLogin.verificarLogin(context);
    _uid=user.uid;

    FirebaseFirestore.instance.collection("servicos").doc(widget.proposta.servico.id).get().then((value) {
      Servico serv =Servico.retornarServico(value.data()["descricao"],
          value.data()["titulo"], value.data()["idPrestador"], widget.proposta.servico.id,
          value.data()["modalidade"], value.data()["oculto"]);
      _serv=serv;
      _oculto=_serv.oculto;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) =>_ServicoRelatorioServicoTela(this);
}

class _ServicoRelatorioServicoTela extends WidgetView<ServicoRelatorioServico, _ServicoRelatorioServicoLogica> {
  _ServicoRelatorioServicoTela(_ServicoRelatorioServicoLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Serviço Concluído")),
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
                          widget.proposta.idPrestador==state._uid?
                            Navigator.pushNamed(context, "/exibirMeuServico", arguments: state._serv):
                            Navigator.pushNamed(context, "/servicoOutroUsuario", arguments: state._serv);
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
                        icon: Icon(Icons.person, color:  state._oculto ? Colors.grey[200] : Colors.cyanAccent[400],size: 30,),
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
                        TextSpan(text: "R\$ "+widget.proposta.precoMostrar, style: state._textStyle),
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
            ],
          ),
        ),
      ),
    );
  }
}
