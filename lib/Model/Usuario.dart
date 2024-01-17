class Usuario{
  String _nome;
  List<String> _telefones=List();
  String _dataNasc;
  String _estado;
  String _cidade;
  String _rua;
  String _complemento;
  String _numero;
  String _email;
  String _senha;
  bool _mostrarEndereco;
  bool _hasContaFacebook;
  bool _hasContaGoogle;
  String _id;
  String _latitude;
  String _longitude;
  double _distancia;

  Usuario();

  Usuario.UsuarioComEndereco(this._telefones, this._nome, this._dataNasc,
      this._estado, this._cidade, this._rua, this._numero, this._complemento,
      this._email, this._mostrarEndereco, this._latitude, this._longitude) {
  }

  Usuario.UsuarioSemEndereco(this._telefones,this._nome, this._dataNasc, this._email,
      this._mostrarEndereco) {
  }

  double get distancia => _distancia;

  set distancia(double value) {
    _distancia = value;
  }

  String get latitude => _latitude;

  set latitude(String value) {
    _latitude = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  bool get hasContaFacebook => _hasContaFacebook;

  set hasContaFacebook(bool value) {
    _hasContaFacebook = value;
  }

  bool get mostrarEndereco => _mostrarEndereco;

  set mostrarEndereco(bool value) {
    _mostrarEndereco = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  List<String> get telefones => _telefones;

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get numero => _numero;

  set numero(String value) {
    _numero = value;
  }

  String get complemento => _complemento;

  set complemento(String value) {
    _complemento = value;
  }

  String get rua => _rua;

  set rua(String value) {
    _rua = value;
  }

  String get cidade => _cidade;

  set cidade(String value) {
    _cidade = value;
  }

  String get estado => _estado;

  set estado(String value) {
    _estado = value;
  }

  String get dataNasc => _dataNasc;

  set dataNasc(String value) {
    _dataNasc = value;
  }

  set telefones(List<String> value) {
    _telefones = value;
  }

  bool get hasContaGoogle => _hasContaGoogle;

  set hasContaGoogle(bool value) {
    _hasContaGoogle = value;
  }

  String get longitude => _longitude;

  set longitude(String value) {
    _longitude = value;
  }
}