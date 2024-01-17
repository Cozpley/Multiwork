import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GerenciarPosicoes{
  static registrarPosicao(String uid)async{
    FirebaseFirestore _db = FirebaseFirestore.instance;
    DocumentSnapshot _ds= await _db.collection("usuarios").doc(uid).get();
    Position pos;
    try{
      pos = await GeolocatorPlatform.instance.getCurrentPosition();
    }catch(_){
      List<Location> locations = await GeocodingPlatform.instance.locationFromAddress("${_ds.data()["estado"]}, ${_ds.data()["cidade"]}");
      if(locations.isNotEmpty){
        await _db.collection("usuarios").doc(uid).update({"latitude": locations[0].latitude.toString(), "longitude": locations[0].longitude.toString()});
        await GerenciarPosicoes.registrarPosServicos("${locations[0].latitude.toString()}","${locations[0].longitude.toString()}", uid);
      }else{
        //Localização padrão para quando não é possível definir uma
        await _db.collection("usuarios").doc(uid).update({"latitude": "-25.5952", "longitude": "-54.4878"});
        await GerenciarPosicoes.registrarPosServicos("-25.5952","-54.4878", uid);
      }
    }
    if(pos!=null){
      await _db.collection("usuarios").doc(uid).update({"latitude": pos.latitude.toString(), "longitude": pos.longitude.toString()});
      await GerenciarPosicoes.registrarPosServicos("${pos.latitude.toString()}","${pos.longitude.toString()}",uid);
    }
  }

  static registrarPosServicos(String lat, String long, uid)async{
    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot qs = await db.collection("servicos").where("idPrestador", isEqualTo:uid).get();

    for(DocumentSnapshot ds in qs.docs){
      db.collection("servicos").doc(ds.id).update({
        "latitude" : lat,
        "longitude":long
      });
    }
  }

  static Future<List> registrarPosicaoNovoCadastro()async{
    List lista;
    dynamic pos = await GeolocatorPlatform.instance.getCurrentPosition();
    if(pos!=null){
      lista= [pos.latitude.toString(), pos.longitude.toString()];
    }
    if(lista ==null){
      lista=["-25.5952","-54.4878"];
    }
    return lista;
  }
}