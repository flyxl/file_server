import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  int port = 8080;
  String rootDirectory = '/storage/emulated/0/Download';

  static Settings? _instance;

  Settings._internal();

  static Settings getInstance() {
    _instance ??= Settings._internal();

    return _instance!;
  }

  Future<void> save() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('port', port);
    await prefs.setString('rootDirectory', rootDirectory);
  }

  Future<void> load() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    port = prefs.getInt('port') ?? port;
    rootDirectory = prefs.getString('rootDirectory') ?? rootDirectory;
  }

  @override
  String toString() {
    return 'port: $port\n'
        'rootDirectory: $rootDirectory';
  }
}
