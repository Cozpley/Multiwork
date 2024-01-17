import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multiwork/GestaoDeEstados/StatefulView.dart';
import 'package:flutter_multiwork/Util/GerenciarDatas.dart';
import 'package:flutter_multiwork/Util/GerenciarPosicoes.dart';
import 'package:flutter_multiwork/Util/UserController.dart';
import 'package:flutter_multiwork/Model/Usuario.dart';

class Cadastro extends StatefulWidget {
  AuthCredential _googleCred;
  FacebookAuthCredential _facebookCred;
  String _googleId;
  String _facebookId;
  Cadastro(Map<String, dynamic> loginFederado){
    this._googleCred =  loginFederado["google"];
    this._facebookCred = loginFederado["facebook"];
    this._googleId = loginFederado["googleid"];
    this._facebookId= loginFederado["facebookid"];
  }
  @override
  _CadastroLogica createState() => _CadastroLogica();
}

class _CadastroLogica extends State<Cadastro>{

  bool _carregando =false;
  TextStyle _formText = TextStyle(fontSize: 15, color: Colors.white);
  TextStyle _formText2 = TextStyle(fontSize: 20, color: Colors.black);
  String _text = null;
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  bool _mostrarEndereco = true;
  TextEditingController _nome = TextEditingController();
  TextEditingController _telefone = TextEditingController();
  TextEditingController _estado = TextEditingController();
  TextEditingController _cidade = TextEditingController();
  TextEditingController _rua = TextEditingController();
  TextEditingController _complemento = TextEditingController();
  TextEditingController _numero = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _confirmarEmail = TextEditingController();
  TextEditingController _senha = TextEditingController();
  TextEditingController _confirmarSenha = TextEditingController();
  String _dataStr = "Escolha uma data";
  String _dataFirebase;
  String _latitude;
  String _longitude;

  _registrarPosicao() async{
    dynamic pos = await GerenciarPosicoes.registrarPosicaoNovoCadastro();
    _latitude=pos[0];
    _longitude=pos[1];

  }

  _alterarBancoLogin(String plataforma, String id){
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection(plataforma).doc(id).set({"exists":true});
  }

  _alterarBoolGoogle(bool b, String uid)async{
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("usuarios").doc(uid).update({"hasContaGoogle" : b});
  }

  _alterarBoolFacebook(bool b, String uid){
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("usuarios").doc(uid).update({"hasContaFacebook" : b});
  }

  _botaoCadastrar(){
    if (_key.currentState.validate()  && _dataFirebase!=null) {
      setState(() {
        _carregando=true;
      });
      Usuario novoUsuario = Usuario.UsuarioComEndereco([_telefone.text], _nome.text, _dataFirebase,
          _estado.text, _cidade.text, _rua.text, _numero.text, _complemento.text, _email.text,
          _mostrarEndereco, _latitude, _longitude);
      novoUsuario.senha=_senha.text;
      _criarAutenticacao(novoUsuario);
    } else {
      setState(() {
        _text = "Preencha todos os campos corretamente";
      });
    }
  }

  _criarAutenticacao(Usuario user){
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: user.email, password: user.senha)
        .then((userCredencial)async{
          String uid = userCredencial.user.uid;
          bool criacao =await  UserController.salvarUsuario(user, uid, _mostrarEndereco);
          if(criacao){
            if(widget._facebookCred!=null){
              userCredencial.user.linkWithCredential(widget._facebookCred).then(
                      (_){
                    _alterarBoolFacebook(true, uid);
                    _alterarBancoLogin("Facebook", widget._facebookId);
                  }
              );
            }else if(widget._googleCred!=null){
              userCredencial.user.linkWithCredential(widget._googleCred).then(
                      (_){
                    _alterarBoolGoogle(true, uid);
                    _alterarBancoLogin("Google", widget._googleId);
                  }
              );
            }
            Navigator.pushNamedAndRemoveUntil(context, "/home", (_)=>false);
          }else{
            setState(() {
              _carregando=false;
              _text = "Criação de usuário não foi realizada com sussesso";
            });
          }
        }).catchError((error) {
          if(error.toString().contains("email-already-in-use")){
            setState(() {
              _carregando = false;
              _text = "Email já cadastrado";
            });
          }else{
            setState(() {
              _carregando = false;
              _text = "Autenticação não foi realizada com sussesso";
            });
          }
        });
  }

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose();
    _estado.dispose();
    _cidade.dispose();
    _rua.dispose();
    _complemento.dispose();
    _numero.dispose();
    _email.dispose();
    _confirmarEmail.dispose();
    _senha.dispose();
    _confirmarSenha.dispose();
    super.dispose();
  }

  String _validarEmail1(value){
    if (value.isEmpty || !value.contains("@")) {
      return "Insira um email válido";
    }
  }

  String _validarEmail2(value){
    if (value != _email.text) {
      return "Os emails devem coincidir";
    }
  }

  String _validarSenha1(value){
    if (value.length < 6) {
      return "Insira uma senha com mais de 6 caracteres";
    }
  }

  String _validarSenha2(value){
    if (value != _senha.text) {
      return "As senhas devem coincidir";
    }
  }

  String _validarPreenchimento(value){
    if (value.isEmpty) {
      return "Necessário preencher este campo";
    }
  }

  _botaoMostrarEndereco(value){
    setState(() {
      _mostrarEndereco=value;
    });
  }

  _selecionarData()async{
    DateTime picked = await showDatePicker(
        locale: Locale("pt", "BR"),
        context: context,
        fieldLabelText: "",
        initialDate: DateTime.now(),
        firstDate: DateTime(1920),
        lastDate: DateTime.now());
    if (picked != null) {
      String data = GerenciarDatas.DataparaTextoUsuario(picked);
      setState(() {
        _dataStr = data;
      });
      _dataFirebase = GerenciarDatas.DataparaTextoFirebase(picked);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _registrarPosicao();
  }

  @override
  Widget build(BuildContext context) => _CadastroTela(this);
}

