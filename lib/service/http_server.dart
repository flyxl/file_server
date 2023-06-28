import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:file_server/service/directory_handler.dart';
import 'package:file_server/service/file_handler.dart';
import 'package:file_server/model/settings.dart';
import 'package:file_server/service/upload_handler.dart';
import 'package:flutter/services.dart';

const staticResources = [
  '/folder-icon.png',
  '/file-icon.png',
  '/upload-btn.png',
];

class _Params {
  final Settings settings;
  final Map<String, List<int>> staticResourceMap;
  final String fileListHtmlTemplate;
  final SendPort sendPort;

  _Params(this.settings, this.staticResourceMap, this.fileListHtmlTemplate,
      this.sendPort);
}

class MyHttpServer {
  SendPort? _controlPort;
  final Settings _settings;

  MyHttpServer(this._settings);

  void start() async {
    if (_controlPort != null) {
      return;
    }

    final staticResourceMap = <String, List<int>>{};
    for (final path in staticResources) {
      ByteData data = await rootBundle.load('assets$path');
      List<int> bytes = data.buffer.asUint8List();
      staticResourceMap.putIfAbsent(path, () => bytes);
    }

    final template =
        await rootBundle.loadString('assets/directory_template.html');

    // final params = {
    //   'settings': _settings,
    //   'staticResources': staticResourceMap,
    //   'fileListHtmlTemplate': template,
    // };

    final receivePort = ReceivePort();
    final params = _Params(_settings, staticResourceMap, template, receivePort.sendPort);
    await Isolate.spawn(_startServer, params);
    _controlPort = await receivePort.first;
  }

  static void _startServer(_Params params) async {
    ReceivePort receivePort = ReceivePort();
    params.sendPort.send(receivePort.sendPort);

    final port = params.settings.port;
    final server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      port,
      shared: true,
    );
    log('Server is running on port $port');

    receivePort.listen((signal) async {
      if (signal == 'stop') {
        await server.close();
        log('Http server is stopped');
        Isolate.exit();
      }
    });

    final rootDirectory = params.settings.rootDirectory;
    final staticResourcesMap = params.staticResourceMap;
    final fileListHtmlTemplate = params.fileListHtmlTemplate;
    await for (final request in server) {
      _handleRequest(
          request, rootDirectory, staticResourcesMap, fileListHtmlTemplate);
    }
  }

  void stop() {
    _controlPort?.send('stop');
    _controlPort = null;
  }

  static void _handleRequest(
      HttpRequest request,
      String rootDirectory,
      Map<String, List<int>> staticResourcesMap,
      String fileListHtmlTemplate) async {
    final path = request.uri.path;

    final absolutePath = rootDirectory + path;
    if (request.method == 'PUT') {
      log('handle PUT request');
      handleUploadRequest(request, absolutePath);
    } else if (staticResources.contains(path)) {
      handleStaticResourceRequest(request, path, staticResourcesMap);
    } else if (FileSystemEntity.isFileSync(absolutePath)) {
      handleFileRequest(request, absolutePath);
    } else if (FileSystemEntity.isDirectorySync(absolutePath)) {
      handleDirectoryRequest(request, absolutePath, fileListHtmlTemplate);
    } else {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('Not Found');
      request.response.close();
    }
  }
}
