import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_zebra_sdk_example/ble_connected_device_monitor.dart';
import 'package:flutter_zebra_sdk_example/ble_logger.dart';
import 'package:flutter_zebra_sdk_example/ble_scanner.dart';
import 'package:flutter_zebra_sdk_example/device_detail_screen.dart';
import 'package:provider/provider.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer5<BleScanner, BleScannerState?,
          BleLogger, LogLevel, BleConnectedDeviceMonitorState>(
        builder: (_, bleScanner, bleScannerState, bleLogger, logLevel,
                bleConnectedDeviceMonitorState, __) =>
            _DeviceList(
          scannerState: bleScannerState ??
              const BleScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
          toggleVerboseLogging: bleLogger.toggleVerboseLogging,
          verboseLogging: bleLogger.verboseLogging,
          connectedDevices: bleConnectedDeviceMonitorState.connectedDevices,
        ),
      );
}

class _DeviceList extends StatefulWidget {
  const _DeviceList({
    required this.scannerState,
    required this.startScan,
    required this.stopScan,
    required this.toggleVerboseLogging,
    required this.verboseLogging,
    required this.connectedDevices,
  });

  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;
  final VoidCallback toggleVerboseLogging;
  final bool verboseLogging;
  final List<ConnectionStateUpdate> connectedDevices;

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<_DeviceList> {
  static const String ZPRINTER_SERV_ID_FOR_CONNECTION = "FE79";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.stopScan();
    super.dispose();
  }

  void _startScanning() {
    widget.startScan([Uuid.parse(ZPRINTER_SERV_ID_FOR_CONNECTION)]);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Scan for devices'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        child: const Text('Scan'),
                        onPressed: !widget.scannerState.scanIsInProgress
                            ? _startScanning
                            : null,
                      ),
                      ElevatedButton(
                        child: const Text('Stop'),
                        onPressed: widget.scannerState.scanIsInProgress
                            ? widget.stopScan
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                children: [
                  SwitchListTile(
                    title: const Text("Verbose logging"),
                    value: widget.verboseLogging,
                    onChanged: (_) => widget.toggleVerboseLogging(),
                  ),
                  ListTile(
                    title: Text(
                      !widget.scannerState.scanIsInProgress
                          ? 'tap start to begin scanning Zebra printers'
                          : 'Tap a device to connect to it',
                    ),
                    trailing: (widget.scannerState.scanIsInProgress ||
                            widget.scannerState.discoveredDevices.isNotEmpty)
                        ? Text(
                            'count: ${widget.scannerState.discoveredDevices.length}',
                          )
                        : null,
                  ),
                  ...widget.scannerState.discoveredDevices
                      .map(
                        (device) => ListTile(
                          title: Text(
                            device.name.isNotEmpty ? device.name : "Unnamed",
                          ),
                          subtitle: Text(
                            """
${device.id}
RSSI: ${device.rssi}
${device.connectable}
                            """,
                          ),
                          leading: const Icon(Icons.bluetooth),
                          onTap: () async {
                            widget.stopScan();
                            await Navigator.push<void>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DeviceDetailScreen(device: device),
                              ),
                            );
                          },
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text(
                      "connected devices",
                    ),
                    trailing: Text(
                      'count: ${widget.connectedDevices.length}',
                    ),
                  ),
                  ...widget.connectedDevices
                      .map(
                        (device) => ListTile(
                          title: Text(
                            device.deviceId,
                          ),
                          subtitle: Text(
                            device.connectionState.toString(),
                          ),
                          leading: const Icon(Icons.bluetooth),
                          onTap: () async {
                            widget.stopScan();
                            // await Navigator.push<void>(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) =>
                            //         DeviceDetailScreen(device: device),
                            //   ),
                            // );
                          },
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      );
}
