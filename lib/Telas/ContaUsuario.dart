import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Util/GerenciarContasVinculadas.dart';
import 'package:flutter_multiwork/Util/GerenciarDatas.dart';
import 'package:flutter_multiwork/Model/Usuario.dart';
import 'package:flutter_multiwork/Telas/RecuperarSenha.dart';
import 'package:flutter_multiwork/Util/UserController.dart';
import 'package:flutter_multiwork/Util/VerificarLogin.dart';

class ContaUsuario extends StatefulWidget {
  @override
  _ContaUsuarioLogica createState() => _ContaUsuarioLogica();
}

class _ContaUsuarioLogica extends State<ContaUsuario> {
  String _uid;
  User _Fuser;
  bool _allowPhoneExclusion;
  TextStyle _dadosTextStyle = TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w700);
  TextStyle _dadosTelStyle = TextStyle(fontSize: 18, color: Colors.white);
  UserInfo _userFacebookData;
  UserInfo _userGoogleData;

  _getData(){
    List<UserInfo> list = _Fuser.providerData;
    for (UserInfo info in list){
      if(info.providerId == "facebook.com"){
        _userFacebookData = info;
      }else if(info.providerId == "google.com"){
        _userGoogleData = info;
      }
    }
  }

  _carregarDadosLogin() {
    _Fuser = VerificarLogin.verificarLogin(context);
    _uid=_Fuser.uid;
    _getData();
  }

  Future<Usuario> _returnUsuario() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snap = await db.collection("usuarios").doc(_uid).get();

    Map<String, dynamic> dados = snap.data();

    List<String> listaTelefones=[];
    dados["telefones"].forEach(
            (item)=>listaTelefones.add(item.toString())
    );

    Usuario user =Usuario.UsuarioComEndereco(listaTelefones, dados["nome"], dados["data"],dados["estado"], dados["cidade"],
        dados["rua"], dados["numero"], dados["complemento"], dados["email"], dados["mostrarEndereco"], dados["latitude"], dados["longitude"]);

    user.hasContaFacebook = dados["hasContaFacebook"];
    if(user.hasContaFacebook==null){
      user.hasContaFacebook = false;
    }
    user.hasContaGoogle = dados["hasContaGoogle"];
    if(user.hasContaGoogle==null){
      user.hasContaGoogle = false;
    }

    if(user.telefones.length>1){
      _allowPhoneExclusion=true;
    }else{
      _allowPhoneExclusion=false;
    }
    return user;
  }

  _alterarMostrarEndereco(bool value){
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("usuarios").doc(_uid).update({"mostrarEndereco" : value});
    Navigator.pushReplacementNamed(context, "/contaUsuario");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _carregarDadosLogin();
  }

  @override
  Widget build(BuildContext context) => _ContaUsuarioTela(this);
}

