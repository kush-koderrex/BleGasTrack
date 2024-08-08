import 'dart:async';

import 'package:ble_service/logScreen.dart';
import 'package:ble_service/permissions/bluetooth_adapter.dart';
import 'package:ble_service/permissions/check_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_background/flutter_blue_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GasBackgroudScreen extends StatefulWidget {
  final String deviceInfo;
  final String charUUID;
  final String serviceUUID;

  const GasBackgroudScreen({
    super.key,
    required this.deviceInfo,
    required this.charUUID,
    required this.serviceUUID,
  });

  @override
  State<GasBackgroudScreen> createState() => _GasBackgroudScreenState();
}

class _GasBackgroudScreenState extends State<GasBackgroudScreen> {
  late TextEditingController deviceInfoController;
  late TextEditingController serviceUUIDController;
  late TextEditingController charUUIDControllerSender;
  late TextEditingController charUUIDControllerReciver;
  String readData = "";
  bool isServiceRunning = true;
  String buttonText = 'Start Service';
  Color buttonColor = Colors.blue; // Initial button color

  @override
  void initState() {
    super.initState();
    deviceInfoController = TextEditingController(text: widget.deviceInfo);
    serviceUUIDController = TextEditingController(text: widget.serviceUUID);
    charUUIDControllerSender = TextEditingController(text: widget.charUUID);
    charUUIDControllerReciver = TextEditingController(text: widget.charUUID);
  }

  @override
  void dispose() {
    deviceInfoController.dispose();
    serviceUUIDController.dispose();
    charUUIDControllerSender.dispose();
    charUUIDControllerReciver.dispose();
    // _timer?.cancel();

    super.dispose();
  }

