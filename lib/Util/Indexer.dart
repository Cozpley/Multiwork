import 'package:diacritic/diacritic.dart';

class Indexer{
  static Map<String, bool> indice(String str){
    str =str.toLowerCase();
    str = removeDiacritics(str);
    List<String> lista =str.split(" ");
    Map<String,bool> retorno={};
    for(String s in lista){
      retorno.addAll({s:true});
    }
    return retorno;
  }
}