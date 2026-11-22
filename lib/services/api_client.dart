import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'storage_service.dart';

/// Endereço da API. Pode ser trocado no build:
/// `flutter run --dart-define=API_URL=https://api.exemplo.com/api`
const String apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:3000/api',
);

/// Erro retornado pela API (ou falha de rede), com a mensagem para o usuário.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? code;

  const ApiException(this.statusCode, this.message, {this.code});

  bool get isUnauthorized => statusCode == 401;
  bool get isNetworkError => statusCode == 0;

  @override
  String toString() => message;
}

/// Cliente HTTP da API do Educano.
///
/// Envia o token salvo no `Authorization`, converte as respostas JSON e
/// transforma erros em [ApiException]. Quando a sessão expira (401), avisa
/// [onSessionExpired] para o app voltar ao login.
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const _timeout = Duration(seconds: 30);
  static const _downloadTimeout = Duration(seconds: 60);

  http.Client _http = http.Client();

  /// Troca o cliente HTTP (usado pelos testes com uma API falsa).
  @visibleForTesting
  set httpClient(http.Client client) => _http = client;

  /// Chamado quando uma requisição autenticada recebe 401.
  void Function()? onSessionExpired;
  Future<bool>? _refreshInProgress;

  /// Renova e persiste os tokens; chamadas simultâneas compartilham a mesma
  /// renovação para que o refresh token rotativo não seja usado duas vezes.
  Future<bool> refreshSession() {
    final current = _refreshInProgress;
    if (current != null) return current;

    final refresh = _refreshSessionRequest();
    _refreshInProgress = refresh;
    return refresh.whenComplete(() {
      if (identical(_refreshInProgress, refresh)) {
        _refreshInProgress = null;
      }
    });
  }

  Future<bool> _refreshSessionRequest() async {
    final refreshToken = await StorageService.instance.loadRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    dynamic response;
    try {
      response = await _send(
        'POST',
        '/auth/refresh',
        body: {'refreshToken': refreshToken},
        authenticated: false,
      );
    } on ApiException catch (error) {
      if (error.isUnauthorized) return false;
      rethrow;
    }

    final data = responseMap(response, endpoint: '/auth/refresh');
    final token = responseString(
      data['token'],
      endpoint: '/auth/refresh.token',
      required: true,
    )!;
    final rotatedRefreshToken = responseString(
      data['refreshToken'],
      endpoint: '/auth/refresh.refreshToken',
      required: true,
    )!;

    await StorageService.instance.saveRefreshToken(rotatedRefreshToken);
    await StorageService.instance.saveToken(token);
    return true;
  }

  /// Converte falhas de formato em erros controlados da API, em vez de deixar
  /// casts inválidos escaparem como exceções não tratadas no Flutter.
  static T parseResponse<T>(String endpoint, T Function() parse) {
    try {
      return parse();
    } on TypeError {
      throw ApiException(
        502,
        'A resposta recebida para $endpoint está incompleta ou em formato inválido.',
      );
    } on FormatException {
      throw ApiException(
        502,
        'A resposta recebida para $endpoint está incompleta ou em formato inválido.',
      );
    } on RangeError {
      throw ApiException(
        502,
        'A resposta recebida para $endpoint está incompleta ou em formato inválido.',
      );
    }
  }

  /// Converte um objeto JSON, tratando objetos opcionais ausentes como vazios.
  static Map<String, dynamic> responseMap(
    Object? value, {
    required String endpoint,
    bool optional = false,
  }) => parseResponse(endpoint, () {
    if (value == null && optional) return <String, dynamic>{};
    if (value is Map) {
      final result = Map<String, dynamic>.from(value);
      if (result.isEmpty && !optional) {
        throw const FormatException('Objeto JSON vazio.');
      }
      return result;
    }
    throw const FormatException('Esperado um objeto JSON.');
  });

  /// Converte uma lista de objetos JSON; uma coleção ausente pode ser vazia.
  static List<Map<String, dynamic>> responseList(
    Object? value, {
    required String endpoint,
    bool optional = true,
  }) => parseResponse(endpoint, () {
    if (value == null && optional) return <Map<String, dynamic>>[];
    if (value is! List) throw const FormatException('Esperada uma lista JSON.');
    return [
      for (final item in value)
        if (item is Map<String, dynamic>)
          item
        else if (item is Map)
          Map<String, dynamic>.from(item)
        else
          throw const FormatException('Item inválido na lista JSON.'),
    ];
  });

  static String? responseString(
    Object? value, {
    required String endpoint,
    String? fallback,
    bool required = false,
  }) => parseResponse(endpoint, () {
    if (value == null) {
      if (required) throw const FormatException('Texto obrigatório ausente.');
      return fallback;
    }
    if (value is String) return value;
    throw const FormatException('Esperado um texto.');
  });

  static int responseInt(
    Object? value, {
    required String endpoint,
    int fallback = 0,
    bool required = false,
  }) => parseResponse(endpoint, () {
    if (value == null) {
      if (required) throw const FormatException('Número obrigatório ausente.');
      return fallback;
    }
    if (value is num) return value.toInt();
    throw const FormatException('Esperado um número inteiro.');
  });

  static List<String> responseStringList(
    Object? value, {
    required String endpoint,
    bool optional = true,
  }) => parseResponse(endpoint, () {
    if (value == null && optional) return <String>[];
    if (value is! List) throw const FormatException('Esperada uma lista JSON.');
    return [
      for (final item in value)
        if (item is String)
          item
        else
          throw const FormatException('Item inválido na lista JSON.'),
    ];
  });

  Future<dynamic> get(String path, {Map<String, Object?>? query}) =>
      _send('GET', path, query: query);

  Future<Uint8List> getBytes(Uri uri) async {
    try {
      final response = await _http
          .get(uri, headers: const {'Accept': 'application/pdf, */*'})
          .timeout(_downloadTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          response.statusCode,
          'Não foi possível baixar o arquivo (HTTP ${response.statusCode}).',
        );
      }
      return response.bodyBytes;
    } on TimeoutException {
      throw const ApiException(0, 'O download demorou demais. Tente novamente.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        0,
        'Não foi possível baixar o arquivo. Verifique sua conexão.',
      );
    }
  }

  Future<dynamic> post(String path, [Object? body]) =>
      _send('POST', path, body: body);

  /// Envia um POST público sem anexar um token salvo de uma sessão anterior.
  Future<dynamic> postPublic(String path, [Object? body]) =>
      _send('POST', path, body: body, authenticated: false);

  Future<dynamic> put(String path, [Object? body]) =>
      _send('PUT', path, body: body);

  Future<dynamic> patch(String path, [Object? body]) =>
      _send('PATCH', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  // Tipos aceitos pelo upload da API, pela extensão do arquivo.
  static const Map<String, String> _mimePorExtensao = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'mp3': 'audio/mpeg',
    'wav': 'audio/wav',
    'ogg': 'audio/ogg',
    'm4a': 'audio/mp4',
    'aac': 'audio/aac',
    'mp4': 'video/mp4',
    'webm': 'video/webm',
    'mov': 'video/quicktime',
    'pdf': 'application/pdf',
  };

  /// Envia um arquivo como `multipart/form-data` (POST).
  Future<dynamic> upload(
    String path, {
    required String field,
    required Uint8List bytes,
    required String fileName,
    Map<String, String> fields = const {},
    Map<String, Object?>? query,
  }) => multipart(
    'POST',
    path,
    fields: fields,
    file: (field: field, bytes: bytes, fileName: fileName),
    query: query,
  );

  /// Requisição `multipart/form-data` com campos e, opcionalmente, um arquivo.
  Future<dynamic> multipart(
    String method,
    String path, {
    Map<String, String> fields = const {},
    ({String field, Uint8List bytes, String fileName})? file,
    Map<String, Object?>? query,
    bool authenticated = true,
    bool retryOnUnauthorized = true,
  }) async {
    final request = http.MultipartRequest(method, _uri(path, query));
    final headers = await _headers(json: false, authenticated: authenticated);
    request.headers.addAll(headers);
    request.fields.addAll(fields);
    if (file != null) {
      final extensao = file.fileName.split('.').last.toLowerCase();
      final mime = _mimePorExtensao[extensao];
      request.files.add(
        http.MultipartFile.fromBytes(
          file.field,
          file.bytes,
          filename: file.fileName,
          contentType: mime == null ? null : MediaType.parse(mime),
        ),
      );
    }

    try {
      // Uploads grandes (vídeos) podem demorar mais que as demais requisições.
      final streamed = await _http
          .send(request)
          .timeout(const Duration(minutes: 15));
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 401 &&
          headers.containsKey('Authorization')) {
        if (retryOnUnauthorized && await refreshSession()) {
          return multipart(
            method,
            path,
            fields: fields,
            file: file,
            query: query,
            authenticated: authenticated,
            retryOnUnauthorized: false,
          );
        }
        onSessionExpired?.call();
      }
      return _handle(response);
    } on TimeoutException {
      throw const ApiException(0, 'O envio demorou demais. Tente novamente.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        0,
        'Não foi possível conectar ao servidor. Verifique sua conexão.',
      );
    }
  }

  Uri _uri(String path, [Map<String, Object?>? query]) {
    final params = <String, String>{
      for (final entry in (query ?? const {}).entries)
        if (entry.value != null && '${entry.value}'.isNotEmpty)
          entry.key: '${entry.value}',
    };
    final uri = Uri.parse('$apiBaseUrl$path');
    return params.isEmpty ? uri : uri.replace(queryParameters: params);
  }

  Future<Map<String, String>> _headers({
    bool json = true,
    bool authenticated = true,
  }) async {
    final token = authenticated
        ? await StorageService.instance.loadToken()
        : null;
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
    bool authenticated = true,
    bool retryOnUnauthorized = true,
  }) async {
    final request = http.Request(method, _uri(path, query));
    final headers = await _headers(authenticated: authenticated);
    request.headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    try {
      final streamed = await _http.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 401 &&
          headers.containsKey('Authorization')) {
        if (retryOnUnauthorized && await refreshSession()) {
          return _send(
            method,
            path,
            body: body,
            query: query,
            authenticated: authenticated,
            retryOnUnauthorized: false,
          );
        }
        onSessionExpired?.call();
      }
      return _handle(response);
    } on TimeoutException {
      throw const ApiException(
        0,
        'O servidor demorou para responder. Tente novamente.',
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        0,
        'Não foi possível conectar ao servidor. Verifique sua conexão.',
      );
    }
  }

  dynamic _handle(http.Response response) {
    final text = utf8.decode(response.bodyBytes);
    dynamic data;
    if (text.isNotEmpty) {
      try {
        data = jsonDecode(text);
      } on FormatException {
        throw const ApiException(
          502,
          'O servidor retornou uma resposta inválida. Tente novamente.',
        );
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) return data;

    final message =
        _messageFrom(data) ??
        'Não foi possível concluir a solicitação (${response.statusCode}).';
    final code = data is Map && data['code'] is String
        ? data['code'] as String
        : null;
    throw ApiException(response.statusCode, message, code: code);
  }

  String? _messageFrom(dynamic data) {
    if (data is! Map) return null;
    final message = data['message'] ?? data['mensagem'];

    // Para erros de validação, mostra o primeiro detalhe quando houver.
    final errors = data['errors'];
    if (errors is List && errors.isNotEmpty && errors.first is Map) {
      final detail = (errors.first as Map)['message'];
      if (detail is String &&
          detail.isNotEmpty &&
          !detail.startsWith('Invalid')) {
        return '${message ?? 'Dados inválidos.'} $detail';
      }
    }

    return message is String ? message : null;
  }
}
