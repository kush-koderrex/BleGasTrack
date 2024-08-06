import 'dart:async';
import 'dart:convert';

import 'package:ble_service/gasbBackground.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'package:flutter/services.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import "../utils/snackbar.dart";

import "descriptor_tile.dart";

class DeviceResponse {
  String deviceId;
  String reqCode;
  String dataLength;
  String beforeDecimal;
  String afterDecimal;
  String battery;
  bool buzzer;
  bool critical;
  String checksum;

  DeviceResponse({
    required this.deviceId,
    required this.reqCode,
    required this.dataLength,
    required this.beforeDecimal,
    required this.afterDecimal,
    required this.battery,
    required this.buzzer,
    required this.critical,
    required this.checksum,
  });

  @override
  String toString() {
    return 'DEVICE ID: $deviceId\n'
        'REQ_CODE: $reqCode\n'
        'DATA LENGTH: $dataLength\n'
        'WEIGHT: $beforeDecimal.$afterDecimal kg\n'
        'BATTERY: $battery%\n'
        'BUZZER: ${buzzer ? "off" : "on"}\n'
        'CRITICAL: ${critical ? "off" : "on"}\n'
        'CHECKSUM: $checksum\n';
  }
}

class ResetRequest {
  String deviceId;
  String reqCode;
  String dataLength;
  String checksum;
  String value;

  ResetRequest({
    required this.deviceId,
    required this.reqCode,
    required this.dataLength,
    required this.checksum,
    required this.value,
  });

  @override
  String toString() {
    return 'DEVICE ID: $deviceId\n'
        'REQ_CODE: $reqCode\n'
        'DATA LENGTH: $dataLength\n'
        'VALUE: $value\n'
        'CHECKSUM: $checksum\n';
  }
}

class VersionResponse {
  String deviceId;
  String reqCode;
  String dataLength;
  String value;
  String checksum;

  VersionResponse({
    required this.deviceId,
    required this.reqCode,
    required this.dataLength,
    required this.value,
    required this.checksum,
  });

  @override
  String toString() {
    return 'DEVICE ID: $deviceId\n'
        'REQ_CODE: $reqCode\n'
        'DATA LENGTH: $dataLength\n'
        'VALUE: $value\n'
        'CHECKSUM: $checksum\n';
  }
}

class CalibrationResponse {
  String deviceId;
  String reqCode;
  String dataLength;
  String value;
  String checksum;

  CalibrationResponse({
    required this.deviceId,
    required this.reqCode,
    required this.dataLength,
    required this.value,
    required this.checksum,
  });

