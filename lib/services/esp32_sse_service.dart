import 'dart:async';
import 'dart:convert';
import 'dart:io';

class SseEvent {
  final String name;
  final String data;

  const SseEvent(this.name, this.data);
}

class Esp32SseService {
  HttpClient? _sseClient;
  StreamSubscription<String>? _sseSub;

  String normalizeBaseUrl(String rawUrl, {bool isFirebase = false}) {
    var url = rawUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (url.isNotEmpty &&
        !url.startsWith('http://') &&
        !url.startsWith('https://')) {
      url = '${isFirebase ? 'https' : 'http'}://$url';
    }
    return url;
  }

  Future<void> connect({
    required String baseUrl,
    bool isFirebase = false,
    required void Function() onOpen,
    required void Function(SseEvent event) onEvent,
    required void Function() onDisconnected,
  }) async {
    disconnect();
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    _sseClient = client;

    try {
      final normalized = normalizeBaseUrl(baseUrl, isFirebase: isFirebase);
      final uri = Uri.parse(
        isFirebase ? '$normalized/irrigation.json' : '$normalized/events',
      );
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
      request.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');

      final response = await request.close();
      if (response.statusCode != 200) {
        throw HttpException('HTTP ${response.statusCode}');
      }

      onOpen();

      var currentEvent = 'message';
      final dataBuffer = StringBuffer();

      _sseSub = response
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          if (line.isEmpty) {
            if (dataBuffer.isNotEmpty) {
              onEvent(SseEvent(currentEvent, dataBuffer.toString().trimRight()));
            }
            currentEvent = 'message';
            dataBuffer.clear();
          } else if (line.startsWith('event:')) {
            currentEvent = line.substring(6).trim();
          } else if (line.startsWith('data:')) {
            dataBuffer.writeln(line.substring(5).trim());
          }
        },
        onError: (_) => onDisconnected(),
        onDone: onDisconnected,
        cancelOnError: true,
      );
    } catch (_) {
      onDisconnected();
    }
  }

  void disconnect() {
    _sseSub?.cancel();
    _sseSub = null;
    _sseClient?.close(force: true);
    _sseClient = null;
  }

  Future<Map<String, dynamic>> sendPumpCommand(String baseUrl, String state) async {
    return _requestJson('POST', '${normalizeBaseUrl(baseUrl)}/api/pump?state=$state');
  }

  Future<Map<String, dynamic>> saveThresholds(
    String baseUrl, {
    required double soil,
    required double tank,
  }) async {
    return _requestJson(
      'POST',
      '${normalizeBaseUrl(baseUrl)}/api/thresholds'
      '?soil=${soil.toStringAsFixed(0)}&tank=${tank.toStringAsFixed(0)}',
    );
  }

  Future<void> patchFirebaseControl(
    String baseUrl,
    Map<String, dynamic> body,
  ) async {
    final normalized = normalizeBaseUrl(baseUrl, isFirebase: true);
    await _requestJson('PATCH', '$normalized/irrigation/control.json', body: body);
  }

  Future<Map<String, dynamic>> _requestJson(
    String method,
    String url, {
    Map<String, dynamic>? body,
  }) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      final req = await client.openUrl(method, Uri.parse(url));
      if (body != null) {
        req.headers.contentType = ContentType.json;
        req.write(jsonEncode(body));
      }
      final res = await req.close();
      final resBody = await res.transform(utf8.decoder).join();
      if (resBody.isEmpty || resBody == 'null') return {};
      final decoded = jsonDecode(resBody);
      return decoded is Map<String, dynamic> ? decoded : {};
    } finally {
      client.close();
    }
  }
}
