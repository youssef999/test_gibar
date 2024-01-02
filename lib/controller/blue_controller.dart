
// ignore_for_file: non_constant_identifier_names


import 'package:get/get.dart';
import 'package:flutter_blue_pro/flutter_blue_pro.dart';

class BluetoothController extends GetxController{

  // FlutterBluePlus flutterBlue = FlutterBluePlus();
FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
// Listens to BLE devices

// late FlutterBluePlus flutterBlue;
// //FlutterBluePlus.instance;
// ignore: deprecated_member_use

// scanAndGetDevices(){



//   FlutterBluePlus.scanResults.listen((results){
//      print("////");
//     print(results);
//     print("////");
// // Hanlde discovered ble devices here
// });
// }

// void connectToDevice(BluetoothDevice device) async{
//     await device.connect();
// }

// Future scanDevices()async{


// print("SCAN");
// FlutterBluePlus.startScan(
//   timeout: const Duration(seconds: 6)
// ).then((value) {
//   // ignore: avoid_print
//   print('ok');
//   //ScanResults;
// }).catchError((onError){
// print(onError);
// });
// FlutterBluePlus.stopScan();

// }

// Stream<List<ScanResult>>get ScanResults{
//   print("SCCCCCC");
//   return FlutterBluePlus.scanResults;
// }
// }
}