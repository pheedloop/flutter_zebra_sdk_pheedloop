import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_zebra_sdk_example/ble_connected_device_monitor.dart';
import 'package:flutter_zebra_sdk_example/ble_printer_connector.dart';
import 'package:flutter_zebra_sdk_example/ble_logger.dart';
import 'package:flutter_zebra_sdk_example/ble_scanner.dart';
import 'package:flutter_zebra_sdk_example/device_list.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final _ble = FlutterReactiveBle();
  final _bleLogger = BleLogger(ble: _ble);
  final _scanner = BleScanner(ble: _ble, logMessage: _bleLogger.addToLog);

  final _connectedDeviceMonitor = BleConnectedDeviceMonitor(
    ble: FlutterReactiveBle(),
    logMessage: _bleLogger.addToLog,
  )..startListening();
  final _connector = BlePrinterConnector(
    ble: _ble,
    logMessage: _bleLogger.addToLog,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: _scanner),
        Provider.value(value: _connector),
        Provider.value(value: _bleLogger),
        StreamProvider<LogLevel>(
          create: (_) => _bleLogger.state,
          initialData: LogLevel.none,
        ),
        StreamProvider<BleScannerState?>(
          create: (_) => _scanner.state,
          initialData: const BleScannerState(
            discoveredDevices: [],
            scanIsInProgress: false,
          ),
        ),
        StreamProvider<PrinterConnectionStatusUpdate>(
          create: (_) => _connector.state,
          initialData: const PrinterConnectionStatusUpdate(
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
