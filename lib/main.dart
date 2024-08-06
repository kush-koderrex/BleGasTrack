// Copyright 2017-2023, Charles Weinberger & Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'screens/bluetooth_off_screen.dart';
import 'screens/scan_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
  InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const FlutterBlueApp());
}



//
// This widget shows BluetoothOffScreen or
// ScanScreen depending on the adapter state
//
class FlutterBlueApp extends StatefulWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = _adapterState == BluetoothAdapterState.on
        ? const ScanScreen()
        : BluetoothOffScreen(adapterState: _adapterState);
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent.shade100),
        useMaterial3: false,
      ),
      color: Colors.redAccent,
      home: screen,
      navigatorObservers: [BluetoothAdapterStateObserver()],
    );
  }
}

//
// This observer listens for Bluetooth Off and dismisses the DeviceScreen
//
class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      // Start listening to Bluetooth state changes when a new route is pushed
      _adapterStateSubscription ??= FlutterBluePlus.adapterState.listen((state) {
        if (state != BluetoothAdapterState.on) {
          // Pop the current route if Bluetooth is off
          navigator?.pop();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // Cancel the subscription when the route is popped
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}






//
// import 'package:ble_service/permissions/bluetooth_adapter.dart';
// import 'package:ble_service/permissions/check_status.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_background/flutter_blue_background.dart';
//
//
// class GasBackgroudScreen extends StatefulWidget {
//   const GasBackgroudScreen({super.key});
//
//   @override
//   State<GasBackgroudScreen> createState() => _GasBackgroudScreenState();
// }
//
// class _GasBackgroudScreenState extends State<GasBackgroudScreen> {
//   String readData = "";
//   bool isServiceRunning = false;
//   String buttonText = 'Start BG Android Service';
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Gas track'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () async {
//                   BluetoothAdapter.initBleStateStream();
//                   if (await PermissionEnable().check() == true) {
//                     await FlutterBlueBackground.startFlutterBackgroundService(
//                             () async {
//                           await FlutterBlueBackground.connectToDevice(
//                               deviceName: 'BLE Device',
//                               serviceUuid: '9999',
//                               characteristicUuid: '9191'
//                             // deviceName: 'Ble',
//                             // serviceUuid: 'f000c0c0-0451-4000-b000-000000000000',
//                             // characteristicUuid: '0xF000C0C2-0451-B000-000000000000'
//                           );
//
//                           await FlutterBlueBackground.writeData(
//                             // characteristicUuid: '0xF000C0C1-0451-B000-000000000000',
//                               characteristicUuid: '9191',
//                               data: 'testing');
//
//                           String? data = await FlutterBlueBackground.readData(
//                               characteristicUuid: '9191');
//                           // characteristicUuid: '0xF000C0C2-0451-B000-000000000000');
//
//                           setState(() {
//                             readData = data ?? 'No data received';
//                             isServiceRunning = true;
//                             buttonText = 'Stop BG Android Service';
//                           });
//                         });
//                   }
//                 },
//                 child: Text(buttonText),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (isServiceRunning) {
//                     await FlutterBlueBackground.stopFlutterBackgroundService();
//                     setState(() {
//                       isServiceRunning = false;
//                       buttonText = 'Start BG Android Service';
//                     });
//                   }
//                 },
//                 child: const Text('Stop Service'),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Read Data: $readData',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }






// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//
// }

// import 'package:ble_service/permissions/bluetooth_adapter.dart';
// import 'package:ble_service/permissions/check_status.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_background/flutter_blue_background.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//
//   String readData = "";
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Gas track'),
//         ),
//         body: Center(
//           child: Column(
//             children: [
//               const SizedBox(height: 20,),
//               ElevatedButton(
//                   onPressed: () async {
//
//                     BluetoothAdapter.initBleStateStream();
//                     if(await PermissionEnable().check() == true) {
//                       await FlutterBlueBackground.startFlutterBackgroundService(() async {
//                         await FlutterBlueBackground.connectToDevice(
//                             deviceName: 'Project_RED_TTT',
//                             serviceUuid: 'f000c0c0-0451-4000-b000-000000000000',
//                             characteristicUuid: '0xF000C0C2-0451-B000-000000000000'
//                             // deviceName: 'BLE Device',
//                             // serviceUuid: '9999',
//                             // characteristicUuid: '9191'
//                         );
//
//                         // Write value on specific characteristic
//                         await FlutterBlueBackground.writeData(
//                             characteristicUuid: '0xF000C0C1-0451-B000-000000000000',
//                             // characteristicUuid: '9191',
//                             data: 'testing'
//                         );
//
//                         String? data = await FlutterBlueBackground.readData(
//                             characteristicUuid: '0xF000C0C2-0451-B000-000000000000'
//                             // characteristicUuid: '0xF000C0C0-0451-B000-000000000000'
//                         );
//                         // print('received value of read is $data');
//                       },);
//                     }
//
//                   },
//                   child: const Text('Start BG Android Service')
//               ),
//               const SizedBox(height: 20,),
//               const SizedBox(height: 20,),
//               ElevatedButton(
//                   onPressed: () async {
//                     await FlutterBlueBackground.stopFlutterBackgroundService();
//                   }, child: const Text('Start/Stop Service')
//               ),
//               // const SizedBox(height: 20,),
//               // ElevatedButton(
//               //     onPressed: () async {
//               //       // This method will get all the read data
//               //       await FlutterBlueBackground.getReadDataAndroid();
//               //     }, child: const Text('Get Read Data List')
//               // ),
//               const SizedBox(height: 20,),
//               // ElevatedButton(
//               //     onPressed: () async {
//               //       await FlutterBlueBackground.clearReadStorage();
//               //     }, child: const Text('Clear Read Data List')
//               // ),
//
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
// }
