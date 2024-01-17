import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_multiwork/Util/GerenciarDatas.dart';

class GerarRelatorioFinanceiro{
  //periodo 0 =completo
  //periodo 1 =mês
  //periodo 2 =ano
  static Future<List<String>> chamarPropostas(String uid, int periodo) async {
    DateTime hoje = DateTime.now();
    String data;
    switch(periodo){
      case 0:
        break;
      case 1:
        data= GerenciarDatas.DataparaTextoFirebase(DateTime(hoje.year, hoje.month-1, hoje.day));
        break;
      case 2:
        data = GerenciarDatas.DataparaTextoFirebase(DateTime(hoje.year-1, hoje.month, hoje.day));
        break;
    }

    FirebaseFirestore db = FirebaseFirestore.instance;
    double despesa=0;
    double receita=0;
    String despesaStr;
    String receitaStr;
    String lucroStr;
    QuerySnapshot qs;
    if(periodo==0){
      qs= await db.collection("propostas").doc(uid).collection("propostasConcluidas").get();
    }else{
      qs= await db.collection("propostas").doc(uid).collection("propostasConcluidas").
      where("data", isGreaterThanOrEqualTo: data).get();
    }
    for(DocumentSnapshot documento in qs.docs){
      if(documento.data()["idCliente"]==uid){
        despesa+=documento.data()["preco"];
      }else{
        receita+=documento.data()["preco"];
      }
    }
    receitaStr =receita.toString().replaceAll(".", ",");
    despesaStr =despesa.toString().replaceAll(".", ",");
    lucroStr = (receita-despesa).toString().replaceAll(".", ",");
    if(receitaStr.indexOf(",")+2>receitaStr.length-1){
      receitaStr+="0";
    }
    if(despesaStr.indexOf(",")+2>despesaStr.length-1){
      despesaStr+="0";
    }
    if(lucroStr.indexOf(",")+2>lucroStr.length-1){
      lucroStr+="0";
    }

    return [receitaStr,despesaStr, lucroStr];
  }

}