import 'package:wifi_info_flutter/wifi_info_flutter.dart';

class Utils {
  static Future<String> getIpAddress() async {
    String? ipAddress = await WifiInfo().getWifiIP();
    if (ipAddress == null) {
      return 'Unknown';
    }
    return ipAddress;
  }
}
