import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_zebra_sdk_example/ble_printer_connector.dart';
import 'package:functional_data/functional_data.dart';
import 'package:provider/provider.dart';

part 'device_interaction_tab.g.dart';

// ignore_for_file: annotate_overrides

class DeviceInteractionTab extends StatelessWidget {
  const DeviceInteractionTab({
    required this.device,
    Key? key,
  }) : super(key: key);

  final DiscoveredDevice device;

  @override
  Widget build(BuildContext context) =>
      Consumer2<BlePrinterConnector, PrinterConnectionStatusUpdate>(
        builder: (_, deviceConnector, printerConnectionStateUpdate, __) =>
            _DeviceInteractionTab(
          viewModel: DeviceInteractionViewModel(
            device: device,
            deviceId: device.id,
            connectableStatus: device.connectable,
            connectionStatus: printerConnectionStateUpdate.connectionState,
            printerConnectionState: printerConnectionStateUpdate,
            deviceConnector: deviceConnector,
          ),
        ),
      );
}

@immutable
@FunctionalData()
class DeviceInteractionViewModel extends $DeviceInteractionViewModel {
  static final Uint8List _testString = Uint8List.fromList(utf8.encode('''
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
        '''));

  const DeviceInteractionViewModel({
    required this.device,
    required this.deviceId,
    required this.connectableStatus,
    required this.connectionStatus,
    required this.deviceConnector,
    required this.printerConnectionState,
  });

  final DiscoveredDevice device;
  final String deviceId;
  final Connectable connectableStatus;
  final DeviceConnectionState connectionStatus;
  final BlePrinterConnector deviceConnector;
  final PrinterConnectionStatusUpdate printerConnectionState;

  bool get deviceConnected =>
      connectionStatus == DeviceConnectionState.connected;

  void connect() {
    deviceConnector.connect(deviceId);
  }

  void disconnect() {
    deviceConnector.disconnect(deviceId);
  }

  Future<void> testPrint() async {
    if (printerConnectionState.connectionState !=
        DeviceConnectionState.connected) {
      return;
    }

    final targetMtu = printerConnectionState.mtu!;
    final writeCharacteristic = printerConnectionState.writeCharacteristic!;

    List<Uint8List> chunks = _chunkByteList(_testString, targetMtu);

    try {
      for (var chunkByteList in chunks) {
        await writeCharacteristic.write(chunkByteList);
      }
    } catch (e) {
      debugPrint("failed to write chunk: $e");
    } finally {
      //disconnect after printing
      disconnect();
    }
  }

  List<Uint8List> _chunkByteList(Uint8List byteList, int chunkSize) {
    List<Uint8List> chunks = [];
    int start = 0;

    while (start < byteList.length) {
      int end = start + chunkSize;
      if (end > byteList.length) {
        end = byteList.length;
      }

      Uint8List chunk = byteList.sublist(start, end);
      chunks.add(chunk);

      start = end;
    }

    return chunks;
  }
}

class _DeviceInteractionTab extends StatefulWidget {
  const _DeviceInteractionTab({
    required this.viewModel,
    Key? key,
  }) : super(key: key);

  final DeviceInteractionViewModel viewModel;

  @override
  _DeviceInteractionTabState createState() => _DeviceInteractionTabState();
}

class _DeviceInteractionTabState extends State<_DeviceInteractionTab> {
  late List<Service> discoveredServices;

  @override
  void initState() {
    discoveredServices = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                      top: 8.0, bottom: 16.0, start: 16.0),
                  child: Text(
                    "ID: ${widget.viewModel.deviceId}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16.0),
                  child: Text(
                    "Connectable: ${widget.viewModel.connectableStatus}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16.0),
                  child: Text(
                    "Connection: ${widget.viewModel.connectionStatus}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: !widget.viewModel.deviceConnected
                            ? widget.viewModel.connect
                            : null,
                        child: const Text("Connect"),
                      ),
                      ElevatedButton(
                        onPressed: widget.viewModel.deviceConnected
                            ? widget.viewModel.testPrint
                            : null,
                        child: const Text("Test Print"),
                      ),
                      ElevatedButton(
                        onPressed: widget.viewModel.deviceConnected
                            ? widget.viewModel.disconnect
                            : null,
                        child: const Text("Disconnect"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
