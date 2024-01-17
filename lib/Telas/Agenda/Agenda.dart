import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Util/GerenciarDatas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/Model/Proposta.dart';
import 'package:flutter_multiwork/Telas/Agenda/TelaAgenda.dart';
import 'package:flutter_multiwork/Telas/Agenda/TelaNaoConcluidos.dart';
import 'package:flutter_multiwork/Telas/Agenda/TelaPropostasRecebidas.dart';

class Agenda extends StatefulWidget {
  String _uid;
  List<Widget> _widgetOptions;
  Agenda(this._uid){
    this._widgetOptions=<Widget>[
      TelaAgenda(_uid),
      TelaPropostasRecebidas(_uid),
      TelaNaoConcluidos(_uid),
    ];
  }
  @override
  _AgendaLogica createState() => _AgendaLogica();
}

class _AgendaLogica extends State<Agenda>{
  int _currentIndex =0;
  Widget _tela;
  String _data;
  bool _notify=false;
  bool _notify2=false;
  StreamSubscription<QuerySnapshot> _listener;
  StreamSubscription<QuerySnapshot> _listener2;

  void _carregarData(){
    String data = GerenciarDatas.DataparaTextoFirebase(DateTime.now());
    _data =data;
  }

  _inicializar() async {
    _listener =  FirebaseFirestore.instance.collection("propostas").doc(widget._uid).collection("propostasAtivas").where("idPrestador", isEqualTo: widget._uid).snapshots().listen((event) {
      bool flag = false;
      event.docs.forEach((element) {
        if(element["status"]==Proposta.REQUISITADA){
          flag=true;
          setState(() {
            _notify=true;
          });
        }
      });
      if(flag==false){
        setState(() {
          _notify=false;
        });
      }
    });

    _listener2 =  FirebaseFirestore.instance.collection("propostas").doc(widget._uid).collection("propostasAtivas").where("idPrestador", isEqualTo: widget._uid).where("status", isEqualTo: Proposta.AGENDADA)
        .where("data", isLessThan: _data).snapshots().listen((event) {
      if(event.docs.length!=0){
        setState(() {
          _notify2=true;
        });
      }else{
        _notify2=false;
      }
    });
  }

  _setIndexTela(int index){
    setState(() {
      _currentIndex=index;
      _tela=widget._widgetOptions[index];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _carregarData();
    _inicializar();
    _tela=widget._widgetOptions[0];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _listener.cancel();
    _listener2.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>_AgendaTela(this);
}

class _AgendaTela extends WidgetView<Agenda, _AgendaLogica> {
  _AgendaTela(_AgendaLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(state._currentIndex == 0 ? "Agenda" :
        (state._currentIndex==1? "Confirmação pendente":"Serviços Pendentes")),
      ),
      body: state._tela,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: state._currentIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedIconTheme: IconThemeData(color: Colors.white, size: 40),
        unselectedIconTheme: IconThemeData(color: Colors.white70, size: 32),
        backgroundColor: Colors.cyan[600],
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Agenda"
          ),

          BottomNavigationBarItem(
            icon: !state._notify ? Icon(Icons.home_repair_service) : Stack(children: [Icon(Icons.home_repair_service), Positioned(
              top: 0,
              right: 0,
              child: Container(
                child: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16,),),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                color: Colors.redAccent[700],
                shape: BoxShape.circle
                )
              )
            )]),
            label: "Serviços requisitados"
          ),

          BottomNavigationBarItem(
            icon: !state._notify2 ? Icon(Icons.update) : Stack(children: [Icon(Icons.update), Positioned(
                top: 0,
                right: 0,
                child: Container(
                    child: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16,),),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                        color: Colors.redAccent[700],
                        shape: BoxShape.circle
                    )
                )
            )]),
            label: "Serviços não concluídos"
          ),
        ],
        onTap: (index){
          state._setIndexTela(index);
        },
      ),
    );
  }
}
