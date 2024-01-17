import 'package:intl/intl.dart';

class GerenciarDatas{

  static String DataparaTextoFirebase(DateTime dt){
    final format = DateFormat("yyyy-MM-dd");
    return format.format(dt);
  }

  static String TextoFirebaseparaUsuario(String str){
    DateTime data =TextoparaData(str);
    return DataparaTextoUsuario(data);
  }

  static DateTime TextoparaData(String str){
    final DateTime retorno = DateTime.parse(str);
    return retorno;
  }

  static String DataparaTextoUsuario(DateTime dt){
    final format = DateFormat("dd/MM/yyyy");
    return format.format(dt);
  }

  static String carregarData(){
    return GerenciarDatas.DataparaTextoFirebase(DateTime.now());
  }

}
