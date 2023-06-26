import 'dart:developer';
import 'dart:io';
import 'package:file_server/service/directory_handler.dart';
import 'package:file_server/service/file_handler.dart';
import 'package:file_server/model/settings.dart';
import 'package:file_server/service/upload_handler.dart';

const staticResources = [
  '/folder-icon.png',
  '/file-icon.png',
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
      shared: true,
    );
    log('Server running on port ${_settings.port}');
    await _server.forEach((request) {
      _handleRequest(request);
    });
    // await for (HttpRequest request in _server) {
    //   _handleRequest(request);
    // }
  }

  void stop() {
    _server.close();
    log('Server stopped');
  }

  void _handleRequest(HttpRequest request) async {
    String path = request.uri.path;
    String absolutePath = _settings.rootDirectory + path;

    if (request.method == 'PUT') {
      log('handle PUT request');
      handleUploadRequest(request, absolutePath);
    } else if (staticResources.contains(path)) {
      handleStaticResourceRequest(request, path);
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