  Future<void> _removeLogs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('getReadData');
  }

  // Timer? _timer;

  Future<void> startBackgroundService() async {
    setState(() {
      isServiceRunning = true;
      buttonText = 'Background Service Initialized';
      buttonColor = Colors.green; // Change button color to green
    });

    // _timer = Timer.periodic(const Duration(seconds: 20), (timer) async {
    await FlutterBlueBackground.startFlutterBackgroundService(() async {
      // Initialize BLE state stream

      Timer.periodic(const Duration(seconds: 20), (timer) async {
        BluetoothAdapter.initBleStateStream();
        // Check permissions
        if (await PermissionEnable().check() == true) {
          await FlutterBlueBackground.connectToDevice(
            deviceName: deviceInfoController.text,
            serviceUuid: serviceUUIDController.text,
            characteristicUuid: charUUIDControllerSender.text,
          );
          // Write data
          await FlutterBlueBackground.writeData(
            characteristicUuid: charUUIDControllerSender.text,
            data: 'testing',
          );
          // Read data
          String? data = await FlutterBlueBackground.readData(
              characteristicUuid: charUUIDControllerReciver.text);
        }
      });
    });

    // print("Background Thread ------------------>");
    if (await PermissionEnable().check() == true) {
      await FlutterBlueBackground.writeData(
        characteristicUuid: charUUIDControllerSender.text,
        data: 'testing',
      );

      String? data = await FlutterBlueBackground.readData(
          characteristicUuid: charUUIDControllerReciver.text);

      // Update UI
      setState(() {
        readData = data ?? 'No data received';
      });
    }
    // await Future.delayed(Duration(seconds: 60));
    // print("Background Thread Stop------------------>");
    // await FlutterBlueBackground.stopFlutterBackgroundService();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gas Service Background"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: deviceInfoController,
                decoration: const InputDecoration(
                  labelText: 'Device Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: serviceUUIDController,
                decoration: const InputDecoration(
                  labelText: 'Service UUID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: charUUIDControllerSender,
                decoration: const InputDecoration(
                  labelText: 'Characteristic UUID (Send)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: charUUIDControllerReciver,
                decoration: const InputDecoration(
                  labelText: 'Characteristic UUID (Receive)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () async {
              //     BluetoothAdapter.initBleStateStream();
              //     if (await PermissionEnable().check() == true) {
              //       await FlutterBlueBackground.startFlutterBackgroundService(
              //         () async {
              //           await FlutterBlueBackground.connectToDevice(
              //             deviceName: deviceInfoController.text,
              //             serviceUuid: serviceUUIDController.text,
              //             characteristicUuid: charUUIDControllerSender.text,
              //           );
              //
              //           await FlutterBlueBackground.writeData(
              //             characteristicUuid: charUUIDControllerSender.text,
              //             data: 'testing',
              //           );
              //
              //           String? data = await FlutterBlueBackground.readData(
              //               characteristicUuid: charUUIDControllerReciver.text);
              //
              //           setState(() {
              //             readData = data ?? 'No data received';
              //             isServiceRunning = true;
              //             buttonText = 'Background Service Initialized';
              //             buttonColor =
              //                 Colors.green; // Change button color to green
              //           });
              //         },
              //       );
              //     }
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: buttonColor, // Set button color
              //   ),
              //   child: Text(buttonText),
              // ),
              ElevatedButton(
                onPressed: startBackgroundService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor, // Set button color
                ),
                child: Text(buttonText),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await FlutterBlueBackground.stopFlutterBackgroundService();
                  setState(() {
                    isServiceRunning = false;
                    buttonText = 'Start Service';
                    buttonColor = Colors.blue; // Reset button color to initial
                  });
                },
                child: const Text('Stop Service'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isServiceRunning
                    ? null
                    : () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LogScreen(),
                          ),
                        );
                      },
                child: const Text('Log Screen'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () async {
                    // This method will get all the read data
                    _removeLogs();
                    // await FlutterBlueBackground.getReadDataAndroid();
                  },
                  child: const Text('      Clear Logs     ')),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:ble_service/logScreen.dart';
// import 'package:ble_service/permissions/bluetooth_adapter.dart';
// import 'package:ble_service/permissions/check_status.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_background/flutter_blue_background.dart';
//
// class GasBackgroudScreen extends StatefulWidget {
//   final String deviceInfo;
//   final String charUUID;
//   final String serviceUUID;
//
//   const GasBackgroudScreen({
//     super.key,
//     required this.deviceInfo,
//     required this.charUUID,
//     required this.serviceUUID,
//   });
//
//   @override
//   State<GasBackgroudScreen> createState() => _GasBackgroudScreenState();
// }
//
// class _GasBackgroudScreenState extends State<GasBackgroudScreen> {
//   String readData = "";
//   bool isServiceRunning = true;
//   String buttonText = 'Start Service';
//   Color buttonColor = Colors.blue; // Initial button color
//
//   @override
//   Widget build(BuildContext context) {
//     print(widget.deviceInfo);
//     print(widget.serviceUUID);
//     print(widget.charUUID);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Gas Service Background"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text(
//               'Device Name: ${widget.deviceInfo}',
//               style: const TextStyle(fontSize: 16),
//             ),
//             Text(
//               'Service UUId: ${widget.serviceUUID}',
//               style: const TextStyle(fontSize: 16),
//             ),
//             Text(
//               'Character uuid: ${widget.charUUID}',
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 BluetoothAdapter.initBleStateStream();
//                 if (await PermissionEnable().check() == true) {
//                   await FlutterBlueBackground.startFlutterBackgroundService(
//                           () async {
//                         await FlutterBlueBackground.connectToDevice(
//                           deviceName: widget.deviceInfo,
//                           serviceUuid: widget.serviceUUID,
//                           characteristicUuid: widget.charUUID,
//                         );
//
//                         await FlutterBlueBackground.writeData(
//                           characteristicUuid: widget.charUUID,
//                           data: 'testing',
//                         );
//
//                         String? data = await FlutterBlueBackground.readData(
//                             characteristicUuid: widget.charUUID);
//
//                         setState(() {
//                           readData = data ?? 'No data received';
//                           isServiceRunning = true;
//                           buttonText = 'Background Service Initialized';
//                           buttonColor = Colors.green; // Change button color to green
//                         });
//                       });
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: buttonColor, // Set button color
//               ),
//               child: Text(buttonText),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 await FlutterBlueBackground.stopFlutterBackgroundService();
//                 setState(() {
//                   isServiceRunning = false;
//                   buttonText = 'Start Service';
//                   buttonColor = Colors.blue; // Reset button color to initial
//                 });
//               },
//               child: const Text('Stop Service'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: isServiceRunning
//                   ? null
//                   : () async {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => LogScreen(),
//                   ),
//                 );
//               },
//               child: const Text('Log Screen'),
//             ),
//             // ElevatedButton(
//             //   onPressed: () async {
//             //     Navigator.push(
//             //       context,
//             //       MaterialPageRoute(
//             //           builder: (context) => LogScreen(
//             //           )),
//             //     );
//             //   },
//             //   child: const Text('Log Screen'),
//             // ),
//             // Text(
//             //   'Read Data: $readData',
//             //   style: TextStyle(fontSize: 16),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//

// import 'package:ble_service/permissions/bluetooth_adapter.dart';
// import 'package:ble_service/permissions/check_status.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_background/flutter_blue_background.dart';
//
// class GasBackgroudScreen extends StatefulWidget {
//   final String deviceInfo;
//   final String charUUID;
//   final String serviceUUID;
//
//   const GasBackgroudScreen({
//     super.key,
//     required this.deviceInfo,
//     required this.charUUID,
//     required this.serviceUUID,
//   });
//
//   @override
//   State<GasBackgroudScreen> createState() => _GasBackgroudScreenState();
// }
//
// class _GasBackgroudScreenState extends State<GasBackgroudScreen> {
//   String readData = "";
//   bool isServiceRunning = false;
//   String buttonText = 'Start Service';
//
//   @override
//   Widget build(BuildContext context) {
//     print(widget.deviceInfo);
//     print(widget.serviceUUID);
//     print(widget.charUUID);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Gas Service Background"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text(
//               'Device Name: ${widget.deviceInfo}',
//               style: TextStyle(fontSize: 16),
//             ),
//             Text(
//               'Service UUId: ${widget.serviceUUID}',
//               style: TextStyle(fontSize: 16),
//             ),
//             Text(
//               'Character uuid: ${widget.charUUID}',
//               style: TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 BluetoothAdapter.initBleStateStream();
//                 if (await PermissionEnable().check() == true) {
//                   await FlutterBlueBackground.startFlutterBackgroundService(
//                           () async {
//                         await FlutterBlueBackground.connectToDevice(
//                             deviceName: widget.deviceInfo,
//                             serviceUuid: widget.serviceUUID,
//                             characteristicUuid: widget.charUUID
//
//                           // deviceName: 'BLE Device',
//                           // serviceUuid: '9999',
//                           // characteristicUuid: '9191'
//                           // deviceName: 'Ble',
//                           // serviceUuid: 'f000c0c0-0451-4000-b000-000000000000',
//                           // characteristicUuid: '0xF000C0C2-0451-B000-000000000000'
//                         );
//
//                         await FlutterBlueBackground.writeData(
//                           // characteristicUuid: '0xF000C0C1-0451-B000-000000000000',
//                             characteristicUuid: widget.charUUID,
//                             data: 'testing');
//
//                         String? data = await FlutterBlueBackground.readData(
//                             characteristicUuid: widget.charUUID);
//                         // characteristicUuid: '0xF000C0C2-0451-B000-000000000000');
//
//                         setState(() {
//                           readData = data ?? 'No data received';
//                           isServiceRunning = true;
//                           buttonText = 'Stop';
//                         });
//                       });
//                 }
//               },
//               child: Text(buttonText),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//                 onPressed: () async {
//                   await FlutterBlueBackground.stopFlutterBackgroundService();
//                 }, child: const Text('Stop Service')
//             ),
//             const SizedBox(height: 20),
//             // Text(
//             //   'Read Data: $readData',
//             //   style: TextStyle(fontSize: 16),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
