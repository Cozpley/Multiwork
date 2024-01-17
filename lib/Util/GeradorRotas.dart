import 'package:flutter/material.dart';
import 'package:flutter_multiwork/Telas/AceitarProposta.dart';
import 'package:flutter_multiwork/Telas/AdicionarServico.dart';
import 'package:flutter_multiwork/Telas/Agenda/Agenda.dart';
import 'package:flutter_multiwork/Telas/Cadastro.dart';
import 'package:flutter_multiwork/Telas/ContaUsuario.dart';
import 'package:flutter_multiwork/Telas/Conversas.dart';
import 'package:flutter_multiwork/Telas/DeleteTelefone.dart';
import 'package:flutter_multiwork/Telas/EditDadoPessoal.dart';
import 'package:flutter_multiwork/Telas/EditEmail.dart';
import 'package:flutter_multiwork/Telas/EditarServico.dart';
import 'package:flutter_multiwork/Telas/ExcluirConta.dart';
import 'package:flutter_multiwork/Telas/ExibirMeuServico.dart';
import 'package:flutter_multiwork/Telas/Login.dart';
import 'package:flutter_multiwork/Telas/Mensagens.dart';
import 'package:flutter_multiwork/Telas/MeusServicos.dart';
import 'package:flutter_multiwork/Telas/OutroUsuario.dart';
import 'package:flutter_multiwork/Telas/ProcurarServico.dart';
import 'package:flutter_multiwork/Telas/PropostaAgendada.dart';
import 'package:flutter_multiwork/Telas/PropostaRequisitada.dart';
import 'package:flutter_multiwork/Telas/RecuperarSenha.dart';
import 'package:flutter_multiwork/Telas/RelatorioFinanceiro/RelatorioFinanceiro.dart';
import 'package:flutter_multiwork/Telas/RelatorioServicos.dart';
import 'package:flutter_multiwork/Telas/ServicoOutroUsuario.dart';
import 'package:flutter_multiwork/Telas/ServicoRelatorioServico.dart';
import 'package:flutter_multiwork/Telas/PesquisarUsuarios.dart';
import 'package:flutter_multiwork/Telas/AddTelefone.dart';
import 'package:flutter_multiwork/Telas/EditTelefone.dart';
import 'package:flutter_multiwork/Telas/Home.dart';
import 'package:flutter_multiwork/Telas/EditarData.dart';
import 'package:flutter_multiwork/Telas/Inicio.dart';

class GeradorRotas {
  static Route<dynamic> gerar(RouteSettings settings){
    final args = settings.arguments;
    switch(settings.name){
      case "/":
        return MaterialPageRoute(
            builder: (_) => Inicio()
        );
      case "/inicio":
        return MaterialPageRoute(
            builder: (_) => Inicio()
        );
      case "/login":
        return MaterialPageRoute(
            builder: (_) => Login()
        );
      case "/cadastro":
        return MaterialPageRoute(
            builder: (_) => Cadastro(args)
        );
      case "/home":
        return MaterialPageRoute(
            builder: (_) => Home()
        );
      case "/contaUsuario":
        return MaterialPageRoute(
            builder: (_) => ContaUsuario()
        );
      case "/editarData":
        return MaterialPageRoute(
            builder: (_) => EditarData(args)
        );
      case "/addTelefone":
        return MaterialPageRoute(
            builder: (_) => AddTelefone(args)
        );
      case "/deleteTelefone":
        return MaterialPageRoute(
            builder: (_) => DeleteTelefone(args)
        );
      case "/editTelefone":
        return MaterialPageRoute(
            builder: (_) => EditTelefone(args)
        );
      case "/excluirConta":
        return MaterialPageRoute(
            builder: (_) => ExcluirConta(args)
        );
      case "/editDadoPessoal":
        return MaterialPageRoute(
            builder: (_) => EditDadoPessoal(args)
        );
      case "/editEmail":
        return MaterialPageRoute(
            builder: (_) => EditEmail(args)
        );
      case "/pesquisarUsuarios":
        return MaterialPageRoute(
            builder: (_) => PesquisarUsuarios(args)
        );
      case "/outroUsuario":
        return MaterialPageRoute(
            builder: (_) => OutroUsuario(args)
        );
      case "/recuperarSenha":
        return MaterialPageRoute(
            builder: (_) => RecuperarSenha()
        );
      case "/meusServicos":
        return MaterialPageRoute(
            builder: (_) => MeusServicos()
        );
      case "/adicionarServico":
        return MaterialPageRoute(
            builder: (_) => AdicionarServico()
        );
      case "/exibirMeuServico":
        return MaterialPageRoute(
            builder: (_) => ExibirMeuServico(args)
        );
      case "/editarServico":
        return MaterialPageRoute(
            builder: (_) => EditarServico(args)
        );
      case "/procurarServico":
        return MaterialPageRoute(
            builder: (_) => ProcurarServico()
        );
      case "/servicoOutroUsuario":
        return MaterialPageRoute(
            builder: (_) => ServicoOutroUsuario(args)
        );
      case "/agenda":
        return MaterialPageRoute(
            builder: (_) => Agenda(args)
        );
      case "/propostaRequisitada":
        return MaterialPageRoute(
            builder: (_) => PropostaRequisitada(args)
        );
      case "/aceitarProposta":
        return MaterialPageRoute(
            builder: (_) => AceitarProposta(args)
        );
      case "/propostaAgendada":
        return MaterialPageRoute(
            builder: (_) => PropostaAgendada(args)
        );
      case "/relatorioFinanceiro":
        return MaterialPageRoute(
            builder: (_) => RelatorioFinanceiro(args)
        );
      case "/relatorioServicos":
        return MaterialPageRoute(
            builder: (_) => RelatorioServicos(args)
        );
      case "/servicoRelatorioServico":
        return MaterialPageRoute(
            builder: (_) => ServicoRelatorioServico(args)
        );
      case "/mensagens":
        return MaterialPageRoute(
            builder: (_) => Mensagens(args)
        );
      case "/conversas":
        return MaterialPageRoute(
            builder: (_) => Conversas()
        );
      default:
        return MaterialPageRoute(
          builder: (_) => ErroRota()
        );
    }
  }

  static Scaffold ErroRota(){
    return Scaffold(
        appBar: AppBar(
        centerTitle: true,
        title: Text("Erro de rota", style: TextStyle(fontSize: 20, color: Colors.white),),
        ),
      body: Container(),
    );
  }
}