class _ContaUsuarioTela extends WidgetView<ContaUsuario, _ContaUsuarioLogica> {
  _ContaUsuarioTela(_ContaUsuarioLogica state): super(state);
  @override
  Column exibirFacebook(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.only(bottom: 6, left: 32),
          child: Text("Facebook: ", style: state._dadosTextStyle,)
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            state._userFacebookData!= null  ? CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  backgroundImage: state._userFacebookData.photoURL !=null ? NetworkImage(state._userFacebookData.photoURL): null): Container(),
              state._userFacebookData != null ? Text(state._userFacebookData.displayName, style: state._dadosTextStyle,) : Text("Conta vinculada", style: state._dadosTextStyle,),
              IconButton(
                icon: Icon(Icons.delete_forever, color: Colors.red),
                onPressed: (){
                  showDialog(
                    context:  state.context,
                    builder:  (BuildContext context) {
                      return AlertDialog(
                        title: Text("Deseja desvincular esta conta Facebook da sua conta Multiwork?",
                          textAlign: TextAlign.justify,),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RaisedButton(onPressed: (){
                              Navigator.of(context).pop();
                            },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(color: Colors.transparent)
                              ),
                              child: Text("Cancelar", style: TextStyle(color:Colors.white),),
                            ),
                            RaisedButton(onPressed: (){
                              Navigator.of(context).pop();
                              GerenciarContasVinculadas.desvincularConta("facebook.com",state._Fuser,state.context,state._userFacebookData.uid);
                            },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(color: Colors.transparent)
                              ),
                              child: Text("Desvincular", style: TextStyle(color:Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  Column exibirGoogle(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.only(bottom: 6, left: 32),
            child: Text("Google: ", style: state._dadosTextStyle,)
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              state._userGoogleData!= null  ? CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  backgroundImage: state._userGoogleData.photoURL !=null ? NetworkImage(state._userGoogleData.photoURL): null): Container(),
              state._userGoogleData != null ? Text(state._userGoogleData.displayName, style: state._dadosTextStyle,) :
              Text("Conta vinculada", style: state._dadosTextStyle,),
              IconButton(
                icon: Icon(Icons.delete_forever, color: Colors.red),
                onPressed: (){
                  showDialog(
                    context:  state.context,
                    builder:  (BuildContext context) {
                      return AlertDialog(
                        title: Text("Deseja desvincular esta conta Google da sua conta Multiwork?",
                        textAlign: TextAlign.justify,),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RaisedButton(onPressed: (){
                              Navigator.of(context).pop();
                            },
                              child: Text("Cancelar", style: TextStyle(color:Colors.white),),
                            ),
                            RaisedButton(onPressed: (){
                              Navigator.of(context).pop();
                              GerenciarContasVinculadas.desvincularConta("google.com",state._Fuser,state.context,state._userGoogleData.uid);
                            },
                              child: Text("Desvincular", style: TextStyle(color:Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  Column mostrarEndereco(Usuario user){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text("Estado: ${user.estado}", style: state._dadosTextStyle,maxLines: null,)),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.cyanAccent),
                  onPressed: (){
                    Navigator.pushNamed(state.context, "/editDadoPessoal", arguments: {
                      "tipoDado" : "estado",
                      "dadoAntigo" : user.estado,
                      "email" : user.email
                    });
                  },
                ),
              ],
            )
        ),
        Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text("Cidade: ${user.cidade}", style: state._dadosTextStyle,maxLines: null)),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.cyanAccent),
                  onPressed: (){
                    Navigator.pushNamed(state.context, "/editDadoPessoal", arguments: {
                      "tipoDado" : "cidade",
                      "dadoAntigo" : user.cidade,
                      "email" : user.email
                    });
                  },
                ),
              ],
            )
        ),
        Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text("Rua: ${user.rua}", style: state._dadosTextStyle,maxLines: null)),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.cyanAccent),
                  onPressed: (){
                    Navigator.pushNamed(state.context, "/editDadoPessoal", arguments: {
                      "tipoDado" : "rua",
                      "dadoAntigo" : user.rua,
                      "email" : user.email
                    });
                  },
                ),
              ],
            )
        ),
        Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text("Número Residencial: ${user.numero}", style: state._dadosTextStyle,maxLines: null)),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.cyanAccent),
                  onPressed: (){
                    Navigator.pushNamed(state.context, "/editDadoPessoal", arguments: {
                      "tipoDado" : "numero",
                      "dadoAntigo" : user.numero,
                      "email" : user.email
                    });
                  },
                ),
              ],
            )
        ),
        Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text("Complemento: ${user.complemento}", style: state._dadosTextStyle,maxLines: null)),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.cyanAccent),
                  onPressed: (){
                    Navigator.pushNamed(state.context, "/editDadoPessoal", arguments: {
                      "tipoDado" : "complemento",
                      "dadoAntigo" : user.complemento,
                      "email" : user.email
                    });
                  },
                ),
              ],
            )
        )
      ],
    );
  }




  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minha conta"),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: FutureBuilder<Usuario>(
          future: state._returnUsuario(),
          builder: (context, snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
                break;
              default:
                if(!snapshot.hasError && snapshot.hasData){
                  Usuario user = snapshot.data;
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 16, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text("Nome: ${user.nome}", style: state._dadosTextStyle,maxLines: null)),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.cyanAccent),
                                onPressed: (){
                                  Navigator.pushNamed(context, "/editDadoPessoal", arguments: {
                                    "tipoDado" : "nome",
                                    "dadoAntigo" : user.nome,
                                    "email" : user.email
                                  });
                                },
                              ),
                            ],
                          )
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text("Email: ${user.email}", style: state._dadosTextStyle,maxLines: null)),
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.cyanAccent),
                                  onPressed: (){
                                    Navigator.pushNamed(context, "/editEmail", arguments: user.email);
                                  },
                                ),
                              ],
                            )
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text("Data de Nascimento: ${GerenciarDatas.TextoFirebaseparaUsuario(user.dataNasc)}",
                                  maxLines: null,style: state._dadosTextStyle,)),
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.cyanAccent),
                                  onPressed: (){
                                    Navigator.pushNamed(context, "/editarData",arguments: {
                                      "data": GerenciarDatas.TextoparaData(user.dataNasc),
                                      "dataExibir" : GerenciarDatas.TextoFirebaseparaUsuario(user.dataNasc),
                                      "email" : user.email
                                    });
                                  },
                                ),
                              ],
                            )
                        ),

                        Padding(
                          padding: EdgeInsets.only( top: 4, left:16, right: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text("Telefones", style: state._dadosTextStyle,maxLines: null)),
                              IconButton(
                                icon: Icon(Icons.add, color: Colors.cyanAccent),
                                onPressed: (){
                                  Navigator.pushNamed(context, "/addTelefone", arguments: user);
                                },
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding:EdgeInsets.only(bottom: 8),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white70,
                                    width: 2)
                            ),
                            child: ListView.separated(
                                separatorBuilder: (_, index){
                                  return Container(
                                      color: Colors.grey,
                                      height: 0.5);
                                },
                                shrinkWrap: true,
                                itemCount: user.telefones.length,
                                itemBuilder: (context, index){
                                  return ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.only(left: 16),
                                    title: Text(user.telefones[index], style: state._dadosTelStyle),
                                    trailing: Wrap(
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.cyanAccent),
                                        onPressed: (){
                                          Navigator.pushNamed(context, "/editTelefone", arguments: {"user":user,"index":index});
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_forever, color: state._allowPhoneExclusion ? Colors.redAccent: Colors.black54),
                                        onPressed: state._allowPhoneExclusion ? (){
                                          Navigator.pushNamed(context, "/deleteTelefone", arguments: {"user":user,"index":index});
                                        } : null,
                                      ),
                                    ],)
                                  );
                                }
                            ),
                          ),
                        ),

                        mostrarEndereco(user),

                        Padding(
                          padding: EdgeInsets.only(top:8, bottom: 8),
                          child: SwitchListTile(
                              contentPadding: EdgeInsets.all(2),
                              title: Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  "Deseja deixar o seu endereço visível a outros usuários?",
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                              inactiveThumbColor: Color.fromRGBO(240, 240, 240, 1),
                              inactiveTrackColor: Color.fromRGBO(150, 150, 150, 1),
                              subtitle: user.mostrarEndereco ?
                              Text("Seu endereço está visivel", style: TextStyle(fontSize: 15, color: Colors.white70)):
                              Text("Seu endereço não está visivel", style: TextStyle(fontSize: 15, color: Colors.white70)),
                              value: user.mostrarEndereco,
                              onChanged: (value){
                                state._alterarMostrarEndereco(value);
                              }
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(bottom: 4, top: 4),
                          child: !user.hasContaFacebook? RaisedButton(
                            onPressed: (){
                              GerenciarContasVinculadas.vincularContaFacebook(state._Fuser, context);
                            },
                            child: Text ("Vincular conta Facebook", style: state._dadosTextStyle,),
                          ) : exibirFacebook()
                        ),
                        Padding(
                            padding: EdgeInsets.only(bottom: 4, top: 4),
                            child: !user.hasContaGoogle? RaisedButton(
                              onPressed: (){
                                GerenciarContasVinculadas.vincularContaGoogle(state._Fuser, context);
                              },
                              child: Text ("Vincular conta Google", style: state._dadosTextStyle,),
                            ) : exibirGoogle()
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          child: GestureDetector(
                            child: Text(
                              "Alterar senha",
                              textAlign: TextAlign.center,
                              style:
                              TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            onTap: () {
                              UserController.recuperarSenha(user.email, context);
                            },
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(bottom: 4, top: 4),
                            child: RaisedButton(
                              color: Colors.red,
                              onPressed: (){
                                Navigator.pushNamed(context, "/excluirConta",arguments: {"email": user.email,
                                "facebook": state._userFacebookData, "google": state._userGoogleData});
                              },
                              child: Text ("Excluir Conta", style: state._dadosTextStyle,),
                            )
                        )
                      ],
                    ),
                  );
                }else{
                  if(snapshot.hasError){
                    return Center(
                      child: Text("Erro", style: TextStyle(color: Colors.redAccent, fontSize: 30),)
                    );
                  }
                  return Container();
                }
                break;
            }
          },
        ),
      ),
    );
  }
}