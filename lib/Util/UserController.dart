import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiwork/Model/Usuario.dart';
import 'package:flutter_multiwork/Util/Indexer.dart';

class UserController{

  static Future<bool> salvarUsuario(Usuario usuario, String uid,bool mostrarEndereco) async{
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try{
      await firestore.collection("usuarios").doc(uid).set({
        "nome": usuario.nome,
        "email": usuario.email,
        "data": usuario.dataNasc,
        "estado": usuario.estado,
        "cidade": usuario.cidade,
        "rua": usuario.rua,
        "mostrarEndereco": mostrarEndereco,
        "numero": usuario.numero,
        "complemento": usuario.complemento,
        "telefones": usuario.telefones,
        "index": Indexer.indice(usuario.nome),
        "latitude": usuario.latitude,
        "longitude": usuario.longitude
      });
      return true;
    }catch(_){
      return false;
    }
    //return true;
  }

  static updateTelefones(String uid, List<String> telefones){
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("usuarios").doc(uid).update({"telefones" : telefones});
  }

  static updateDataNasc(String uid, String data){
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("usuarios").doc(uid).update({"data" : data});
  }

  static alterarNomes(String uid, String nome) async{
    FirebaseFirestore db = FirebaseFirestore.instance;
    var resultados = await db.collection("propostas").doc(uid).collection("propostasConcluidas").get();
    for(var ds in resultados.docs){
      if(ds.data()["idCliente"]==uid){
        await db.collection("propostas").doc(uid).collection("propostasConcluidas").doc(ds.id).update({"nomeCliente":nome});
        await db.collection("propostas").doc(ds.data()["idPrestador"]).collection("propostasConcluidas").doc(ds.id).update({"nomeCliente":nome});
      }else{
        await db.collection("propostas").doc(uid).collection("propostasConcluidas").doc(ds.id).update({"nomePrestador":nome});
        await db.collection("propostas").doc(ds.data()["idCliente"]).collection("propostasConcluidas").doc(ds.id).update({"nomePrestador":nome});
      }
    }
    resultados = await db.collection("propostas").doc(uid).collection("prpostasAtivas").get();
    for(var ds in resultados.docs){
      if(ds.data()["idCliente"]==uid){
        await db.collection("propostas").doc(uid).collection("propostasAtivas").doc(ds.id).update({"nomeCliente":nome});
        await db.collection("propostas").doc(ds.data()["idPrestador"]).collection("propostasAtivas").doc(ds.id).update({"nomeCliente":nome});
      }else{
        await db.collection("propostas").doc(uid).collection("propostasAtivas").doc(ds.id).update({"nomePrestador":nome});
        await db.collection("propostas").doc(ds.data()["idCliente"]).collection("propostasAtivas").doc(ds.id).update({"nomePrestador":nome});
      }
    }

    resultados = await db.collection("conversas").doc(uid).collection("ultimaConversa").get();
    for(var ds in resultados.docs){
      await db.collection("conversas").doc(ds.id).collection("ultimaConversa").doc(uid).update({"nome":nome});
    }
  }

  static updateDadoPessoal(String tipoDado, String novo, String uid)async{
    FirebaseFirestore db = FirebaseFirestore.instance;
    if(tipoDado=="nome"){
      await db.collection("usuarios").doc(uid).update({tipoDado : novo, "index": Indexer.indice(novo)});
      UserController.alterarNomes(uid, novo);
    }else{
      await db.collection("usuarios").doc(uid).update({tipoDado : novo});
    }
  }

  //retorna mensagem de erro, caso ocorra
  static Future<String> updateEmailBanco(String novo, User fuser) async{
    String retorno =null;
    try{
      await fuser.updateEmail(novo);
    }catch(error){
      if(error.toString().contains("email-already-in-use")){
        retorno= "Email já cadastrado";
      }else{
        retorno = "Não foi possível completar mudança";
      }
    }
    if(retorno==null){
      FirebaseFirestore db = FirebaseFirestore.instance;
      db.collection("usuarios").doc(fuser.uid).update({"email" : novo});
    }
    return retorno;

  }

  static Future<bool> _enviarEmailSenha(String email, context) async{
    FirebaseAuth auth = FirebaseAuth.instance;
    bool retorno=true;
    try{
      auth.sendPasswordResetEmail(email: email);
    } catch(error){
        retorno=false;
      }
    return retorno;
  }

  static recuperarSenha(String email, context)async{
    bool sucesso = await UserController._enviarEmailSenha(email, context);
    if(sucesso){
      return showDialog(context: context,
          builder: (context){
            return AlertDialog(
              title: Text("Email para alteração de senha enviado"),
              actions: [
                FlatButton(onPressed: (){Navigator.pop(context);}, child: Text("Fechar"))
              ],
            );}
      );
    }else{
      return showDialog(context: context,
          builder: (context){
            return AlertDialog(
              title: Text("Não foi possível enviar o email"),
              actions: [
                FlatButton(onPressed: (){Navigator.pop(context);}, child: Text("Fechar"))
              ],
            );}
      );
    }
  }

  static excluirConta(User fuser, UserInfo userGoogleData, UserInfo userFacebookData, context) async{
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("usuarios").doc(fuser.uid).delete();
    if(userGoogleData!=null){
      await db.collection("Google").doc(userGoogleData.uid).delete();
    }
    if(userFacebookData!=null){
      await db.collection("Facebook").doc(userFacebookData.uid).delete();
    }
    db.collection("servicos").where("idPrestador", isEqualTo: fuser.uid).get().then((value){
      value.docs.forEach((element)async {
        await db.collection("servicos").doc(element.id).update({"oculto" : true});
      });
      db.collection("propostas").doc(fuser.uid).collection("propostasAtivas").get().then((value) async{
        value.docs.forEach((element)async {
          await db.collection("propostas").doc(element["idPrestador"]).collection("propostasAtivas").doc(element.id).delete();
          await db.collection("propostas").doc(element["idCliente"]).collection("propostasAtivas").doc(element.id).delete();
        });
        try{
          await fuser.delete();
          FirebaseAuth auth= FirebaseAuth.instance;
          await auth.signOut();
          Navigator.pushNamedAndRemoveUntil(context, "/inicio", (route) => false);
        }catch(_){}
      });
    });

  }

}