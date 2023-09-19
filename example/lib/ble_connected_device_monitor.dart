import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_zebra_sdk_example/reactive_state.dart';

class BleConnectedDeviceMonitor
    extends ReactiveState<BleConnectedDeviceMonitorState> {
  BleConnectedDeviceMonitor({
    required FlutterReactiveBle ble,
    required Function(String message) logMessage,
  })  : _ble = ble,
        _logMessage = logMessage;

  final FlutterReactiveBle _ble;
  final void Function(String message) _logMessage;

  final _deviceConnectionController =
      StreamController<BleConnectedDeviceMonitorState>();

  List<ConnectionStateUpdate> _connectedDevices = [];

  StreamSubscription? _subscription;

  void startListening() {
    _logMessage('Start listening for connected devices');
    _subscription = _ble.connectedDeviceStream.listen((device) {
      _logMessage('Connected device: ${device.deviceId}');

      _deviceConnectionController.add(
        BleConnectedDeviceMonitorState(
          connectedDevices: [device],
        ),
      );
    });
  }

  void stopListening() {
    _logMessage('Stop listening for connected devices');
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  Stream<BleConnectedDeviceMonitorState> get state =>
      _deviceConnectionController.stream;

  Future<void> dispose() async {
    await _deviceConnectionController.close();
    stopListening();
  }
}

@immutable
class BleConnectedDeviceMonitorState {
  const BleConnectedDeviceMonitorState({
    required this.connectedDevices,
  });

  final List<ConnectionStateUpdate> connectedDevices;
}
