import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Util/GerarRelatorioFinanceiro.dart';

class RelatorioAnual extends StatefulWidget {
  String _uid;
  RelatorioAnual(this._uid);
  @override
  _RelatorioAnualLogica createState() => _RelatorioAnualLogica();
}

class _RelatorioAnualLogica extends State<RelatorioAnual>{
  List<String> retorno;
  _definirRetorno()async{
    List<String> retornoAux =await GerarRelatorioFinanceiro.chamarPropostas(widget._uid,2);
    setState(() {
      retorno=retornoAux;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _definirRetorno();
  }
  @override
  Widget build(BuildContext context) => _RelatorioAnualTela(this);
}

class _RelatorioAnualTela extends WidgetView<RelatorioAnual, _RelatorioAnualLogica>{
  _RelatorioAnualTela(_RelatorioAnualLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: (state.retorno==null)? Padding(padding: EdgeInsets.all(32),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ):
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RichText(
                maxLines: null,
                textAlign: TextAlign.start,
                text: TextSpan(
                    children: [
                      TextSpan(text: "Receitas: ", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                      TextSpan(text: "R\$: "+ state.retorno[0], style:TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.greenAccent[200])),
                    ]
                ),),
              RichText(
                maxLines: null,
                textAlign: TextAlign.start,
                text: TextSpan(
                    children: [
                      TextSpan(text: "Despesas: ", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                      TextSpan(text: "R\$: "+ state.retorno[1], style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.redAccent[100])),
                    ]
                ),),
              RichText(
                maxLines: null,
                textAlign: TextAlign.start,
                text: TextSpan(
                    children: [
                      TextSpan(text: "Diferença: ", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                      TextSpan(text: "R\$: "+ state.retorno[2], style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: state.retorno[2].startsWith("-") ? Colors.redAccent[100] : Colors.greenAccent[200])),
                    ]
                ),),
            ],
          ),
        )

    );

  }
}
