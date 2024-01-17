class Servico{
  String _descricao;
  String _titulo;
  String _idPrestador;
  String _id;
  String _modalidade;
  bool _oculto;
  double _distancia;

  Servico();

  Servico.retornarServico(this._descricao, this._titulo, this._idPrestador, this._id,
      this._modalidade, this._oculto){
  }

  Servico.retornarBasico(this._id, this._titulo);

  double get distancia => _distancia;

  set distancia(double value) {
    _distancia = value;
  }

  bool get oculto => _oculto;

  set oculto(bool value) {
    _oculto = value;
  }

  String get modalidade => _modalidade;

  set modalidade(String value) {
    _modalidade = value;
  }

  String get descricao => _descricao;

  set descricao(String value) {
    _descricao = value;
  }

  String get titulo => _titulo;

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get idPrestador => _idPrestador;

  set idPrestador(String value) {
    _idPrestador = value;
  }

  set titulo(String value) {
    _titulo = value;
  }
}