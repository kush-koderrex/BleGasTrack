// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class LogScreen extends StatefulWidget {
//   @override
//   _LogScreenState createState() => _LogScreenState();
// }
//
// class _LogScreenState extends State<LogScreen> {
//   List<String> logs = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadLogs();
//   }
//
//   Future<void> _loadLogs() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     await preferences.reload();
//     setState(() {
//       logs = preferences.getStringList('getReadData') ?? <String>[];
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Logs'),
//       ),
//       body: ListView.builder(
//         itemCount: logs.length,
//         itemBuilder: (context, index) {
//           String log = logs[index];
//           String timestamp = log.substring(0, 26); // Extract timestamp
//           String response = log.substring(29); // Extract response data
//
//           bool isAlert = response.contains('40a80501051825860100aa55');
//
//           // Extracting the data components
//           String deviceId = response.substring(0, 6); // 3 bytes -> 6 hex digits
//           String reqCode = response.substring(6, 8); // 1 byte -> 2 hex digits
//           String dataLength = response.substring(8, 10); // 1 byte -> 2 hex digits
//           String beforeDecimal = response.substring(10, 12);
//           String afterDecimal = response.substring(12, 14);
//           String battery = response.substring(14, 16);
//           bool buzzer = response.substring(16, 18) == '00';
//           bool critical = response.substring(18, 20) == '00';
//           String checksum = response.substring(20, 24); // 2 bytes -> 4 hex digits
//
//           return ListTile(
//             title: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   timestamp,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   response,
//                   style: TextStyle(
//                     color: isAlert ? Colors.red : Colors.black,
//                   ),
//                 ),
//                 Text('Device ID: $deviceId'),
//                 Text('Req Code: $reqCode'),
//                 Text('Data Length: $dataLength'),
//                 Text('Before Decimal: $beforeDecimal'),
//                 Text('After Decimal: $afterDecimal'),
//                 Text('Battery: $battery'),
//                 Text('Buzzer: $buzzer'),
//                 Text('Critical: $critical'),
//                 Text('Checksum: $checksum'),
//               ],
//             ),
//             trailing: isAlert ? Text('Alert', style: TextStyle(color: Colors.red)) : null,
//           );
//         },
//       ),
//     );
//   }
// }
//


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    setState(() {
      logs = preferences.getStringList('getReadData') ?? <String>[];
    });
  }


  Future<void> _removeLogs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('getReadData');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs'),
        actions: [

        ],
      ),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(logs[index]),
          );
        },
      ),
    );
  }
}

