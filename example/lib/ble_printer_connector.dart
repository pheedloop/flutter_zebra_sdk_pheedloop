import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_zebra_sdk_example/reactive_state.dart';

class BlePrinterConnector extends ReactiveState<ConnectionStateUpdate> {
  BlePrinterConnector({
    required FlutterReactiveBle ble,
    required Function(String message) logMessage,
  })  : _ble = ble,
        _logMessage = logMessage;

  final FlutterReactiveBle _ble;
  final void Function(String message) _logMessage;
  final Map<String, StreamSubscription<ConnectionStateUpdate>>
      _printerConnectionSubscriptions = {};
  final Map<String, DeviceConnectionState> _printerConnectionStates = {};

  @override
  Stream<ConnectionStateUpdate> get state => _deviceConnectionController.stream;

  final _deviceConnectionController = StreamController<ConnectionStateUpdate>();

  Future<void> connect(String deviceId) async {
    if (_printerConnectionSubscriptions.containsKey(deviceId) &&
        _printerConnectionStates.containsKey(deviceId) &&
        _printerConnectionStates[deviceId] == DeviceConnectionState.connected) {
      throw Exception('Already connected to $deviceId');
    }

    _logMessage('Start connecting to $deviceId');

    _printerConnectionSubscriptions[deviceId] =
        _ble.connectToDevice(id: deviceId).listen(
      (update) async {
        _logMessage(
            'ConnectionState for printer $deviceId : ${update.connectionState}');
        _deviceConnectionController.add(update);
      },
      onError: (Object e) =>
          _logMessage('Connecting to printer $deviceId resulted in error $e'),
    );
  }

  Future<void> disconnect(String deviceId) async {
    if (!_printerConnectionSubscriptions.containsKey(deviceId) ||
        (_printerConnectionStates.containsKey(deviceId) &&
            _printerConnectionStates[deviceId] ==
                DeviceConnectionState.disconnected)) {
      _logMessage("trying to disconnect a disconnected printer: $deviceId");
      return;
    }

    try {
      _logMessage('disconnecting to printer: $deviceId');
      await _printerConnectionSubscriptions[deviceId]!.cancel();
    } on Exception catch (e, _) {
      _logMessage("Error disconnecting from a printer: $e");
    } finally {
      _deviceConnectionController.add(
        ConnectionStateUpdate(
          deviceId: deviceId,
          connectionState: DeviceConnectionState.disconnected,
          failure: null,
        ),
      );
    }
  }

//   Future<void> sendWrite() async {
// try {
//       _logMessage('disconnecting to device: $deviceId');
//       _ble.writeCharacteristicWithoutResponse(, value: value)
//     } on Exception catch (e, _) {
//       _logMessage("Error disconnecting from a device: $e");
//     } finally {
//       // Since [_connection] subscription is terminated, the "disconnected" state cannot be received and propagated
//       _deviceConnectionController.add(
//         ConnectionStateUpdate(
//           deviceId: deviceId,
//           connectionState: DeviceConnectionState.disconnected,
//           failure: null,
//         ),
//       );
//     }
//   }

  Future<void> dispose() async {
    await _deviceConnectionController.close();
  }
}
