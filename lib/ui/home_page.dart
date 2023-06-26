import 'package:flutter/material.dart';
import 'package:flutter_foreground_plugin/flutter_foreground_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

import '../service/http_server.dart';
import '../model/settings.dart';
import '../util/utils.dart';
import 'settings_dialog.dart';

MyHttpServer? _httpServer;

void startForegroundService() async {
  await FlutterForegroundPlugin.setServiceMethodInterval(seconds: 5);
  await FlutterForegroundPlugin.setServiceMethod(startHttpServer);
  await FlutterForegroundPlugin.startForegroundService(
    holdWakeLock: false,
    // onStarted: () {

    // },
    onStopped: () {
      _httpServer?.stop();
    },
    title: "Http File Server",
    content: "",
    iconName: "ic_launcher",
  );
}

void startHttpServer() {
  Settings settings = Settings();
  settings.load();
  _httpServer = MyHttpServer(settings);
  _httpServer!.start();
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final Settings _settings = Settings();

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
    startForegroundService();
    setState(() {
      _isServerRunning = true;
    });
  }

  void _stopServer() {
    FlutterForegroundPlugin.stopForegroundService();
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
