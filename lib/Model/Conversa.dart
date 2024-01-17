import 'package:cloud_firestore/cloud_firestore.dart';
class Conversa{
  String _usuario1;
  String _usuario2;
  String _idRemetente;
  String _idDestinatario;
  String _tipo;
  String _nome;
  String _mensagem;
  String _data;
  bool _visualizada;

  salvar()async{
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("conversas").doc(this._usuario1).collection("ultimaConversa").doc(this._usuario2)
        .set(this.toMap());
  }

  Map<String, dynamic> toMap(){
    return {
      "idRemetente" : _idRemetente,
      "idDestinatario" : _idDestinatario,
      "tipo" : _tipo,
      "nome" : _nome,
      "mensagem" : _mensagem,
      "data":_data,
      "visualizada": _visualizada
    };
  }

  String get usuario1 => _usuario1;

  set usuario1(String value) {
    _usuario1 = value;
  }

  bool get visualizada => _visualizada;

  set visualizada(bool value) {
    _visualizada = value;
  }

  String get data => _data;

  set data(String value) {
    _data = value;
  }

  String get idRemetente => _idRemetente;

  set idRemetente(String value) {
    _idRemetente = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get mensagem => _mensagem;


  set mensagem(String value) {
    _mensagem = value;
  }

  String get idDestinatario => _idDestinatario;

  set idDestinatario(String value) {
    _idDestinatario = value;
  }

  String get tipo => _tipo;

  set tipo(String value) {
    _tipo = value;
  }

  String get usuario2 => _usuario2;

  set usuario2(String value) {
    _usuario2 = value;
  }
}