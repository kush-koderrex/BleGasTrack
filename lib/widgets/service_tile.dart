import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import "characteristic_tile.dart";

class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile({Key? key, required this.service, required this.characteristicTiles}) : super(key: key);

  // Widget buildUuid(BuildContext context) {
  //   String uuid = '0x${service.uuid.str.toUpperCase()}';
  //   return Text(uuid, style: TextStyle(fontSize: 13));
  // }

  String getServiceName(String uuid) {
    switch (uuid.toUpperCase()) {
      case '1800':
        return 'Generic Access Service (GAP)';
      case '1801':
        return 'Generic Attribute Service (GATT)';
      case '180F':
        return 'Battery Service';
      case '180D':
        return 'Heart Rate Service';
      case '1809':
        return 'Device Information Service';
      case '181A':
        return 'Environmental Sensing Service';
      case '1819':
        return 'Location and Navigation Service';
      case 'FF00':
        return 'OTA Update Service';
      case '180A':
        return 'SIG (Special Interest Group)';
      case 'FEE7':
        return 'Nordic UART Service (NUS)';
      default:
        return 'Unknown Service';
    }
  }



  Widget buildUuid(BuildContext context) {
    String uuid = '0x${service.uuid.str.toUpperCase()}';
    String serviceName = getServiceName(service.uuid.str.toUpperCase());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('UUID: $uuid', style: TextStyle(fontSize: 13)),
        Text('Service Name: $serviceName', style: TextStyle(fontSize: 13)),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    // print("characteristicTiles");
    // print(characteristicTiles);
    return characteristicTiles.isNotEmpty
        ? ExpansionTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Service', style: TextStyle(color: Colors.blue)),
                buildUuid(context),
              ],
            ),
            children: characteristicTiles,
          )
        : ListTile(
            title: const Text('Service'),
            subtitle: buildUuid(context),
          );

  }

  // Widget build(BuildContext context) {
  //   List<Widget> filteredTiles = characteristicTiles.where((tile) {
  //     String uuid = '0x${service.uuid.str.toUpperCase()}';
  //     return uuid.toString().contains('F000');'0xF000C0C0-0451-B000-000000000000';
  //   }).toList();
  //   print("characteristicTiles");
  //   print(characteristicTiles);
  //   return filteredTiles.isNotEmpty
  //       ? ExpansionTile(
  //     title: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: <Widget>[
  //         const Text('Service', style: TextStyle(color: Colors.blue)),
  //         buildUuid(context),
  //       ],
  //     ),
  //     children: characteristicTiles,
  //   )
  //       : SizedBox();
  //   // ListTile(
  //   //         title: const Text('Service'),
  //   //         subtitle: buildUuid(context),
  //   //       );
  // }
}



