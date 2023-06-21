import 'dart:developer';
import 'dart:io';
import 'package:file_server/directory_handler.dart';
import 'package:file_server/file_handler.dart';
import 'package:file_server/settings.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';

const staticResources = [
  '/folder-icon.png',
  '/upload-btn.png',
];

class MyHttpServer {
  late HttpServer _server;
  final Settings _settings;

  MyHttpServer(this._settings);

  void start() async {
    _server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      _settings.port,
    );
    log('Server running on port ${_settings.port}');
    await for (HttpRequest request in _server) {
      _handleRequest(request);
    }
  }

  void stop() {
    _server.close();
    log('Server stopped');
  }

  void _handleRequest(HttpRequest request) async {
    String path = request.uri.path;
    String absolutePath = _settings.rootDirectory + path;
    log('path: $path, absolutePath: $absolutePath');
    if (staticResources.contains(path)) {
      ByteData data = await rootBundle.load('assets$path');
      List<int> bytes = data.buffer.asUint8List();
      String mimeType = lookupMimeType(path) ?? 'image/png';
      request.response.headers.set('Content-Type', mimeType);
      request.response.add(bytes);
      await request.response.close();
    } else if (FileSystemEntity.isFileSync(absolutePath)) {
      handleFileRequest(request, absolutePath);
    } else if (FileSystemEntity.isDirectorySync(absolutePath)) {
      handleDirectoryRequest(request, absolutePath);
    } else {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('Not Found');
      request.response.close();
    }
  }
}
