
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gibar_app/views/test.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bluetooth scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  const FlutterBlueApp()
    );
  }
}

