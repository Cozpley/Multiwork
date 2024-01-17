
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Telas/ResultadosProcurarServico.dart';
import 'package:flutter_multiwork/Util/Modalidades.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';

class ProcurarServico extends StatefulWidget {
  @override
  _ProcurarServicoLogica createState() => _ProcurarServicoLogica();
}

class _ProcurarServicoLogica extends State<ProcurarServico> {
  String _uid;
  TextStyle _textStyleDD= TextStyle(color: Colors.white, fontSize: 18);
  String _dropdownValue;
  Widget _tela=Container();
  List<String> _listaModalidadesExibir;
  TextEditingController _contrPesquisa =TextEditingController();

  _recuperarLista(){
    _listaModalidadesExibir=GerenciarModalidades.listaExibicao();
    _listaModalidadesExibir.insert(0, "");
    _dropdownValue=_listaModalidadesExibir[0];
  }

  _changeValueDropdown(String value){
    setState(() {
      _dropdownValue = value;
    });
  }

  _pesquisar(){
    setState(() {
      _tela=ResultadosProcurarServico(_uid, _contrPesquisa.text, _dropdownValue);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarLista();
    try{
      _uid =VerificarLogin.verificarLogin(context).uid;
    }catch(_){}
  }

  @override
  Widget build(BuildContext context) =>_ProcurarServicoTela(this);
}

class _ProcurarServicoTela extends WidgetView<ProcurarServico, _ProcurarServicoLogica> {
  _ProcurarServicoTela(_ProcurarServicoLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: state._dropdownValue,
              icon: Padding(padding: EdgeInsets.only(bottom: 10),
                child: Icon(Icons.arrow_downward, color: Colors.white,),
              ),
              iconSize: 24,
              isExpanded: true,
              style: state._textStyleDD,
              dropdownColor: Colors.grey[700],
              underline: Container(
                height: 1.5,
                color: Colors.white,
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
                    child: Text(value==""?"Todas as Categorias" :value),
                  ),
                );
              }).toList(),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    controller: state._contrPesquisa,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(16, 5, 16, 5),
                      hintText: "Pesquisar por Serviços",
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(4, 0, 4, 14),
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: IconButton(
                      icon: Icon(Icons.search, size: 30,),
                      onPressed: state._pesquisar,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: state._tela,
      )
    );
  }
}
