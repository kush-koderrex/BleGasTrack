import 'dart:async';

import 'package:ble_service/logScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/scan_result_tile.dart';
import 'dart:developer' as developer;
import 'package:ble_service/utils/extra.dart';

// class ScanScreen extends StatefulWidget {
//   const ScanScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ScanScreen> createState() => _ScanScreenState();
// }
//
// class _ScanScreenState extends State<ScanScreen> {
//   List<BluetoothDevice> _systemDevices = [];
//   List<ScanResult> _scanResults = [];
//   bool _isScanning = false;
//   late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
//   late StreamSubscription<bool> _isScanningSubscription;
//   final TextEditingController _logController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//
//     _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
//       _scanResults = results;
//       if (mounted) {
//         setState(() {
//           _logController.text += "_scanResults ---->${_scanResults.toString()}\n";
//         });
//       }
//     }, onError: (e) {
//       developer.log("Scan Error: ${e.toString()}");
//     });
//
//     _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
//       _isScanning = state;
//       if (mounted) {
//         setState(() {});
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _scanResultsSubscription.cancel();
//     _isScanningSubscription.cancel();
//     _logController.dispose();
//     super.dispose();
//   }
//
//   Future onScanPressed() async {
//     try {
//       _systemDevices = await FlutterBluePlus.systemDevices;
//     } catch (e) {
//       developer.log("System Devices Error: ${e.toString()}");
//     }
//     try {
//       await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
//     } catch (e) {
//       developer.log("Start Scan Error: ${e.toString()}");
//     }
//     if (mounted) {
//       setState(() {});
//     }
//   }
//
//   Future onStopPressed() async {
//     try {
//       FlutterBluePlus.stopScan();
//     } catch (e) {
//       developer.log("Stop Scan Error: ${e.toString()}");
//     }
//   }
//
//   void onConnectPressed(BluetoothDevice device) {
//     device.connectAndUpdateStream().catchError((e) {
//       developer.log("Connect Error: ${e.toString()}");
//     });
//     MaterialPageRoute route = MaterialPageRoute(
//         builder: (context) => DeviceScreen(device: device), settings: RouteSettings(name: '/DeviceScreen'));
//     Navigator.of(context).push(route);
//   }
//
//   Future onRefresh() {
//     if (_isScanning == false) {
//       FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
//     }
//     if (mounted) {
//       setState(() {});
//     }
//     return Future.delayed(Duration(milliseconds: 500));
//   }
//
//   Widget buildScanButton(BuildContext context) {
//     if (FlutterBluePlus.isScanningNow) {
//       return FloatingActionButton(
//         child: const Icon(Icons.stop),
//         onPressed: onStopPressed,
//         backgroundColor: Colors.red,
//       );
//     } else {
//       return FloatingActionButton(child: const Text("SCAN"), onPressed: onScanPressed);
//     }
//   }
//
//   List<Widget> _buildSystemDeviceTiles(BuildContext context) {
//     return _systemDevices
//         .map(
//           (d) => ListTile(
//         title: Text(d.name),
//         subtitle: Text(d.id.toString()),
//         onTap: () => Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => DeviceScreen(device: d),
//             settings: RouteSettings(name: '/DeviceScreen'),
//           ),
//         ),
//       ),
//     )
//         .toList();
//   }
//
//   List<Widget> _buildScanResultTiles(BuildContext context) {
//     return _scanResults
//         .map(
//           (r) => ScanResultTile(
//         onTap: () {
//           developer.log("r.device: ${r.device}");
//           onConnectPressed(r.device);
//         },
//       ),
//     )
//         .toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     developer.log("_scanResults ---->${_scanResults.toString()}");
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Find Ble Device'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: RefreshIndicator(
//               onRefresh: onRefresh,
//               child: ListView(
//                 children: <Widget>[
//                   ..._buildScanResultTiles(context),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _logController,
//               maxLines: 10, // Adjust as needed
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Logs',
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: buildScanButton(context),
//     );
//   }
// }
//
// class DeviceScreen extends StatelessWidget {
//   final BluetoothDevice device;
//
//   const DeviceScreen({required this.device});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Device Details'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Device Name: ${device.name}'),
//             Text('Device ID: ${device.id}'),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'device_screen.dart';
import '../utils/snackbar.dart';
import '../widgets/system_device_tile.dart';
import '../widgets/scan_result_tile.dart';
import '../utils/extra.dart';
import 'dart:developer' as developer;
class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  Future onScanPressed() async {
    try {
      _systemDevices = await FlutterBluePlus.systemDevices;
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("System Devices Error:", e), success: false);
    }
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e), success: false);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e), success: false);
    }
  }

  void onConnectPressed(BluetoothDevice device) {
    device.connectAndUpdateStream().catchError((e) {
      Snackbar.show(ABC.c, prettyException("Connect Error:", e), success: false);
    });
    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => DeviceScreen(device: device), settings: const RouteSettings(name: '/DeviceScreen'));
    Navigator.of(context).push(route);
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(const Duration(milliseconds: 500));
  }

  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return FloatingActionButton(
        child: const Icon(Icons.stop),
        onPressed: onStopPressed,
        backgroundColor: Colors.red,
      );
    } else {
      return FloatingActionButton(child: const Text("SCAN"), onPressed: onScanPressed);
    }
  }

  List<Widget> _buildSystemDeviceTiles(BuildContext context) {
    return _systemDevices
        .map(
          (d) => SystemDeviceTile(
            device: d,
            onOpen: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DeviceScreen(device: d),
                settings: const RouteSettings(name: '/DeviceScreen'),
              ),
            ),
            onConnect: () => onConnectPressed(d),
          ),
        )
        .toList();
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            onTap: () {
              print("r.device");
              print(r.device);
              onConnectPressed(r.device);
            },
          ),
        )
        .toList();
  }
  Future<void> _removeLogs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('getReadData');
  }


  @override
  Widget build(BuildContext context) {
    // print("_scanResults");
    // developer.log("_scanResults ---->${_scanResults.toString()}");
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyB,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Find Ble Device'),
          actions: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.cleaning_services_rounded),
                  onPressed: (){
                    _removeLogs();

                  },
                ),
                IconButton(
                  icon: const Icon(Icons.document_scanner),
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LogScreen(),
                      ),
                    );
                  },
                ),

              ],
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            children: <Widget>[
              // ..._buildSystemDeviceTiles(context),
              ..._buildScanResultTiles(context),
            ],
          ),
        ),
        floatingActionButton: buildScanButton(context),
      ),
    );
  }
}
