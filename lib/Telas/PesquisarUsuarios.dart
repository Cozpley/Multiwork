import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_multiwork/Model/Usuario.dart';

class PesquisarUsuarios extends StatefulWidget {
  String _strBusca;

  PesquisarUsuarios(this._strBusca);

  @override
  _PesquisarUsuariosLogica createState() => _PesquisarUsuariosLogica();
}

class _PesquisarUsuariosLogica extends State<PesquisarUsuarios>{
  TextEditingController _contrUsuarios = TextEditingController();
  String _uid="";

  Future<List<Usuario>> _chamarUsuarios() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<Usuario> retorno = List();
    List<String> strings = removeDiacritics(_contrUsuarios.text).toLowerCase().split(" ");
    if(strings.length>0){
      await db.collection("usuarios").doc(_uid).get().then((ds) async{
        Query query = db.collection("usuarios");
        for(String str in strings){
          if(str!=""){
            str="index.$str";
            query=query.where(str, isEqualTo: true);
          }
        }
        QuerySnapshot qs = await query.get();
        for(DocumentSnapshot documento in qs.docs){
          if(documento.id != _uid){
            Usuario user = Usuario();
            user.nome = documento.data()["nome"];
            user.id=documento.id;
            user.distancia =Geolocator.distanceBetween(double.parse(ds.data()["latitude"]), double.parse(ds.data()["longitude"]),
                double.parse(documento.data()["latitude"]), double.parse(documento.data()["longitude"]));
            retorno.add(user);
          }
        }
      });
    }
    retorno.sort((a,b)=>a.distancia.compareTo(b.distancia));
    return retorno;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _uid=VerificarLogin.verificarLogin(context).uid;
    _contrUsuarios.text = widget._strBusca;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _contrUsuarios.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => _PesquisarUsuariosTela(this);
}


class _PesquisarUsuariosTela extends WidgetView<PesquisarUsuarios, _PesquisarUsuariosLogica> {
  _PesquisarUsuariosTela(_PesquisarUsuariosLogica state): super(state);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Procurar usuários"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              style: TextStyle(fontSize: 18, color: Colors.black),
              controller: state._contrUsuarios,
              decoration: InputDecoration(
                prefixIconConstraints:
                    BoxConstraints(minWidth: 24, maxHeight: 24),
                suffixIconConstraints:
                    BoxConstraints(minWidth: 24, maxHeight: 24),
                contentPadding: EdgeInsets.fromLTRB(16, 5, 16, 5),
                prefixIcon: IconButton(
                  padding: EdgeInsets.only(right: 4),
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    state._contrUsuarios.clear();
                  },
                ),
                suffixIcon: IconButton(
                  padding: EdgeInsets.only(left: 4),
                  icon: Icon(Icons.search),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/pesquisarUsuarios",
                        arguments: state._contrUsuarios.text);
                  },
                ),
                hintText: "Pesquisar por pessoas",
              ),
            ),
            FutureBuilder<List<Usuario>>(
              future: state._chamarUsuarios(),
              builder: (context, snap) {
                switch (snap.connectionState) {
                  case ConnectionState.waiting:
                    return Padding(padding: EdgeInsets.all(32),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                    break;
                  default:
                    if(!snap.hasError && snap.hasData) {
                      List<Usuario> dados = snap.data;
                      return Container(
                        padding: EdgeInsets.only(top: 8),
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: dados.length,
                            itemBuilder: (context, index){
                              return GestureDetector(
                                child: Card(
                                    color: Colors.transparent,
                                    child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text(dados[index].nome, style: TextStyle(fontSize: 20, color: Colors.white))
                                    )
                                ),
                                onTap: (){
                                  Navigator.pushNamed(context, "/outroUsuario", arguments: {"id": dados[index].id, "nome": dados[index].nome});
                                },
                              );
                            }
                        ),
                      );
                    }else{
                      return Container();
                    }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}