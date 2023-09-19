import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';
// import 'package:flutter/services.dart';
import 'package:flutter_zebra_sdk/flutter_zebra_sdk.dart';
import 'package:flutter_zebra_sdk_example/ble_connected_device_monitor.dart';
import 'package:flutter_zebra_sdk_example/ble_device_connector.dart';
import 'package:flutter_zebra_sdk_example/ble_device_interactor.dart';
import 'package:flutter_zebra_sdk_example/ble_logger.dart';
import 'package:flutter_zebra_sdk_example/ble_scanner.dart';
import 'package:flutter_zebra_sdk_example/device_list.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final _ble = FlutterReactiveBle();
  final _bleLogger = BleLogger(ble: _ble);
  final _scanner = BleScanner(ble: _ble, logMessage: _bleLogger.addToLog);
  // final _monitor = BleStatusMonitor(_ble);

  final _connectedDeviceMonitor = BleConnectedDeviceMonitor(
    ble: FlutterReactiveBle(),
    logMessage: _bleLogger.addToLog,
  )..startListening();
  final _connector = BleDeviceConnector(
    ble: _ble,
    logMessage: _bleLogger.addToLog,
  );
  final _serviceDiscoverer = BleDeviceInteractor(
    bleDiscoverServices: (deviceId) async {
      await _ble.discoverAllServices(deviceId);
      return _ble.getDiscoveredServices(deviceId);
    },
    logMessage: _bleLogger.addToLog,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: _scanner),
        // Provider.value(value: _monitor),
        Provider.value(value: _connector),
        Provider.value(value: _serviceDiscoverer),
        Provider.value(value: _bleLogger),

        StreamProvider<BleScannerState?>(
          create: (_) => _scanner.state,
          initialData: const BleScannerState(
            discoveredDevices: [],
            scanIsInProgress: false,
          ),
        ),

        StreamProvider<ConnectionStateUpdate>(
          create: (_) => _connector.state,
          initialData: const ConnectionStateUpdate(
            deviceId: 'Unknown device',
            connectionState: DeviceConnectionState.disconnected,
            failure: null,
          ),
        ),

        Provider.value(value: _connectedDeviceMonitor),
        StreamProvider<BleConnectedDeviceMonitorState>(
          create: (_) => _connectedDeviceMonitor.state,
          initialData: const BleConnectedDeviceMonitorState(
            connectedDevices: [],
          ),
        ),
      ],
      child: const MaterialApp(
        title: 'Flutter Reactive BLE example',
        home: DeviceListScreen(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initial();
  }

  void initial() async {
    // await Permission.
  }

  Future _ackAlert(BuildContext context, String title) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          // content: const Text('This item is no longer available'),
          actions: [
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> onDiscovery() async {
    var a = await ZebraSdk.onDiscovery();
    print(a);
    var b = json.decode(a);

    var printers = b['content'];
    if (printers != null) {
      var printObj = json.decode(printers);
      print(printObj);
    }

    print(b);
  }

  Future<void> onDiscoveryUSB(dynamic context) async {
    var a = await ZebraSdk.onDiscoveryUSB();
    _ackAlert(context, 'USB $a');
    print(a);
    var b = json.decode(a);

    var printers = b['content'];
    if (printers != null) {
      var printObj = json.decode(printers);
      print(printObj);
    }
    print(b);
  }

  Future<void> onGetIPInfo() async {
    var a = await ZebraSdk.onGetPrinterInfo('192.168.1.26');
    print(a);
  }

  Future<void> onTestConnect() async {
    var a = await ZebraSdk.isPrinterConnected('192.168.1.26');
    print(a);
    var b = json.decode(a);
    print(b);
  }

  Future<void> onTestTCP() async {
    String data;
    data = '''
    ''
    ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR6,6~SD15^JUS^LRN^CI0^XZ
    ^XA
    ^MMT
    ^PW500
    ^LL0240
    ^LS0
    ^FT144,33^A0N,25,24^FB111,1,0,C^FH\^FDITEM TITLE^FS
    ^FT3,61^A@N,20,20,TT0003M_^FB394,1,0,C^FH\^CI17^F8^FDOption 1, Option 2, Option 3, Option 4, Opt^FS^CI0
    ^FT3,84^A@N,20,20,TT0003M_^FB394,1,0,C^FH\^CI17^F8^FDion 5, Option 6 ^FS^CI0
    ^FT34,138^A@N,25,24,TT0003M_^FB331,1,0,C^FH\^CI17^F8^FDOrder: https://eat.chat/phobac^FS^CI0
    ^FT29,173^A@N,20,20,TT0003M_^FB342,1,0,C^FH\^CI17^F8^FDPromotional Promotional Promotional^FS^CI0
    ^FT29,193^A@N,20,20,TT0003M_^FB342,1,0,C^FH\^CI17^F8^FD Promotional Promotional ^FS^CI0
    ^FT106,233^A0N,25,24^FB188,1,0,C^FH\^FDPHO BAC HOA VIET^FS
    ^PQ1,0,1,Y^XZ
        ''';

    final rep = ZebraSdk.printZPLOverTCPIP('192.168.1.26', data: data);
    print(rep);
  }

  Future<void> onTestBluetooth() async {
    String data;
    data = '''
    CT~~CD,~CC^~CT~
    ^XA~JS20 - ~JS80
    ^XA~TA018
    ^LT0^MNM^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD30^JUS^LRN^CI28^XZ
    ^XA
    ^MMC
    ^PW728
    ^LL624
    ^LS0
    
        ^FO32,32
        ^FB650,1,5,c,
        ^A0,73,73
        ^FH\^FDnathan^FS
    
        ^FO32,119
        ^FB650,1,5,c,
        ^A0,73,73
        ^FH\^FDchan^FS
    
        ^FO32,217
        ^FB650,1,5,c,
        ^A0,58,58
        ^FH\^FDEvent Host Inc.^FS
    
        ^FO32,292
        ^FB650,1,5,c,
        ^A0,49,49
        ^FH\^FDEvent Manager^FS
    
        ^FO32,358
        ^FB650,1,5,c,
        ^A0,39,39
        ^FH\^FDExhibitor, Sponsor^FS
    
    ^FO271,433
    ^BQN,2,7,Q,7
    ^FH\^FDLA,ATTXHYFY5QXY0EX2BSKBS6MF4ZW5^FS
    
    ^PQ1,0,1,Y^XZ
        ''';

    String arr = 'D9N225100849';

    final rep = ZebraSdk.printZPLOverBluetooth(arr, data: data);
    print(rep);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              children: [
                TextButton(
                    onPressed: onGetIPInfo, child: Text('onGetPrinterInfo')),
                TextButton(
                    onPressed: onTestConnect, child: Text('onTestConnect')),
                TextButton(onPressed: onDiscovery, child: Text('Discovery')),
                TextButton(
                    onPressed: () => onDiscoveryUSB(context),
                    child: Text('Discovery USB')),
                TextButton(onPressed: onTestTCP, child: Text('Print TCP')),
                TextButton(
                    onPressed: onTestBluetooth, child: Text('Print Bluetooth')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
