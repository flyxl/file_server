import 'dart:developer';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';

class Utils {
  static Future<String> getIpAddress() async {
    // String ipAddress = 'Unknown';
    // try {
    //   for (final interface in await NetworkInterface.list()) {
    //     for (final address in interface.addresses) {
    //       if (address.address.contains('.')) {
    //         ipAddress = address.address;
    //         break;
    //       }
    //     }
    //     if (ipAddress != 'Unknown') {
    //       break;
    //     }
    //   }
    // } on SocketException catch (e) {
    //   print('Error: ${e.toString()}');
    // }
    // return ipAddress;
    String? ipAddress = await WifiInfo().getWifiIP();
    if (ipAddress == null) {
      return 'Unknown';
    }
    log('ip: $ipAddress');
    return ipAddress;
  }
}