  @override
  String toString() {
    return 'DEVICE ID: $deviceId\n'
        'REQ_CODE: $reqCode\n'
        'DATA LENGTH: $dataLength\n'
        'VALUE: $value\n'
        'CHECKSUM: $checksum\n';
  }
}

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;
  final String deviceName;


  const CharacteristicTile(
      {Key? key, required this.characteristic,required this.deviceName, required this.descriptorTiles})
      : super(key: key);

  @override
  State<CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  List<int> _value = [];

  final TextEditingController _textController = TextEditingController();

  late StreamSubscription<List<int>> _lastValueSubscription;

  bool isActive = false;

  @override
  void initState() {
    super.initState();
    _lastValueSubscription =
        widget.characteristic.lastValueStream.listen((value) {
      _value = value;
      if (mounted) {
        setState(() {});
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      // onSubscribePressedcustok();
      _autoSubscribe();
    });
  }

  Future<void> _autoSubscribe() async {
    if (!widget.characteristic.isNotifying) {
      await onSubscribePressed();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _lastValueSubscription.cancel();
    super.dispose();

    _textController.dispose();
    super.dispose();
  }

  BluetoothCharacteristic get c => widget.characteristic;

  Future onReadPressed() async {
    try {
      await c.read();
      Snackbar.show(ABC.c, "Read: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Read Error:", e), success: false);
    }
  }

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Text'),
          content: TextField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            controller: _textController,
            decoration: const InputDecoration(hintText: 'Enter text here...'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                setState(() {
                  isActive = true;
                });

                // Do something with the entered tex
                // onWritePressed();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String stringToHex(String text) {
    List<int> bytes = utf8.encode(text); // Convert text to UTF-8 bytes
    String hexString =
        bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
    return hexString;
  }

  String hexToString(String hex) {
    List<int> bytes = [];
    for (int i = 0; i < hex.length; i += 2) {
      String byteString = hex.substring(i, i + 2);
      int byteValue = int.parse(byteString, radix: 16);
      bytes.add(byteValue);
    }
    return const Utf8Decoder(allowMalformed: true).convert(bytes);
  }

  List<int> hexToDecimal(String hexString) {
    List<int> bytes = [];
    for (int i = 0; i < hexString.length; i += 2) {
      String hex = hexString.substring(i, i + 2);
      int byte = int.parse(hex, radix: 16);
      bytes.add(byte);
    }
    return bytes;
  }

  Future onWritePressed() async {
    String TextData = _textController.text;
    String hexString = stringToHex(TextData);
    print("Hexadecimal representation of '$TextData': $hexString");
    // Convert hex string to decimal list
    List<int> decimalList = hexToDecimal(hexString);
    print("decimalList");
    print(decimalList);
    // return decimalList;
    try {
      await c.write(decimalList,
          withoutResponse: c.properties.writeWithoutResponse);
      // await c.write([0xa, 0x1, 0x2, 0x3c, 0x1, 0x37, 0xaa, 0x37], withoutResponse: c.properties.writeWithoutResponse);
      Snackbar.show(ABC.c, "Write: Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }

  Future onWritePressedgenreq() async {
    try {
      await c.write([0x40, 0xA8, 0x00, 0x01, 0x01, 0x01, 0xAA, 0x55],
          withoutResponse: c.properties.writeWithoutResponse,
          allowLongWrite: true);
      // await c.write([0xa, 0x1, 0x2, 0x3c, 0x1, 0x37, 0xaa, 0x37], withoutResponse: c.properties.writeWithoutResponse);
      Snackbar.show(ABC.c, "Write: Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }

  Future onWritePressedresretreq() async {
    try {
      await c.write([0x40, 0xA8, 0x00, 0x00, 0x01, 0x01, 0xAA, 0x55],
          // [52, 48, 65, 56, 48, 53, 48, 48, 48, 49, 48, 49, 65, 65, 53, 53],
          withoutResponse: c.properties.writeWithoutResponse,
          allowLongWrite: true);
      // await c.write([0xa, 0x1, 0x2, 0x3c, 0x1, 0x37, 0xaa, 0x37], withoutResponse: c.properties.writeWithoutResponse);
      Snackbar.show(ABC.c, "Write: Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }

  Future onWritePressedBuzzerON() async {
    try {
      await c.write([0x40, 0xA8, 0x00, 0x10, 0x01, 0x01, 0xAA, 0x55],
          // [52, 48, 65, 56, 48, 53, 49, 48, 48, 49, 48, 49, 65, 65, 53, 53],
          withoutResponse: c.properties.writeWithoutResponse,
          allowLongWrite: true);
      // await c.write([0xa, 0x1, 0x2, 0x3c, 0x1, 0x37, 0xaa, 0x37], withoutResponse: c.properties.writeWithoutResponse);
      Snackbar.show(ABC.c, "Write: Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }

  Future onWritePressedBuzzerOFF() async {
    try {
      await c.write([0x40, 0xA8, 0x00, 0x10, 0x01, 0x00, 0xAA, 0x55],
          withoutResponse: c.properties.writeWithoutResponse,
          allowLongWrite: true);
      // await c.write([0xa, 0x1, 0x2, 0x3c, 0x1, 0x37, 0xaa, 0x37], withoutResponse: c.properties.writeWithoutResponse);
      Snackbar.show(ABC.c, "Write: Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }

  Future onWritePressedLEDON() async {
    try {
      await c.write([0x40, 0xA8, 0x00, 0x20, 0x01, 0x01, 0xAA, 0x55],
          // [52, 48, 65, 56, 48, 53, 50, 48, 48, 49, 48, 49, 65, 65, 53, 53],
          withoutResponse: c.properties.writeWithoutResponse,
          allowLongWrite: true);
      // await c.write([0xa, 0x1, 0x2, 0x3c, 0x1, 0x37, 0xaa, 0x37], withoutResponse: c.properties.writeWithoutResponse);
      Snackbar.show(ABC.c, "Write: Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }

  Future onWritePressedLEDOFF() async {
    try {
      await c.write([0x40, 0xA8, 0x00, 0x20, 0x01, 0x00, 0xAA, 0x55],
          withoutResponse: c.properties.writeWithoutResponse,
          allowLongWrite: true);
      // await c.write([0xa, 0x1, 0x2, 0x3c, 0x1, 0x37, 0xaa, 0x37], withoutResponse: c.properties.writeWithoutResponse);
      Snackbar.show(ABC.c, "Write: Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }

  Future onWritePressedVersion() async {
    try {
      await c.write([0x40, 0xA8, 0x00, 0x30, 0x01, 0x01, 0xAA, 0x55],
          // [52, 48, 65, 56, 48, 53, 51, 48, 48, 49, 48, 49, 65, 65, 53, 53],
          withoutResponse: c.properties.writeWithoutResponse,
          allowLongWrite: true);
      // await c.write([0xa, 0x1, 0x2, 0x3c, 0x1, 0x37, 0xaa, 0x37], withoutResponse: c.properties.writeWithoutResponse);
      Snackbar.show(ABC.c, "Write: Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }

  Future onWritePressedTare() async {
    try {
      await c.write([0x40, 0xA8, 0x00, 0x40, 0x02, 0x00, 0x00, 0xAA, 0x55],
          // [52, 48, 65, 56, 48, 53, 51, 48, 48, 49, 48, 49, 65, 65, 53, 53],
          withoutResponse: c.properties.writeWithoutResponse,
          allowLongWrite: true);
      // await c.write([0xa, 0x1, 0x2, 0x3c, 0x1, 0x37, 0xaa, 0x37], withoutResponse: c.properties.writeWithoutResponse);
      Snackbar.show(ABC.c, "Write: Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }

  String stringToHextest(String input) {
    List<String> hexList = [];
    for (int i = 0; i < input.length; i++) {
      hexList.add(input.codeUnitAt(i).toRadixString(16).padLeft(2, '0'));
    }
    return hexList.join();
  }

  String decimalToHex(int decimal) {
    return decimal.toRadixString(16).toUpperCase();
  }

  Future onWritePressedCalibrate() async {
    String TextData = _textController.text;
    String hexString = stringToHex(TextData);
    print("Hexadecimal representation of '$TextData': $hexString");
    int decimalValue1 = int.parse(TextData.substring(0, 2));
    int decimalValue2 = int.parse(TextData.substring(2, 4));
    print("decimalValue1");
    print(decimalValue1);
    print(decimalValue2);
    String hexValue1 = decimalToHex(decimalValue1);
    String hexValue2 = decimalToHex(decimalValue2);
    // print('DECIMAL: $decimalValue'); // Output: DECIMAL: 89
    print('0x$hexValue1'); // Output: HEX: 0x59
    print('0x$hexValue2'); // Output: HEX: 0x59

    List<int> decimalList = hexToDecimal(hexString);
    print("decimalList");

    print([0x40, 0xA8, 0x00, 0x40, 0x02, hexValue1, hexValue2, 0xAA, 0x55]);
    try {
      await c.write([
        0x40,
        0xA8,
        0x00,
        0x40,
        0x02,
        int.parse('0x$hexValue1'),
        int.parse('0x$hexValue2'),
        0xAA,
        0x55
      ],
          // [52, 48, 65, 56, 48, 53, 51, 48, 48, 49, 48, 49, 65, 65, 53, 53],
          withoutResponse: c.properties.writeWithoutResponse,
          allowLongWrite: true);

      // await c.write([0xa, 0x1, 0x2, 0x3c, 0x1, 0x37, 0xaa, 0x37], withoutResponse: c.properties.writeWithoutResponse);
      Snackbar.show(ABC.c, "Write: Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
    setState(() {
      isActive = false;
    });
  }

  Future onSubscribePressed() async {
    try {
      String op = c.isNotifying == false ? "Subscribe" : "Unubscribe";
      await c.setNotifyValue(c.isNotifying == false);
      Snackbar.show(ABC.c, "$op : Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Subscribe Error:", e),
          success: false);
    }
  }

  Widget buildUuid(BuildContext context) {
    String uuid = '0x${widget.characteristic.uuid.str.toUpperCase()}';
    return Text(uuid, style: const TextStyle(fontSize: 13));
  }

  String hexToAscii(String hexString) {
    // Check if the hexString length is even
    if (hexString.length % 2 != 0) {
      throw ArgumentError('Invalid hex string');
    }

    // Convert each pair of hexadecimal characters to its decimal equivalent
    List<int> byteValues = [];
    for (int i = 0; i < hexString.length; i += 2) {
      String hex = hexString.substring(i, i + 2);
      byteValues.add(int.parse(hex, radix: 16));
    }

    // Convert byte values to ASCII characters
    return String.fromCharCodes(byteValues);
  }

  Widget buildValue(BuildContext context) {
    String data = _value.toString();

    List<String> hexList = _value
        .map((decimal) => decimal.toRadixString(16).padLeft(2, '0'))
        .toList();
    String hexString = hexList.join('');
    var asciiData = hexToAscii(hexString.toUpperCase());
    // print(_value);
    // print(_value[0]);
    // print(_value.runtimeType);
    // print("data");
    // print(data[1]);
    // print(data.runtimeType);
    // print(hexString);
    // print(asciiData);

    // String response = hexString.toUpperCase();
    // DeviceResponse? parsedResponse = parseDeviceResponse(response);
    // if (parsedResponse != null) {
    //   print("parsedResponse");
    //   print(parsedResponse);
    // } else {
    //   print('Failed to parse response.');
    // }

    // double batlev = _value[0] ?? 0.0;
    // num batlev = _value[0] ?? 0.0;
    // num batlev = _value.isNotEmpty ? _value[0] : 0.0;
    // print("batlev");
    // print(batlev);

    // Map<String, String> parseData(String input) {
    //   List<String> dataList = input.split('23');
    //   Map<String, String> parsedData = {
    //     "DEVICE ID": dataList.length > 0 ? dataList[0] : '',
    //     "WEIGHT": dataList.length > 1 ? dataList[1] : '',
    //     "BATTERY": dataList.length > 2 ? dataList[2] : '',
    //     "BUZZER": dataList.length > 3 ? dataList[3] : '',
    //     "CRITICAL": dataList.length > 4 ? dataList[4] : '',
    //     "CHECKSUM": dataList.length > 5 ? dataList[5] : '',
    //   };
    //   return parsedData;
    // }

    // Map<String, String> parsedData = parseData(hexString);

    DeviceResponse? _deviceResponse;

    // _onParseButtonClick() {
    //   String response = hexString;
    //   // String response = "40A80501051825860100AA55";
    //   setState(() {
    //     _deviceResponse = parseDeviceResponse(response);
    //     print("_deviceResponse");
    //     print(_deviceResponse);
    //   });
    // }

    _onParseButtonClick() {
      String response = hexString;
      setState(() {
        _deviceResponse = parseDeviceResponse(response);
        // print("_deviceResponse");
        // print(_deviceResponse);
        // Show notification if critical is true
        if (_deviceResponse != null && _deviceResponse!.critical == false) {
          // _showNotification();
        }
      });
    }

    _onParseButtonClick();

    ResetRequest? _resetRequest;

    _onParseButtonresterClick() {
      String resetresponse = hexString.toUpperCase();
      setState(() {
        _resetRequest = parseResetRequest(resetresponse);
        // print("_resetRequest");
        // print(_resetRequest);
      });
    }

    _onParseButtonresterClick();

    VersionResponse? _versionRequest;

    _onParseButtonversionClick() {
      String versionresponse = hexString.toUpperCase();
      setState(() {
        _versionRequest = parseversionRequest(versionresponse);
        // print("_versionRequest");
        // print(_versionRequest);
      });
    }

    _onParseButtonversionClick();

    CalibrationResponse? _calRequest;

    _onParseButtonCalClick() {
      String calresponse = hexString.toUpperCase();
      setState(() {
        _calRequest = parseCalibrate(calresponse);
        // print("calresponse");
        // print(calresponse);
      });
    }

    _onParseButtonCalClick();

    // int hexToDec(String hexString) {
    //   // Input validation (optional but recommended)
    //   if (hexString.isEmpty || hexString.length != 6 && hexString.length != 8) {
    //     throw ArgumentError("Invalid hex string format");
    //   }
    //
    //   // Remove leading "#" if present
    //   hexString = hexString.replaceAll("#", "");
    //
    //   // Convert to integer value in base 16 (hexadecimal)
    //   return int.parse(hexString, radix: 16);
    // }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Raw data (Decimal Form)",
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            Text(data, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
        Row(
          children: [
            const Text("hex String :- ",
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            Text(hexString, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
        // Row(
        //   children: [
        //     Text("Ascii Data :- ",
        //         style: TextStyle(fontSize: 13, color: Colors.grey)),
        //     Text(asciiData.toUpperCase(),
        //         style: TextStyle(fontSize: 13, color: Colors.red)),
        //   ],
        // ),
        // Row(
        //   children: [
        //     Text("Hex to stirng  :- ",
        //         style: TextStyle(fontSize: 13, color: Colors.grey)),
        //     Text(hexToString(hexString),
        //         style: TextStyle(fontSize: 13, color: Colors.red)),
        //   ],
        // ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ElevatedButton(
            //   onPressed: _onParseButtonClick(),
            //   child: Text('Parse Device Response'),
            // ),
            const SizedBox(height: 20),
            if (_deviceResponse != null &&
                _deviceResponse!.reqCode == "01") ...[
              const Text('General Response:'),
              Text('DEVICE ID: ${_deviceResponse!.deviceId}'),
              Text('REQ_CODE: ${_deviceResponse!.reqCode}'),
              Text('DATA LENGTH: ${_deviceResponse!.dataLength}'),
              Text(
                  'WEIGHT: ${int.parse(_deviceResponse!.beforeDecimal.replaceAll("#", ""), radix: 16).toString()}.${int.parse(_deviceResponse!.afterDecimal.replaceAll("#", ""), radix: 16).toString()} kg'),
              Text(
                  'BATTERY: ${int.parse(_deviceResponse!.battery.replaceAll("#", ""), radix: 16)}%'),
              Text('BUZZER: ${_deviceResponse!.buzzer ? "off" : "on"}'),
              Text('CRITICAL: ${_deviceResponse!.critical ? "off" : "on"}'),
              Text('CHECKSUM: ${_deviceResponse!.checksum}'),
            ] else ...[
              const SizedBox(),
              // Text('No response parsed.'),
            ],
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_resetRequest != null &&
                    _resetRequest!.reqCode == "00") ...[
                  const Text('Reset Response:'),
                  Text('DEVICE ID: ${_resetRequest!.deviceId}'),
                  Text('REQ_CODE: ${_resetRequest!.reqCode}'),
                  Text('DATA LENGTH: ${_resetRequest!.dataLength}'),
                  Text('VALUE: ${_resetRequest!.value}'),
                  Text('CHECKSUM: ${_resetRequest!.checksum}'),
                ],
                if (_deviceResponse == null && _resetRequest == null) ...[
                  const SizedBox(),
                ],
                const SizedBox(height: 20),
                // if (_resetRequest != null) ...[
                //   Text('DEVICE ID: ${_resetRequest!.deviceId}'),
                //   Text('REQ_CODE: ${_resetRequest!.reqCode}'),
                //   Text('DATA LENGTH: ${_resetRequest!.dataLength}'),
                //   Text('CHECKSUM: ${_resetRequest!.checksum}'),
                // ] else ...[
                //   SizedBox(),
                // ],
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_versionRequest != null &&
                    _versionRequest!.reqCode == "30") ...[
                  const Text('Version Response:'),
                  Text('DEVICE ID: ${_versionRequest!.deviceId}'),
                  Text('REQ_CODE: ${_versionRequest!.reqCode}'),
                  Text('DATA LENGTH: ${_versionRequest!.dataLength}'),
                  Text('VALUE: ${_versionRequest!.value}'),
                  Text(
                      'S/W Version: ${_versionRequest!.value.toString().substring(0, 2)}.${_versionRequest!.value.toString().substring(2, 4)}'),
                  Text(
                      'H/W Version : ${_versionRequest!.value.toString().substring(4, 6)}.${_versionRequest!.value.toString().substring(6, 8)}'),
                  Text('CHECKSUM: ${_versionRequest!.checksum}'),
                ],
                if (_deviceResponse == null &&
                    _resetRequest == null &&
                    _versionRequest == null) ...[
                  const SizedBox(),
                ],
                const SizedBox(height: 20),
                // if (_resetRequest != null) ...[
                //   Text('DEVICE ID: ${_resetRequest!.deviceId}'),
                //   Text('REQ_CODE: ${_resetRequest!.reqCode}'),
                //   Text('DATA LENGTH: ${_resetRequest!.dataLength}'),
                //   Text('CHECKSUM: ${_resetRequest!.checksum}'),
                // ] else ...[
                //   SizedBox(),
                // ],
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_calRequest != null && _calRequest!.reqCode == "40") ...[
                  const Text('Calibration Response:'),
                  Text('DEVICE ID: ${_calRequest!.deviceId}'),
                  Text('REQ_CODE: ${_calRequest!.reqCode}'),
                  Text('DATA LENGTH: ${_calRequest!.dataLength}'),
                  Text('VALUE: ${_calRequest!.value}'),
                  Text('CHECKSUM: ${_calRequest!.checksum}'),
                ],
                if (_deviceResponse == null &&
                    _resetRequest == null &&
                    _versionRequest == null) ...[
                  const SizedBox(),
                ],
                const SizedBox(height: 20),
                // if (_resetRequest != null) ...[
                //   Text('DEVICE ID: ${_resetRequest!.deviceId}'),
                //   Text('REQ_CODE: ${_resetRequest!.reqCode}'),
                //   Text('DATA LENGTH: ${_resetRequest!.dataLength}'),
                //   Text('CHECKSUM: ${_resetRequest!.checksum}'),
                // ] else ...[
                //   SizedBox(),
                // ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget buildReadButton(BuildContext context) {
    return TextButton(
        child: const Text("Read"),
        onPressed: () async {
          await onReadPressed();
          if (mounted) {
            setState(() {});
          }
        });
  }

  Widget buildWriteButton(BuildContext context) {
    bool withoutResp = widget.characteristic.properties.writeWithoutResponse;
    return TextButton(
        child: Text(withoutResp ? "WriteNoResp" : "Write"),
        onPressed: () async {
          await onWritePressed();
          if (mounted) {
            setState(() {});
          }
        });
  }

  Widget buildSubscribeButton(BuildContext context) {
    bool isNotifying = widget.characteristic.isNotifying;
    return TextButton(
        child: Text(isNotifying ? "Unsubscribe" : "Subscribe"),
        onPressed: () async {
          await onSubscribePressed();
          if (mounted) {
            setState(() {});
          }
        });
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Critical Alert',
      'Please check your device',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Widget buildButtonRow(BuildContext context) {
    bool read = widget.characteristic.properties.read;
    bool write = widget.characteristic.properties.write;
    bool notify = widget.characteristic.properties.notify;
    bool indicate = widget.characteristic.properties.indicate;
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container(
            //   width: 80.0,
            //   height: 15.0,
            //   decoration: BoxDecoration(
            //     border: Border.all(color: Colors.black),
            //     borderRadius: BorderRadius.circular(10.0),
            //   ),
            //   child: Stack(
            //     children: <Widget>[
            //       Container(
            //         width: 50 * _batteryLevel,
            //         height: 25.0,
            //         decoration: BoxDecoration(
            //           color: _getColorForBatteryLevel(),
            //           borderRadius: BorderRadius.circular(10.0),
            //         ),
            //       ),
            //       Positioned.fill(
            //         child: Align(
            //           alignment: Alignment.center,
            //           child: Text(
            //             '${(_batteryLevel * 100).toStringAsFixed(0)}%',
            //             style: TextStyle(fontSize: 8.0),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            if (read) buildReadButton(context),
            if (write) buildWriteButton(context),
            if (notify || indicate) buildSubscribeButton(context),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container(
            //   width: 80.0,
            //   height: 15.0,
            //   decoration: BoxDecoration(
            //     border: Border.all(color: Colors.black),
            //     borderRadius: BorderRadius.circular(10.0),
            //   ),
            //   child: Stack(
            //     children: <Widget>[
            //       Container(
            //         width: 50 * _batteryLevel,
            //         height: 25.0,
            //         decoration: BoxDecoration(
            //           color: _getColorForBatteryLevel(),
            //           borderRadius: BorderRadius.circular(10.0),
            //         ),
            //       ),
            //       Positioned.fill(
            //         child: Align(
            //           alignment: Alignment.center,
            //           child: Text(
            //             '${(_batteryLevel * 100).toStringAsFixed(0)}%',
            //             style: TextStyle(fontSize: 8.0),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            TextButton(
                child: const Text("Enter Text"),
                onPressed: () {
                  _showPopup(context);
                }),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        Row(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
                child: const Text("GEN REQ"),
                onPressed: () {
                  onWritePressedgenreq();
                }),
            const SizedBox(
              width: 10,
            ),
            ElevatedButton(
                child: const Text("RESET REQ"),
                onPressed: () {
                  onWritePressedresretreq();
                }),
          ],
        ),
        Row(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
                child: const Text("BUZZER ON"),
                onPressed: () {
                  onWritePressedBuzzerON();
                }),
            const SizedBox(
              width: 10,
            ),
            ElevatedButton(
                child: const Text("BUZZER OFF"),
                onPressed: () {
                  onWritePressedBuzzerOFF();
                }),
          ],
        ),
        Row(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
                child: const Text("LED ON"),
                onPressed: () {
                  onWritePressedLEDON();
                }),
            const SizedBox(
              width: 10,
            ),
            ElevatedButton(
                child: const Text("LED OFF"),
                onPressed: () {
                  onWritePressedLEDOFF();
                }),
          ],
        ),
        Row(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
                child: const Text("VERSION REQ"),
                onPressed: () {
                  onWritePressedVersion();
                }),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        Row(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
                child: const Text("TARE ZERO"),
                onPressed: () {
                  onWritePressedTare();
                }),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        Row(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
                child: const Text("Enter Custom val"),
                onPressed: () {
                  _showPopup(context);
                }),
            const SizedBox(
              width: 10,
            ),
            ElevatedButton(
              child: const Text("CALIBRATE"),
              onPressed: isActive
                  ? () {
                      onWritePressedCalibrate();
                    }
                  : null,
              // onPressed: () {
              //   addNewFloor();
              // },
              // onPressed: () {
              //   onWritePressedCalibrate();
            ),
          ],
        ),
        ElevatedButton(
            child: const Text("Background Process"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GasBackgroudScreen(
                          deviceInfo: widget.deviceName,
                          charUUID: widget.characteristic.characteristicUuid
                              .toString(),
                          serviceUUID:
                              widget.characteristic.serviceUuid.toString(),
                        )),
              );
            }),
        SizedBox(height: 50,),
      ],
    );
  }

  // kush code for test

  DeviceResponse? parseDeviceResponse(String response) {
    // Ensure the response is in uppercase
    response = response.toUpperCase();

    // Expected response length is 24 hex digits
    if (response.length != 24) {
      // print('Invalid response length: ${response.length}');
      return null;
    }

    try {
      // Parsing the response
      String deviceId = response.substring(0, 6); // 3 bytes -> 6 hex digits
      String reqCode = response.substring(6, 8); // 1 byte -> 2 hex digits
      String dataLength = response.substring(8, 10); // 1 byte -> 2 hex digits

      String beforeDecimal = response.substring(10, 12);
      String afterDecimal = response.substring(12, 14);
      String battery = response.substring(14, 16);
      bool buzzer = response.substring(16, 18) == '00';
      bool critical = response.substring(18, 20) == '00';
      String checksum = response.substring(20, 24); // 2 bytes -> 4 hex digits

      return DeviceResponse(
        deviceId: deviceId,
        reqCode: reqCode,
        dataLength: dataLength,
        beforeDecimal: beforeDecimal,
        afterDecimal: afterDecimal,
        battery: battery,
        buzzer: buzzer,
        critical: critical,
        checksum: checksum,
      );
    } catch (e) {
      print('Error parsing response: $e');
      return null;
    }
  }

  // kush code for test rest
  ResetRequest? parseResetRequest(String request) {
    // Ensure the request is in uppercase
    request = request.toUpperCase();
    // print("request.length");
    // print(request.length);

    // Expected request length is 8 hex digits
    if (request.length != 17) {
      // print('Invalid request length: ${request.length}');
      return null;
    }

    try {
      // Parsing the request
      String deviceId = request.substring(0, 6); // 3 bytes -> 6 hex digits
      String reqCode = request.substring(6, 8); // 1 byte -> 2 hex digits
      String dataLength = request.substring(8, 10); // No data for RESET request
      String value = request.substring(10, 13); // No data for RESET request
      String checksum = request.substring(13, 17); // 2 bytes -> 4 hex digits

      return ResetRequest(
        deviceId: deviceId,
        reqCode: reqCode,
        dataLength: dataLength,
        value: value,
        checksum: checksum,
      );
    } catch (e) {
      print('Error parsing request: $e');
      return null;
    }
  }

  // kush code for test rest

  // kush code for test version
  VersionResponse? parseversionRequest(String verrequest) {
    // Ensure the request is in uppercase
    verrequest = verrequest.toUpperCase();
    // print("request.length");
    // print(verrequest.length);

    // Expected request length is 8 hex digits
    if (verrequest.length != 22) {
      // print('Invalid request length: ${verrequest.length}');
      return null;
    }

    try {
      // Parsing the request
      String deviceId = verrequest.substring(0, 6); // 3 bytes -> 6 hex digits
      String reqCode = verrequest.substring(6, 8); // 1 byte -> 2 hex digits
      String dataLength =
          verrequest.substring(8, 10); // No data for RESET request
      String value = verrequest.substring(10, 18); // No data for RESET request
      String checksum = verrequest.substring(18, 22); // 2 bytes -> 4 hex digits

      return VersionResponse(
        deviceId: deviceId,
        reqCode: reqCode,
        dataLength: dataLength,
        value: value,
        checksum: checksum,
      );
    } catch (e) {
      print('Error parsing request: $e');
      return null;
    }
  }

  // kush code for test version

  // kush code for test version
  CalibrationResponse? parseCalibrate(String Calrequest) {
    // Ensure the request is in uppercase
    Calrequest = Calrequest.toUpperCase();
    // print("request.length cal");
    // print(Calrequest.length);

    // Expected request length is 8 hex digits
    if (Calrequest.length != 18) {
      // print('Invalid request length: ${Calrequest.length}');
      return null;
    }

    try {
      // Parsing the request
      String deviceId = Calrequest.substring(0, 6); // 3 bytes -> 6 hex digits
      String reqCode = Calrequest.substring(6, 8); // 1 byte -> 2 hex digits
      String dataLength =
          Calrequest.substring(8, 10); // No data for RESET request
      String value = Calrequest.substring(10, 14); // No data for RESET request
      String checksum = Calrequest.substring(14, 18); // 2 bytes -> 4 hex digits

      return CalibrationResponse(
        deviceId: deviceId,
        reqCode: reqCode,
        dataLength: dataLength,
        value: value,
        checksum: checksum,
      );
    } catch (e) {
      print('Error parsing request: $e');
      return null;
    }
  }

  // kush code for test version

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: ListTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Characteristic'),
            buildUuid(context),
            buildValue(context),
          ],
        ),
        subtitle: buildButtonRow(context),
        contentPadding: const EdgeInsets.all(0.0),
      ),
      children: widget.descriptorTiles,
    );
  }
  // Color _getColorForBatteryLevel() {
  //   if (_batteryLevel >= 0.6) {
  //     return Colors.green;
  //   } else if (_batteryLevel >= 0.3) {
  //     return Colors.yellow;
  //   } else {
  //     return Colors.red;
  //   }
  // }
}
