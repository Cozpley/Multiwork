import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Telas/RelatorioFinanceiro/RelatorioCompleto.dart';
import 'package:flutter_multiwork/Telas/RelatorioFinanceiro/RelatorioMensal.dart';
import 'package:flutter_multiwork/Telas/RelatorioFinanceiro/RelatorioAnual.dart';

class RelatorioFinanceiro extends StatefulWidget {
  String _uid;
  List<Widget> _widgetOptions;
  RelatorioFinanceiro(this._uid){
    this._widgetOptions=<Widget>[
      RelatorioMensal(_uid),
      RelatorioAnual(_uid),
      RelatorioCompleto(_uid),
    ];
  }
  @override
  _RelatorioFinanceiroLogica createState() => _RelatorioFinanceiroLogica();
}

class _RelatorioFinanceiroLogica  extends State<RelatorioFinanceiro>{
  int _currentIndex =0;
  Widget _tela;

  _setIndexState(index){
    setState(() {
      _currentIndex=index;
      _tela=widget._widgetOptions[index];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tela=widget._widgetOptions[0];
  }

  @override
  Widget build(BuildContext context) => _RelatorioFinanceiroTela(this);
}

class _RelatorioFinanceiroTela extends WidgetView<RelatorioFinanceiro, _RelatorioFinanceiroLogica> {
  _RelatorioFinanceiroTela(_RelatorioFinanceiroLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(state._currentIndex == 0 ? "Relatório Mensal"
            : (state._currentIndex==1? "Relatório Anual":"Relatório Completo")),
      ),
      body: state._tela,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: state._currentIndex,
        selectedLabelStyle: TextStyle(fontSize: 18,  fontWeight: FontWeight.bold),
        fixedColor: Colors.white,
        unselectedItemColor: Colors.white70,
        unselectedLabelStyle: TextStyle(fontSize: 15),
        backgroundColor: Colors.cyan[600],
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Container(),
              label: "Trinta dias"
          ),

          BottomNavigationBarItem(
              icon: Container(),
              label: "Último ano"
          ),

          BottomNavigationBarItem(
              icon: Container(),
              label: "Sempre"
          ),
        ],
        onTap: (index){
          state._setIndexState(index);
        },
      ),
    );
  }
}
