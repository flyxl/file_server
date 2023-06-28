import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mustache_template/mustache_template.dart';

void handleDirectoryRequest(
    HttpRequest request, String dirPath, String template) async {
  Directory dir = Directory(dirPath);
  List<FileSystemEntity> entities = dir.listSync();
  final html = await generateDirectoryHtml(entities, dir.path, template);
  request.response.headers.set('Content-Type', 'text/html; charset=utf-8');
  request.response.write(html);
  request.response.close();
}

Future<String> generateDirectoryHtml(
    List<FileSystemEntity> entities, String dirPath, String template) async {
  final templateEntities = entities.map((entity) {
    String name = entity.path.split('/').last;
    // if (name.length > 18) {
    //   name = '${name.substring(0, 18)}...';
    // }
    final isDirectory = FileSystemEntity.isDirectorySync(entity.path);
    final encodedName = Uri.encodeComponent(name);
    return {
      'name': name,
      'url': isDirectory ? '$encodedName/' : encodedName,
      'isDirectory': isDirectory,
    };
  }).toList();
  templateEntities.sort((a, b) {
    final isDirectoryA = a['isDirectory'] as bool;
    final isDirectoryB = b['isDirectory'] as bool;
    if (isDirectoryA && !isDirectoryB) {
      return -1; // a is a directory, so it should come first
    } else if (!isDirectoryA && isDirectoryB) {
      return 1; // b is a directory, so it should come first
    } else {
      // both are directories or both are files, so sort by name
      final nameA = a['name'] as String;
      final nameB = b['name'] as String;
      return nameA.compareTo(nameB);
    }
  });
  final data = {
    'dirPath': dirPath,
    'entities': templateEntities,
  };
  final result = Template(template).renderString(data);
  return result;
}
