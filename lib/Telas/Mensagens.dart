import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Model/Conversa.dart';
import 'package:flutter_multiwork/Model/Mensagem.dart';
import 'package:flutter_multiwork/Model/Usuario.dart';
import 'package:flutter_multiwork/Util/EnviarMensagem.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


class Mensagens extends StatefulWidget {
  Usuario _contato;
  Mensagens(this._contato);
  @override
  _MensagensLogica createState() => _MensagensLogica();
}

class _MensagensLogica extends State<Mensagens>{
  bool _subindoImagem=false;
  FirebaseFirestore _db = FirebaseFirestore.instance;
  TextEditingController _contr = TextEditingController();
  String _idLogado;
  String _idDestinatario;
  final _controler = StreamController<QuerySnapshot>.broadcast();
  bool _excluido=true;
  String _token;

  Stream<QuerySnapshot> _listenerMensagens(){
    Stream<QuerySnapshot> stream = _db.collection("mensagens").doc(_idLogado).collection(_idDestinatario)
        .orderBy("data", descending: true).snapshots()
      ..listen((dados) async {
        await _visualizar();
        if(!_controler.isClosed){
          await _controler.add(dados);}
      });
  }

  _visualizar() async{
    try{await _db.collection("conversas").
      doc(_idLogado).collection("ultimaConversa").
      doc(_idDestinatario).update({"visualizada":true});
    } catch(_){}
  }

  _verificarContato() async{
    var resultado = await _db.collection("usuarios").doc(_idDestinatario).get();
    if(resultado.exists){
      setState(() {
        _excluido=false;
      });
      var variavel = await _db.collection("usuarios").doc(_idDestinatario).get();
      setState(() {
        _token = variavel.data()["MessageToken"];
      });
    }
  }

  _recuperarDados() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user = await auth.currentUser;
    _idLogado = user.uid;
    _idDestinatario = widget._contato.id;
    _verificarContato();
    _listenerMensagens();
  }

  _enviarMensagem() {
    String textoMensagem = _contr.text;
    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.mensagem = textoMensagem;
      mensagem.idUsuario = _idLogado;
      mensagem.tipo = "texto";
      mensagem.data = Timestamp.now().toString();
      mensagem.urlMensagem = "";
      mensagem.salvarMensagem(_idLogado, _idDestinatario);
      mensagem.salvarMensagem(_idDestinatario, _idLogado);
      _contr.clear();
      _salvarConversa(mensagem);
    }
  }

  _salvarConversa(Mensagem mensagem)async{
    Conversa conversa = Conversa();
    conversa.usuario1=_idLogado;
    conversa.usuario2=_idDestinatario;
    conversa.idRemetente=_idLogado;
    conversa.idDestinatario = _idDestinatario;
    conversa.mensagem=mensagem.mensagem;
    conversa.tipo = mensagem.tipo;
    conversa.nome = widget._contato.nome;
    conversa.visualizada = true;
    conversa.data= Timestamp.now().toString();
    conversa.salvar();
    DocumentSnapshot dadossnap = await  _db.collection("usuarios").
    doc(_idLogado).get();
    conversa.usuario1=_idDestinatario;
    conversa.usuario2=_idLogado;
    conversa.nome = dadossnap.data()["nome"];
    conversa.visualizada = false;
    conversa.data= Timestamp.now().toString();
    conversa.salvar();
    SendMessage("Nova mensagem!", "${dadossnap.data()["nome"]} enviou uma mensagem", _token).send();
  }

  _enviarFoto() async {
    File imagemSelecionada;
    imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(imagemSelecionada!=null){
      setState(() {
        _subindoImagem=true;
      });
      String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
      FirebaseStorage storage = FirebaseStorage.instance;
      StorageReference arq = storage.ref().child("mensagens").child("$_idLogado").child("$nomeImagem.jpg");
      StorageUploadTask task = arq.putFile(imagemSelecionada);
      task.events.listen((event) {
        if(event.type==StorageTaskEventType.success){
          setState(() {
            _subindoImagem=false;
          });
        }
      });
      task.onComplete.then((value) {
        _colocarImagemBanco(value);
      });
    }
  }

  _colocarImagemBanco(StorageTaskSnapshot snap) async{
    String url = await snap.ref.getDownloadURL();
    Mensagem mensagem = Mensagem();
    mensagem.mensagem = "";
    mensagem.idUsuario = _idLogado;
    mensagem.tipo = "imagem";
    mensagem.data = Timestamp.now().toString();
    mensagem.urlMensagem = url;
    mensagem.salvarMensagem(_idLogado, _idDestinatario);
    mensagem.salvarMensagem(_idDestinatario, _idLogado);
    _salvarConversa(mensagem);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarDados();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controler.close();
  }

  @override
  Widget build(BuildContext context) => _MensagensTela(this);
}

