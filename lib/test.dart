import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Gas Tracker',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  Timer.periodic(const Duration(seconds: 2), (timer) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();

    // For flutter prior to version 3.0.0
    // We have to register the plugin manually

    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // await preferences.setString("hello", "world");

    /// OPTIONAL when use custom notification
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // Variables Using in Bluetooth Functionality
    List<BluetoothDevice> scannedDevicesList = <BluetoothDevice>[];
    StreamSubscription? streamSubscription;
    BluetoothDevice? gBleDevice;
    // List<ServicesModel> servicesList = [];
    List<BluetoothService> gBleServices = <BluetoothService>[];
    StreamSubscription? subscription;
    StreamSubscription? subscriptionConnection;
    List<String> receivedDataList = <String>[];
    String deviceName = "";
    String serviceUuid = "";
    String sendCharacteristicUuid = "";
    String receiveCharacteristicUuid = "";
    String dataForWrite = "";
    List<int> readValue = [];

    String datafornotification = '';

    SharedPreferences getMethodsCall = await SharedPreferences.getInstance();
    await getMethodsCall.reload();

    // This is getting values for scanning and connecting of specific device
    final connectToDevice =
        getMethodsCall.getStringList('connectToDevice') ?? <String>[];
    deviceName = connectToDevice[1];
    serviceUuid = connectToDevice[2];

    // This is getting values to write value on specific device
    final writeData = getMethodsCall.getStringList('writeData') ?? <String>[];
    if (writeData.isNotEmpty) {
      sendCharacteristicUuid = writeData[1];
      dataForWrite = writeData[2];
    }

    // This is getting values to read value on specific device
    final readData = getMethodsCall.getStringList('readData') ?? <String>[];
    if (readData.isNotEmpty) {
      receiveCharacteristicUuid = readData[1];
    }

    // writeCharacteristic will write value on specific characteristic

    // Timer.periodic(Duration(seconds: 10), (Timer timer) {
    void writeCharacteristic(String command) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.reload();

      final log = preferences.getStringList('getReadData') ?? <String>[];

      for (var serv in gBleServices) {
        if (serv.uuid.toString() == serviceUuid) {
          debugPrint("service match ${serv.uuid.toString()}");
          log.add("service match ${serv.uuid.toString()}");

          await preferences.setStringList('getReadData', log);
          //service = serv;
          for (var char in serv.characteristics) {
            if (char.uuid.toString() == sendCharacteristicUuid) {
              debugPrint("char match ${char.uuid.toString()}");
              log.add("char match ${char.uuid.toString()}");

              await preferences.setStringList('getReadData', log);
              // List<int> bytes = command.codeUnits;
              // debugPrint("bytes are $bytes");
              // log.add("bytes are $bytes");

              await preferences.setStringList('getReadData', log);
              // await char.write(bytes);
              // Timer.periodic(const Duration(seconds: 30), (timer) async {
              log.add("${DateTime.now().toIso8601String()}Service Started");
              await preferences.setStringList('getReadData', log);

              await char
                  .write([0x40, 0xA8, 0x00, 0x01, 0x01, 0x01, 0xAA, 0x55]);
              // log.add("[0x40, 0xA8, 0x00, 0x20, 0x01, 0x01, 0xAA, 0x55]");

              await preferences.setStringList('getReadData', log);
              // await char.write([0x40, 0xA8, 0x00, 0x01, 0x01, 0x01, 0xAA, 0x55]);
              // log.add("[0x40, 0xA8, 0x00, 0x01, 0x01, 0x01, 0xAA, 0x55]");

              // await preferences.setStringList('getReadData', log);
              //   }
              // );
              debugPrint("write success");
              log.add("write success");

              await preferences.setStringList('getReadData', log);
            }
          }
        }
      }
    }

    void receiveCommandFromFirmware() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.reload();
      final log = preferences.getStringList('getReadData') ?? <String>[];
      for (var serv in gBleServices) {
        if (serv.uuid.toString() == serviceUuid) {
          debugPrint("service match in read ${serv.uuid.toString()}");
          log.add("service match in read ${serv.uuid.toString()}");
          await preferences.setStringList('getReadData', log);
          for (var char in serv.characteristics) {
            if (char.uuid.toString() == receiveCharacteristicUuid) {
              log.add("char match in read ${char.uuid.toString()}");
              debugPrint("char match in read ${char.uuid.toString()}");
              await preferences.setStringList('getReadData', log);
              if (subscription != null) {
                debugPrint("Canceling stream");
                subscription!.cancel();
              }
              if (char.properties.notify == true) {
                await char.setNotifyValue(true);
                subscription = char.onValueReceived.listen((value) async {
                  debugPrint("received value is $value");
                  print(value.runtimeType);
                  List<String> hexList = value
                      .map((decimal) =>
                      decimal.toRadixString(16).padLeft(2, '0'))
                      .toList();

                  // if(hexList != null && hexList.isNotEmpty && hexList!=[]){
                  //   service.stopSelf();
                  // }
                  // await Future.delayed(Duration(seconds: 2));
                  // service.stopSelf();

                  // String hexString = hexList.join('');
                  String response = hexList.join('');
                  debugPrint("received value as hexString $response");
                  log.add("received value as hexString $response");

                  await preferences.setStringList('getReadData', log);
                  if (response.length >= 24) {
                    String deviceId =
                    response.substring(0, 6); // 3 bytes -> 6 hex digits
                    String reqCode =
                    response.substring(6, 8); // 1 byte -> 2 hex digits
                    String dataLength =
                    response.substring(8, 10); // 1 byte -> 2 hex digits
                    String beforeDecimal = response.substring(10, 12);
                    String afterDecimal = response.substring(12, 14);
                    String battery = response.substring(14, 16);
                    String buzzer = response.substring(16, 18);
                    String critical = response.substring(18, 20);
                    String checksum =
                    response.substring(20, 24); // 2 bytes -> 4 hex digits

                    if (critical == "01") {
                      debugPrint("Critical condition detected");
                      log.add("Critical condition detected");
                      // await updateLog(preferences, log);

                      String weight = "$beforeDecimal.$afterDecimal";
                      String notificationMessage =
                          "Battery level: $battery%, Weight: $weight";

                      datafornotification = notificationMessage;

                      // flutterLocalNotificationsPlugin.show(
                      //   1000, // Notification ID
                      //   'Critical Alert',
                      //   notificationMessage,
                      //   const NotificationDetails(
                      //     android: AndroidNotificationDetails(
                      //       'my_foreground',
                      //       'MY FOREGROUND SERVICE',
                      //       icon: 'ic_bg_service_small',
                      //       importance: Importance.max,
                      //       priority: Priority.high,
                      //       ongoing: false,
                      //     ),
                      //   ),
                      // );
                      // service.stopSelf();
                    }
                  } else {
                    debugPrint(
                        "Response string is too short: ${response.length} characters");
                  }
                  await Future.delayed(Duration(seconds: 5));
                  service.stopSelf();
                  // await preferences.setStringList('getReadData', log);
                  // await char.write(bytes);
                  // Timer.periodic(const Duration(seconds: 30), (timer) async {
                  log.add("${DateTime.now().toIso8601String()}Service Stoped");
                  await preferences.setStringList('getReadData', log);

                  // Check if hexString matches and show notification
                  // if (hexString == "40a80501051825860100aa55") {
                  //   debugPrint("Low Gas Alert detected");
                  //   flutterLocalNotificationsPlugin.show(
                  //     999, // Notification ID
                  //     'Low Gas Alert',
                  //     'Low Gas detected from the device.',
                  //     const NotificationDetails(
                  //       android: AndroidNotificationDetails(
                  //         'my_foreground',
                  //         'MY FOREGROUND SERVICE',
                  //         icon: 'ic_bg_service_small',
                  //         importance: Importance.max,
                  //         priority: Priority.high,
                  //         ongoing: false,
                  //       ),
                  //     ),
                  //   );
                  // }

                  // SharedPreferences preferences = await SharedPreferences.getInstance();
                  // await preferences.reload();
                  // final log = preferences.getStringList('getReadData') ?? <String>[];
                  //
                  // // Add new log with timestamp
                  // final newLog = "${DateTime.now().toIso8601String()} - $hexString";
                  // log.add(newLog);
                  //
                  // // Keep only the last 5 logs
                  // if (log.length > 5) {
                  //   log.removeRange(0, log.length - 5);
                  // }
                  //
                  // await preferences.setStringList('getReadData', log);
                });
              } else {
                readValue = await char.read();
                debugPrint("read value is  $readValue");
                log.add("read value is  $readValue");
                await preferences.setStringList('getReadData', log);
                List<String> hexList = readValue
                    .map((decimal) => decimal.toRadixString(16).padLeft(2, '0'))
                    .toList();
                await Future.delayed(Duration(seconds: 5));
                service.stopSelf();
                // if(hexList != null && hexList.isNotEmpty){
                //   service.stopSelf();
                // }

                String hexString = hexList.join('');
                debugPrint("read value as hexString $hexString");
                log.add("read value as hexString $hexString");

                await preferences.setStringList('getReadData', log);

                // Check if hexString matches and show notification
                if (hexString == "40a80501051825860100aa55") {
                  debugPrint("Low Gas Alert detected");
                  log.add("Low Gas Alert detected");
                  await preferences.setStringList('getReadData', log);
                  flutterLocalNotificationsPlugin.show(
                    999, // Notification ID
                    'Low Gas Alert',
                    'Low Gas detected from the device.',
                    const NotificationDetails(
                      android: AndroidNotificationDetails(
                        'my_foreground',
                        'MY FOREGROUND SERVICE',
                        icon: 'ic_bg_service_small',
                        importance: Importance.max,
                        priority: Priority.high,
                        ongoing: false,
                      ),
                    ),
                  );
                  await Future.delayed(Duration(seconds: 5));
                  service.stopSelf();
                }

                // SharedPreferences preferences = await SharedPreferences.getInstance();
                // await preferences.reload();
                // final log = preferences.getStringList('getReadData') ?? <String>[];
                //
                // // Add new log with timestamp
                // final newLog = "${DateTime.now().toIso8601String()} - $hexString";
                // log.add(newLog);
                //
                // // Keep only the last 5 logs
                // // if (log.length > 5) {
                // //   log.removeRange(0, log.length - 5);
                // // }
                //
                // await preferences.setStringList('getReadData', log);
              }
            }
          }
        }
      }
    }

    // scanningMethod() will scan devices and connect to specific device
    Future<void> scanningMethod() async {
      final isScanning = FlutterBluePlus.isScanningNow;
      if (isScanning) {
        await FlutterBluePlus.stopScan();
      }

      await FlutterBluePlus.stopScan();
      //Empty the Devices List before storing new value
      scannedDevicesList = [];
      gBleServices.clear();
      // servicesList.clear();
      receivedDataList.clear();

      await streamSubscription?.cancel();

      streamSubscription = FlutterBluePlus.scanResults.listen(
            (results) async {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.reload();
          final log = preferences.getStringList('getReadData') ?? <String>[];

          // log.add(newLog);

          // Keep only the last 5 logs
          // if (log.length > 5) {
          //   log.removeRange(0, log.length - 5);
          // }

          for (ScanResult r in results) {
            if (r.device.platformName.isNotEmpty &&
                !scannedDevicesList.contains(r.device)) {
              if (r.device.platformName == deviceName) {
                debugPrint("Device Name Matched ${r.device.platformName}");
                log.add("Device Name Matched ${r.device.platformName}");
                await streamSubscription?.cancel();
                scannedDevicesList.add(r.device);
                gBleDevice = r.device;

                await FlutterBluePlus.stopScan();
                try {
                  await gBleDevice!.disconnect();
                  await gBleDevice!.connect(autoConnect: false);
                } catch (e) {
                  if (e.toString() != 'already_connected') {
                    await gBleDevice!.disconnect();
                  }
                } finally {
                  gBleServices = await gBleDevice!.discoverServices();
                  Future.delayed(const Duration(milliseconds: 500), () async {
                    if (Platform.isAndroid) {
                      await gBleDevice!.requestMtu(200);
                    }
                  });
                  Future.delayed(Duration.zero, () async {
                    await preferences.reload();
                    final log =
                        preferences.getStringList('getReadData') ?? <String>[];

                    debugPrint('Device Connected');
                    log.add('Device Connected');
                    await preferences.setStringList('getReadData', log);

                    receiveCommandFromFirmware();
                    if (writeData.isNotEmpty) {
                      writeCharacteristic(dataForWrite);
                    }
                    if (readData.isNotEmpty) {
                      receiveCommandFromFirmware();
                    }
                    subscriptionConnection = gBleDevice?.connectionState
                        .listen((BluetoothConnectionState state) async {
                      if (state == BluetoothConnectionState.disconnected) {
                        // 1. typically, start a periodic timer that tries to
                        //    reconnect, or just call connect() again right now
                        // 2. you must always re-discover services after disconnection!
                        debugPrint(
                            "${gBleDevice?.platformName} is disconnected");
                        log.add("${gBleDevice?.platformName} is disconnected");
                        await preferences.setStringList('getReadData', log);

                        subscription!.cancel();
                        scanningMethod();
                        subscriptionConnection!.cancel();
                      }
                    });
                  });
                }
              }
            }
          }

          await preferences.setStringList('getReadData', log);
        },
      );
      await FlutterBluePlus.startScan();
    }

    if (connectToDevice.isNotEmpty) {
      scanningMethod();
    }

    // bring to foreground
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          /// OPTIONAL for use custom notification
          /// the notification id must be equals with AndroidConfiguration when you call configure() method.
          flutterLocalNotificationsPlugin.show(
            888,
            'Critical Alert',
            'Data:- ${datafornotification}',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'my_foreground',
                'MY FOREGROUND SERVICE',
                icon: 'ic_bg_service_small',
                ongoing: true,
              ),
            ),
          );

          // if you don't using custom notification, uncomment this
          service.setForegroundNotificationInfo(
            title: "Critical Alert",
            content: "${datafornotification}",
          );
        }
      }

      /// you can see this log in logcat
      //debugPrint('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

      service.invoke(
        'update',
        {
          "current_date": DateTime.now().toIso8601String(),
          "readData": readValue.toString(),
        },
      );
    });
  });
}