class _CadastroTela extends WidgetView<Cadastro, _CadastroLogica> {

  _CadastroTela(_CadastroLogica state): super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Cadastro Multiwork"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Form(
          key: state._key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  "Nome: ",
                  style: state._formText,
                ),
              ),
              TextFormField(
                validator: (value) {
                  return state._validarPreenchimento(value);
                },
                controller: state._nome,
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Ex: Lidia da Silva",
                ),
                style: state._formText2,
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  "Telefone: ",
                  style: state._formText,
                ),
              ),
              TextFormField(
                controller: state._telefone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TelefoneInputFormatter(),
                ],
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Ex: 40028922",
                ),
                style: state._formText2,
                validator: (value) {
                  return state._validarPreenchimento(value);
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  "Data de Nascimento: ",
                  style: state._formText,
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: Text(state._dataStr, style: state._formText, textAlign: TextAlign.center,)
                  ),
                  RaisedButton(
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      onPressed: state._selecionarData
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  "Estado: ",
                  style: state._formText,
                ),
              ),
              TextFormField(
                controller: state._estado,
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Ex: Paraná",
                ),
                style: state._formText2,
                validator: (value) {
                  return state._validarPreenchimento(value);
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  "Cidade: ",
                  style: state._formText,
                ),
              ),
              TextFormField(
                controller: state._cidade,
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Ex: Irati",
                ),
                style: state._formText2,
                validator: (value) {
                  return state._validarPreenchimento(value);
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  "Rua: ",
                  style: state._formText,
                ),
              ),
              TextFormField(
                controller: state._rua,
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Ex: Rua das Dores",
                ),
                style: state._formText2,
                validator: (value) {
                  return state._validarPreenchimento(value);
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  "Complemento: ",
                  style: state._formText,
                ),
              ),
              TextFormField(
                controller: state._complemento,
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Ex: Apartamento 500",
                ),
                style: state._formText2,
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  "Número Residencial: ",
                  style: state._formText,
                ),
              ),
              TextFormField(
                controller: state._numero,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Ex: 200",
                ),
                style: state._formText2,
                validator: (value) {
                  return state._validarPreenchimento(value);
                },
              ),

              Padding(
                padding: EdgeInsets.only(top:16, bottom: 4),
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
                    subtitle: state._mostrarEndereco ?
                    Text("Seu endereço está visivel", style: TextStyle(fontSize: 15, color: Colors.white70)):
                    Text("Seu endereço não está visivel", style: TextStyle(fontSize: 15, color: Colors.white70)),
                    value: state._mostrarEndereco,
                    onChanged: (value){
                      state._botaoMostrarEndereco(value);
                    }
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  "Email: ",
                  style: state._formText,
                ),
              ),
              TextFormField(
                controller: state._email,
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Ex: email@email.com",
                ),
                style: state._formText2,
                validator: (value) {
                  return state._validarEmail1(value);
                },
              ),

              Padding(
                padding: EdgeInsets.only(top: 8),
                child: TextFormField(
                  controller: state._confirmarEmail,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "Confirme o Email",
                  ),
                  style: state._formText2,
                  validator: (value) {
                    return state._validarEmail2(value);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  "Senha: ",
                  style: state._formText,
                ),
              ),
              TextFormField(
                controller: state._senha,
                obscureText: true,
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Insira a senha",
                ),
                style: state._formText2,
                validator: (value) {
                  return state._validarSenha1(value);
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: TextFormField(
                  controller: state._confirmarSenha,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "Confirme a senha",
                  ),
                  style: state._formText2,
                  validator: (value){
                    return state._validarSenha2(value);
                  },
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 12),
                  child: Center(
                    child: Text(
                      "A senha precisa conter mais de 6 caracteres",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  )),
              state._text == null
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Center(
                        child: Text(
                          state._text,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 20, color: Colors.redAccent),
                        ),
                      ),
                    ),
              !state._carregando ? RaisedButton(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Text(
                    "Concluir",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  onPressed: state._botaoCadastrar
              ) : Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}