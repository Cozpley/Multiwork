import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';

class Inicio extends StatefulWidget {
  @override
  _InicioLogica createState() => _InicioLogica();
}

class _InicioLogica extends State<Inicio>{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    VerificarLogin.verificarLoginInicio(context);
  }

  @override
  Widget build(BuildContext context) => _InicioTela(this);
}


class _InicioTela extends  WidgetView<Inicio, _InicioLogica> {
  _InicioTela(_InicioLogica state): super(state);
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
