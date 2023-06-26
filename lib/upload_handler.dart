import 'dart:developer';
import 'dart:io';

void handleUploadRequest(HttpRequest request, String absolutePath) async {
  try {
    // Extract file name from request path
    final file = File(absolutePath);
    final sink = file.openWrite();
    await for (final data in request) {
      sink.add(data);
    }
    await sink.close();

    // Return success response
    request.response.statusCode = HttpStatus.ok;
    request.response.write('File uploaded successfully');
    await request.response.close();
  } catch (e) {
    // Return error response
    log(e.toString());
    request.response.statusCode = HttpStatus.internalServerError;
    request.response.write('Error uploading file: $e');
    await request.response.close();
  }
}