class _MensagensTela extends WidgetView<Mensagens, _MensagensLogica> {
  _MensagensTela(_MensagensLogica state) : super(state);

  @override
  Widget build(BuildContext context) {
    var stream = StreamBuilder(
        stream: state._controler.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("Carregando", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      ),
                      CircularProgressIndicator()
                    ],
                  ));
              break;
            default:
              QuerySnapshot querySnapshot = snapshot.data;
              if (snapshot.hasError) {
                return Center(
                  child: Text("Erro ao  carregar dados", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                );
              } else {
                return Expanded(
                  child: ListView.builder(
                      itemCount: querySnapshot.docs.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        List<DocumentSnapshot> lista = querySnapshot.docs.toList();
                        DocumentSnapshot item = lista[index];
                        return Align(alignment: state._idLogado==item["idUsuario"]
                              ? Alignment.centerRight : Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: item["tipo"] == "texto" ? Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                  MediaQuery.of(context).size.width * 0.8),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: state._idLogado==item["idUsuario"]
                                      ? Colors.cyanAccent[100]
                                      : Colors.grey[50],
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                              child: Text(
                                item["mensagem"],
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.justify,)
                            ): GestureDetector(
                              onTap: (){
                                showDialog(context: context, builder: (context){
                                  return SizedBox.expand(
                                    child: GestureDetector(
                                      onTap: (){
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: Image.network(item["urlMensagem"]).image
                                          )
                                        ),
                                      ),
                                    ),
                                  );
                                });
                              },
                              child: Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                      MediaQuery.of(context).size.width * 0.8),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: state._idLogado==item["idUsuario"]
                                          ? Colors.cyanAccent[100]
                                          : Colors.grey[50],
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(16))),
                                  child: Image.network(item["urlMensagem"], scale: 10,),
                              ),
                            ),
                          ),
                        );
                      }),
                );
              }
              break;
          }
        });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: ClipRect(
                child: Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(widget._contato.nome, overflow: TextOverflow.ellipsis,),
                ),
              ),
            ),
            
          ],
        ),
        actions: [
          !state._excluido ? IconButton(icon: Icon(Icons.person, color: Colors.white, size: 30,), onPressed: (){Navigator.pushReplacementNamed(context, "/outroUsuario", arguments: {"id": widget._contato.id, "nome": widget._contato.nome});})
              :Container()
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.black, Colors.cyan[800]], begin: Alignment.bottomCenter, end: Alignment.topCenter)
        ),
        child: SafeArea(
            child: Container(
              child: Column(
                children: [
                  stream,
                  Container(
                    padding: EdgeInsets.only(bottom: 8, top: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      boxShadow: [BoxShadow(
                        color: Colors.grey[400],
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 10,
                      )]
                    ),

                    child:  Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: !state._excluido ? state._enviarFoto : null,
                              icon: state._subindoImagem ? CircularProgressIndicator()  : Icon(Icons.camera_alt,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Container(
                            constraints: BoxConstraints(maxHeight: 250),
                            child: Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: TextField(
                                controller: state._contr,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                autofocus: false,
                                style: TextStyle(fontSize: 20),
                                decoration: InputDecoration(
                                    hintText: "Digite sua mensagem",
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.fromLTRB(10, 10, 8, 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: !state._excluido ? state._enviarMensagem : null,
                              icon: Icon(Icons.send, color: Colors.white),
                            ),
                          ],
                        )
                      ],
                    )
                  )
                ],
              ),
            )),
      ),
    );
  }
}