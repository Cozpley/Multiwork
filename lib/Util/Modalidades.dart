import 'package:flutter/foundation.dart';

enum Modalidades{
  Limpeza,
  Construcao,
  Acabamento,
  Culinaria,
  Saude,
  Beleza,
  Transporte,
  Reparos,
  Outra
}

class GerenciarModalidades{


  static List<String> listaExibicao(){
    List<Modalidades> aux = Modalidades.values.toList();
    return aux.map((value){
      String retorno= describeEnum(value);
      if(retorno=="Construcao"){
        return "Construção";
      }else if(retorno=="Culinaria"){
        return "Culinária";
      }else if(retorno=="Saude"){
        return "Saúde";
      }else{
        return retorno;
      }
    }).toList();
  }
}