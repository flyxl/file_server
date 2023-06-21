import 'dart:io';
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
