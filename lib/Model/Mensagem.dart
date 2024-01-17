import 'package:cloud_firestore/cloud_firestore.dart';

class Mensagem{
  String _idUsuario;
  String _mensagem;
  String _urlMensagem;
  String _tipo;
  String _data;


  String get data => _data;

  set data(String value) {
    _data = value;
  }

  String get idUsuario => _idUsuario;

  Map<String, dynamic> toMap(){
    return{
      "idUsuario" : this._idUsuario,
      "mensagem" : this.mensagem,
      "urlMensagem" : this._urlMensagem,
      "tipo": this._tipo,
      "data": this._data
    };
  }

  set idUsuario(String value) {
    _idUsuario = value;
  }

  String get mensagem => _mensagem;

  String get tipo => _tipo;

  set tipo(String value) {
    _tipo = value;
  }

  String get urlMensagem => _urlMensagem;

  set urlMensagem(String value) {
    _urlMensagem = value;
  }

  set mensagem(String value) {
    _mensagem = value;
  }

  salvarMensagem(String idRemetente, String idDestinatario) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection("mensagens")
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(this.toMap());
  }
}