import 'dart:convert';

import 'package:educano_app/services/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// API do Educano em memória para os testes de widget (sem rede).
///
/// Cobre o cadastro/validação/login e as consultas usadas pelas telas
/// testadas (perfil, planos, loja e inventário).
class FakeApi {
  FakeApi._();

  static const password = 'Senha@123';
  static const validCode = 'ABC123';

  static final Map<String, Map<String, dynamic>> _users = {};
  static final Set<String> _pending = {};
  static final Map<String, String?> authorizationByPath = {};
  static final List<String> requests = [];
  static final Map<String, http.Response> responseOverrides = {};

  static void install() {
    reset();
    ApiClient.instance.httpClient = MockClient(_handle);
  }

  static void reset() {
    _users
      ..clear()
      ..['aluno@educano.test'] = {
        'id': '00000000-0000-4000-8000-000000000001',
        'nome': 'Ana Souza',
        'email': 'aluno@educano.test',
        'tipo': 'ALUNO',
        'status': 'ATIVO',
      };
    _pending.clear();
    authorizationByPath.clear();
    requests.clear();
    responseOverrides.clear();
  }

  static Future<http.Response> _handle(http.Request request) async {
    final path = request.url.path.replaceFirst(RegExp(r'^/api'), '');
    authorizationByPath[path] = request.headers['Authorization'];
    requests.add('${request.method} $path');
    final override = responseOverrides['${request.method} $path'];
    if (override != null) return override;
    final body = request.body.isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(request.body) as Map<String, dynamic>;

    http.Response json(Object data, [int status = 200]) => http.Response(
      jsonEncode(data),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

    switch ('${request.method} $path') {
      case 'POST /auth/register':
        if (request.headers.containsKey('Authorization') ||
            body['tipo'] != 'ALUNO') {
          return json({
            'message': 'Você não tem autorização para cadastrar usuários.',
          }, 403);
        }
        final email = (body['email'] as String).toLowerCase();
        _users[email] = {
          'id':
              '00000000-0000-4000-8000-${_users.length.toString().padLeft(12, '0')}',
          'nome': body['nome'],
          'email': email,
          'tipo': 'ALUNO',
          'status': 'PENDENTE',
        };
        _pending.add(email);
        return json({
          'message': 'Cadastro criado.',
          'usuario': _users[email],
        }, 201);
      case 'POST /auth/verify-code':
        final email = (body['email'] as String).toLowerCase();
        if (body['codigo'] != validCode || !_pending.remove(email)) {
          return json({'message': 'Código de validação incorreto.'}, 400);
        }
        _users[email]!['status'] = 'ATIVO';
        return json({'message': 'Conta validada e ativada com sucesso.'});
      case 'POST /auth/login':
        final user = _users[(body['email'] as String).toLowerCase()];
        if (user == null ||
            body['senha'] != password ||
            user['status'] != 'ATIVO') {
          return json({
            'message': 'E-mail, senha inválidos ou conta ainda não ativada.',
          }, 401);
        }
        return json({
          'message': 'Login realizado com sucesso.',
          'token': 'token-de-teste',
          'usuario': user,
        });
      case 'GET /auth/me':
        return json({
          'autenticado': true,
          'usuario': _users.values.first,
          'perfil': null,
        });
      case 'GET /users/me/profile':
        return json({
          'perfil': {
            'tipoPerfil': 'PUBLICO',
            'urlFotoPerfil': '',
            'xp': 120,
            'moedas': 300,
          },
        });
      case 'GET /progress/me':
        return json(_progress);
      case 'GET /plans':
        return json({'idPlanoAtual': 'p1', 'dados': _plans});
      case 'GET /items':
        return json({
          'saldo': 300,
          'categorias': ['Estudos', 'Proteção'],
          'dados': _items,
        });
      case 'GET /inventory':
        return json({
          'saldo': 300,
          'dados': [
            {
              'item': _items[1],
              'quantidade': 1,
              'ativo': false,
              'ativacao': null,
            },
          ],
        });
    }

    return json({'message': 'Rota não simulada: ${request.method} $path'}, 404);
  }

  static final _plans = [
    {
      'id': 'p1',
      'nome': 'Básico',
      'precoCentavos': 0,
      'cor': '#7DAB9E',
      'icone': 'school',
      'destaque': null,
      'beneficios': ['Ranking global'],
      'indisponiveis': ['Simulados ilimitados'],
      'limiteSimuladosMes': 3,
      'acessoCursosPremium': false,
      'ordem': 0,
      'atual': true,
    },
    {
      'id': 'p2',
      'nome': 'Pro',
      'precoCentavos': 2990,
      'cor': '#425BC2',
      'icone': 'workspace_premium',
      'destaque': 'Mais Popular',
      'beneficios': ['Simulados ilimitados'],
      'indisponiveis': [],
      'limiteSimuladosMes': null,
      'acessoCursosPremium': true,
      'ordem': 1,
      'atual': false,
    },
  ];

  static final _items = [
    {
      'id': 'i1',
      'nome': 'Dica Extra',
      'descricao': 'Elimina uma alternativa errada.',
      'preco': 80,
      'icone': 'lightbulb',
      'cor': '#79B425',
      'categoria': 'Estudos',
      'efeito': 'DICA_EXTRA',
      'valorEfeito': 0,
      'duracaoMinutos': null,
      'ativo': true,
      'quantidadeNoInventario': 0,
    },
    {
      'id': 'i2',
      'nome': 'Escudo de Sequência',
      'descricao': 'Protege sua sequência por um dia.',
      'preco': 150,
      'icone': 'shield',
      'cor': '#425BC2',
      'categoria': 'Proteção',
      'efeito': 'ESCUDO_SEQUENCIA',
      'valorEfeito': 0,
      'duracaoMinutos': 1440,
      'ativo': true,
      'quantidadeNoInventario': 1,
    },
  ];

  static final _progress = {
    'perfil': {
      'nivel': 0,
      'xpNoNivel': 120,
      'xpParaProximoNivel': 250,
      'proximoNivelEm': 250,
      'xp': 120,
      'moedas': 300,
      'sequenciaDias': 2,
      'plano': {'id': 'p1', 'nome': 'Básico'},
      'posicaoRanking': 4,
    },
    'cursos': {'inscritos': 0, 'concluidos': 0, 'lista': []},
    'simulados': {'realizados': 0, 'mediaNota': 0, 'melhorNota': 0},
    'desempenho': {'porMateria': [], 'porTema': []},
    'evolucao': [
      {'mes': 'Out', 'ano': 2026, 'simulados': 70, 'atividades': 50},
      {'mes': 'Nov', 'ano': 2026, 'simulados': 80, 'atividades': 60},
    ],
    'recompensasRecentes': [],
  };
}
