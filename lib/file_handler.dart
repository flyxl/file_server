import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';

void handleFileRequest(HttpRequest request, String filePath) async {
  File file = File(filePath);
  String mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
  request.response.headers.set('Content-Type', mimeType);
  request.response.headers.set('Content-Disposition',
      'attachment; filename="${file.path.split('/').last}"');
  request.response.addStream(file.openRead()).then((_) {
    request.response.close();
  });
}

void handleStaticResourceRequest(HttpRequest request, String path) async {
  ByteData data = await rootBundle.load('assets$path');
  List<int> bytes = data.buffer.asUint8List();
  String mimeType = lookupMimeType(path) ?? 'image/png';
  request.response.headers.set('Content-Type', mimeType);
  request.response.add(bytes);
  await request.response.close();
}
