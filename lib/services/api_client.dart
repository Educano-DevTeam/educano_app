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

  http.Client _http = http.Client();

  /// Troca o cliente HTTP (usado pelos testes com uma API falsa).
  @visibleForTesting
  set httpClient(http.Client client) => _http = client;

  /// Chamado quando uma requisição autenticada recebe 401.
  void Function()? onSessionExpired;

  Future<dynamic> get(String path, {Map<String, Object?>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, [Object? body]) =>
      _send('POST', path, body: body);

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
  }) async {
    final request = http.MultipartRequest(method, _uri(path, query));
    request.headers.addAll(await _headers(json: false));
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

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await StorageService.instance.loadToken();
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
  }) async {
    final request = http.Request(method, _uri(path, query));
    request.headers.addAll(await _headers());
    if (body != null) request.body = jsonEncode(body);

    try {
      final streamed = await _http.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
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
      } catch (_) {
        data = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) return data;

    final message = _messageFrom(data) ??
        'Não foi possível concluir a solicitação (${response.statusCode}).';
    final code = data is Map ? data['code'] as String? : null;
    final hadToken = response.request?.headers['Authorization'] != null;

    if (response.statusCode == 401 && hadToken) {
      onSessionExpired?.call();
    }

    throw ApiException(response.statusCode, message, code: code);
  }

  String? _messageFrom(dynamic data) {
    if (data is! Map) return null;
    final message = data['message'] ?? data['mensagem'];

    // Para erros de validação, mostra o primeiro detalhe quando houver.
    final errors = data['errors'];
    if (errors is List && errors.isNotEmpty && errors.first is Map) {
      final detail = (errors.first as Map)['message'];
      if (detail is String && detail.isNotEmpty && !detail.startsWith('Invalid')) {
        return '${message ?? 'Dados inválidos.'} $detail';
      }
    }

    return message is String ? message : null;
  }
}
