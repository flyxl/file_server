import 'dart:isolate';

import 'package:flutter/material.dart';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../service/http_server.dart';
import '../model/settings.dart';
import '../util/utils.dart';
import 'settings_dialog.dart';

MyHttpServer? _httpServer;

Future<bool> _startForegroundService() async {
  if (await FlutterForegroundTask.isRunningService) {
    return FlutterForegroundTask.restartService();
  } else {
    return FlutterForegroundTask.startService(
      notificationTitle: 'Http File Server',
      notificationText:
          'To keep the service running, do not close this notification.',
      callback: _startServerCallback,
    );
  }
}

@pragma('vm:entry-point')
void _startServerCallback() {
  debugPrint('_startServerCallback');
  FlutterForegroundTask.setTaskHandler(HttpServerTaskHandler());
}

class HttpServerTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    debugPrint('HttpServerTaskHandler.onStart');
    if (_httpServer == null) {
      _httpServer = MyHttpServer(Settings.getInstance());
      _httpServer!.start();
    }
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {}

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    _httpServer?.stop();
    _httpServer = null;
  }
}

void _initForegroundTask() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'notification_channel_id',
      channelName: 'Foreground Notification',
      channelDescription:
          'This notification appears when the foreground service is running.',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.HIGH,
      iconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        resPrefix: ResourcePrefix.ic,
        name: 'launcher',
      ),
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 5000,
      isOnceEvent: false,
      autoRunOnBoot: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool _isServerRunning = false;
  String? _ipAddress;

  @override
  void initState() {
    super.initState();
    _initForegroundTask();
    Settings.getInstance()
        .load()
        .then((value) => Utils.getIpAddress())
        .then((value) => setState(() => _ipAddress = value));
  }

  void _startServer() async {
    await _startForegroundService();
    setState(() {
      _isServerRunning = true;
    });
  }

  void _stopServer() async {
    await FlutterForegroundTask.stopService();
    setState(() {
      _isServerRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Settings settings = Settings.getInstance();
    return WithForegroundTask(
      child: Scaffold(
        // return Scaffold(
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
                'Server URL: http://$_ipAddress:${settings.port}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Root Directory: ${settings.rootDirectory}',
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
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => SettingsDialog(settings),
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
      ),
    );
  }
}
