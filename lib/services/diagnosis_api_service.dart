import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DiagnosisApiService {
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get _baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl.replaceFirst(RegExp(r'/$'), '');
    }
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  Future<Map<String, dynamic>> startDiagnosis(String problem) {
    return _post('/api/diagnosis/session/start', {'problem': problem});
  }

  Future<Map<String, dynamic>> answerQuestion(String sessionId, String answer) {
    final encodedSessionId = Uri.encodeComponent(sessionId);
    return _post('/api/diagnosis/session/$encodedSessionId/answer', {
      'answer': answer,
    });
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl$path'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 90));

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid diagnosis response.');
    }
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['success'] != true) {
      throw Exception(
        decoded['message']?.toString() ??
            'Diagnosis request failed (${response.statusCode}).',
      );
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Diagnosis response is missing data.');
    }
    return data;
  }
}
