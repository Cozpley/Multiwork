import 'package:flutter_multiwork/Model/Servico.dart';

class Proposta{
  static const String REQUISITADA = "requisitada";
  static const String AGENDADA = "agendada";
  static const String CONCLUIDA = "concluida";
  String _id;
  Servico _servico;
  String _idPrestador;
  String _idCliente;
  String _nomeCliente;
  String _nomePrestador;
  String _data;
  String _hora;
  double _preco;
  String _precoMostrar;
  String _status;

  Proposta.retornarProposta(this._id, this._servico, this._idCliente, this._nomeCliente,
      this._idPrestador, this._nomePrestador);

  Proposta();

  String get precoMostrar => _precoMostrar;

  set precoMostrar(String value) {
    _precoMostrar = value;
  }

  String get hora => _hora;

  set hora(String value) {
    _hora = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  double get preco => _preco;

  set preco(double value) {
    _preco = value;
  }

  String get data => _data;

  set data(String value) {
    _data = value;
  }

  String get nomeCliente => _nomeCliente;

  set nomeCliente(String value) {
    _nomeCliente = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  Servico get servico => _servico;

  set servico(Servico value) {
    _servico = value;
  }

  String get idCliente => _idCliente;

  set idCliente(String value) {
    _idCliente = value;
  }

  String get idPrestador => _idPrestador;

  set idPrestador(String value) {
    _idPrestador = value;
  }

  String get nomePrestador => _nomePrestador;

  set nomePrestador(String value) {
    _nomePrestador = value;
  }
}