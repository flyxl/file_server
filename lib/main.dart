import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:file_server/settings_dialog.dart';
import 'package:file_server/http_server.dart';
import 'package:file_server/settings.dart';
import 'package:file_server/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.storage.request();
  await Permission.manageExternalStorage.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HTTP File Server',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final Settings _settings = Settings();
  MyHttpServer? _httpServer;
  bool _isServerRunning = false;
  String? _ipAddress;

  @override
  void initState() {
    super.initState();
    Permission.storage
        .request()
        .then((_) => _settings.load())
        .then((value) => Utils.getIpAddress())
        .then((value) => setState(() => _ipAddress = value));
  }

  void _startServer() {
    log('$_settings');
    _httpServer = MyHttpServer(_settings);
    _httpServer!.start();
    setState(() {
      _isServerRunning = true;
    });
  }

  void _stopServer() {
    _httpServer!.stop();
    setState(() {
      _isServerRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTTP File Server'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'IP Address: $_ipAddress',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Server URL: http://$_ipAddress:${_settings.port}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Root Directory: ${_settings.rootDirectory}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            const Text(
              'Server Status:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Text(
              _isServerRunning ? 'Running' : 'Stopped',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => SettingsDialog(_settings),
                    );
                  },
                  child: const Text('Settings'),
                ),
                ElevatedButton(
                  onPressed: _isServerRunning ? _stopServer : _startServer,
                  child:
                      Text(_isServerRunning ? 'Stop Server' : 'Start Server'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
