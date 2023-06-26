import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  int port = 8080;
  String rootDirectory = '/';

  Future<void> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('port', port);
    await prefs.setString('rootDirectory', rootDirectory);
  }

  Future<void> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    port = prefs.getInt('port') ?? port;
    rootDirectory = prefs.getString('rootDirectory') ?? rootDirectory;
    if (rootDirectory == '/') {
      // final directory = await getExternalStorageDirectory();
      rootDirectory = '/storage/emulated/0/Download';
    }
  }

  @override
  String toString() {
    return 'port: $port\n'
        'rootDirectory: $rootDirectory';
  }
}
