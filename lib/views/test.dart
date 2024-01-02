// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_blue_pro/flutter_blue_pro.dart';


class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBluePlus.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return const FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subtitle2
                  ?.copyWith(color: Colors.white),
            ),
            ElevatedButton(
              child: const Text('TURN ON'),
              onPressed: Platform.isAndroid
                  ? () => FlutterBluePlus.instance.turnOn()
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Devices'),
        actions: [
          ElevatedButton(
            child: const Text('TURN OFF'),
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
              onPrimary: Colors.white,
            ),
            onPressed: Platform.isAndroid
                ? () => FlutterBluePlus.instance.turnOff()
                : null,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => FlutterBluePlus.instance
            .startScan(timeout: const Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(const Duration(seconds: 2))
                    .asyncMap((_) => FlutterBluePlus.instance.connectedDevices),
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map((d) => ListTile(
                            title: Text(d.name.toString()),
                            subtitle: Text(d.id.toString()),
                            trailing: StreamBuilder<BluetoothDeviceState>(
                              stream: d.state,
                              initialData: BluetoothDeviceState.disconnected,
                              builder: (c, snapshot) {
                                if (snapshot.data ==
                                    BluetoothDeviceState.connected) {
                                  return ElevatedButton(
                                    child: const Text('OPEN'),
                                    onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DeviceScreen(device: d))),
                                  );
                                }
                                return Text(snapshot.data.toString());
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBluePlus.instance.scanResults,
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map(
                        (r) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: InkWell(child: Container(
                            decoration:BoxDecoration(
                              border:Border.all(color:Colors.black)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(r.device.id.toString()),
                            )),
                          onTap:(){
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              r.device.connect();
                              return DeviceScreen(device: r.device);
                              }));
                          },
                          ),
                        ),
                        // ScanResultTile(
                        //   result: r,
                        //   onTap: () => Navigator.of(context)
                        //       .push(MaterialPageRoute(builder: (context) {
                        //     r.device.connect();
                        //     return DeviceScreen(device: r.device);
                        //   })),
                        // ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBluePlus.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: const Icon(Icons.stop),
              onPressed: () => FlutterBluePlus.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: const Icon(Icons.search),
                onPressed: () => FlutterBluePlus.instance
                    .startScan(timeout: const Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  ConnectionPriority? connectionPriority;

  List<int> _getRandomBytes() {
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
 
  List<Widget> widgetList = [];

  for(int i=0;i<services.length;i++){
    widgetList.add(Text(services[i].deviceId.toString()));
  }
  return widgetList;

  // Add widgets to the list


        // .map(
        //   (s) => ServiceTile(
        //     service: s,
        //     characteristicTiles: s.characteristics
        //         .map(
        //           (c) => CharacteristicTile(
        //             characteristic: c,
        //             onReadPressed: () => c.read(),
        //             onWritePressed: () async {
        //               await c.write(_getRandomBytes(), withoutResponse: true);
        //               await c.read();
        //             },
        //             onNotificationPressed: () async {
        //               await c.setNotifyValue(!c.isNotifying);
        //               await c.read();
        //             },
        //             descriptorTiles: c.descriptors
        //                 .map(
        //                   (d) => DescriptorTile(
        //                     descriptor: d,
        //                     onReadPressed: () => d.read(),
        //                     onWritePressed: () => d.write(_getRandomBytes()),
        //                   ),
        //                 )
        //                 .toList(),
        //           ),
        //         )
        //         .toList(),
        //   ),
        // )
        // .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: widget.device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => widget.device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => widget.device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return TextButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        ?.copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: widget.device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    snapshot.data == BluetoothDeviceState.connected
                        ? const Icon(Icons.bluetooth_connected)
                        : const Icon(Icons.bluetooth_disabled),
                    snapshot.data == BluetoothDeviceState.connected
                        ? StreamBuilder<int>(
                            stream: rssiStream(),
                            builder: (context, snapshot) {
                              return Text(
                                  snapshot.hasData ? '${snapshot.data}dBm' : '',
                                  style: Theme.of(context).textTheme.caption);
                            })
                        : Text('', style: Theme.of(context).textTheme.caption),
                  ],
                ),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${widget.device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: widget.device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data! ? 1 : 0,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => widget.device.discoverServices(),
                      ),
                      const IconButton(
                        icon: SizedBox(
                          // ignore: sort_child_properties_last
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                          ),
                          width: 18.0,
                          height: 18.0,
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
            StreamBuilder<int>(
              stream: widget.device.mtu,
              initialData: 0,
              builder: (c, snapshot) => ListTile(
                title: const Text('MTU Size'),
                subtitle: Text('${snapshot.data} bytes'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => widget.device.requestMtu(223),
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                showDialog(
                    context: context,
                    builder: ((context) {
                      return Dialog(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const ListTile(
                              title:
                                  Text('Choose connection parameter update:'),
                            ),
                            ListTile(
                              title: const Text('Connection Priority Balanced'),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async => await widget.device
                                    .requestConnectionPriority(
                                  connectionPriorityRequest:
                                      ConnectionPriority.balanced,
                                )
                                    .whenComplete(() {
                                  connectionPriority =
                                      ConnectionPriority.balanced;
                                  setState(() {});

                                  Navigator.pop(context);
                                }),
                              ),
                            ),
                            ListTile(
                              title: const Text('Connection Priority High'),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async => await widget.device
                                    .requestConnectionPriority(
                                  connectionPriorityRequest:
                                      ConnectionPriority.high,
                                )
                                    .whenComplete(() {
                                  connectionPriority = ConnectionPriority.high;
                                  setState(() {});

                                  Navigator.pop(context);
                                }),
                              ),
                            ),
                            ListTile(
                              title:
                                  const Text('Connection Priority Low Power'),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async => await widget.device
                                    .requestConnectionPriority(
                                  connectionPriorityRequest:
                                      ConnectionPriority.lowPower,
                                )
                                    .whenComplete(() {
                                  connectionPriority =
                                      ConnectionPriority.lowPower;
                                  setState(() {});
                                  Navigator.pop(context);
                                }),
                              ),
                            ),
                          ],
                        ),
                      );
                    }));
              },
              title: const Text(' Request Connection Priority'),
              subtitle: connectionPriority != null
                  ? Text('Connection priority status: $connectionPriority')
                  : null,
              trailing: const Icon(Icons.connect_without_contact),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: widget.device.services,
              initialData: const [],
              builder: (c, snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data!),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Stream<int> rssiStream() async* {
    var isConnected = true;
    final subscription = widget.device.state.listen((state) {
      isConnected = state == BluetoothDeviceState.connected;
    });
    while (isConnected) {
      yield await widget.device.readRssi();
      await Future.delayed(const Duration(seconds: 1));
    }
    subscription.cancel();
    // Device disconnected, stopping RSSI stream
  }
}