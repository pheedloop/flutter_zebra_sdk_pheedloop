import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_zebra_sdk_example/reactive_state.dart';

class BlePrinterConnector extends ReactiveState<ConnectionStateUpdate> {
  static final Uuid _serviceUuid =
      Uuid.parse('38EB4A80-C570-11E3-9507-0002A5D5C51B');
  static final Uuid _write2CharacteristicsUuid =
      Uuid.parse("38EB4A82-C570-11E3-9507-0002A5D5C51B");
  static final Uuid _readCharacteristicsUuid =
      Uuid.parse("38EB4A81-C570-11E3-9507-0002A5D5C51B");

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
  Stream<PrinterConnectionStatusUpdate> get state =>
      _deviceConnectionController.stream;

  final _deviceConnectionController =
      StreamController<PrinterConnectionStatusUpdate>();

  Future<void> connect(String deviceId) async {
    if (_printerConnectionSubscriptions.containsKey(deviceId) &&
        _printerConnectionStates.containsKey(deviceId) &&
        (_printerConnectionStates[deviceId] ==
                DeviceConnectionState.connected ||
            _printerConnectionStates[deviceId] ==
                DeviceConnectionState.connecting)) {
      throw Exception('Already connected to $deviceId');
    }

    _logMessage('Start connecting to $deviceId');

    _printerConnectionSubscriptions[deviceId] =
        _ble.connectToDevice(id: deviceId).listen(
      (update) async {
        if (update.connectionState == DeviceConnectionState.connected) {
          await _ble.discoverAllServices(deviceId);
          final allServices = await _ble.getDiscoveredServices(deviceId);

          if (!(allServices.any((service) =>
              service.id == _serviceUuid &&
              service.characteristics.any((characteristic) =>
                  characteristic.id == _write2CharacteristicsUuid) &&
              service.characteristics.any((characteristic) =>
                  characteristic.id == _readCharacteristicsUuid)))) {
            // if not a valid zebra printer, then disconnect
            await disconnect(deviceId);
            return;
          }

          final requestedMtu =
              await _ble.requestMtu(deviceId: deviceId, mtu: 512);
          final writeCharacteristic = allServices
              .firstWhere((service) => service.id == _serviceUuid)
              .characteristics
              .firstWhere((characteristic) =>
                  characteristic.id == _write2CharacteristicsUuid);

          final printerUpdate =
              PrinterConnectionStatusUpdate.withConnectionStateUpdate(
            update,
            mtu: requestedMtu,
            writeCharacteristic: writeCharacteristic,
          );

          _deviceConnectionController.add(printerUpdate);
        } else {
          _deviceConnectionController.add(
            PrinterConnectionStatusUpdate.withConnectionStateUpdate(
              update,
            ),
          );
        }

        _printerConnectionStates[deviceId] = update.connectionState;

        _logMessage(
            'ConnectionState for printer $deviceId : ${update.connectionState}');
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
      _printerConnectionStates[deviceId] = DeviceConnectionState.disconnected;
      _deviceConnectionController.add(
        PrinterConnectionStatusUpdate(
          deviceId: deviceId,
          connectionState: DeviceConnectionState.disconnected,
        ),
      );
    }
  }

  Future<void> dispose() async {
    await _deviceConnectionController.close();
  }
}

class PrinterConnectionStatusUpdate extends ConnectionStateUpdate {
  final int? mtu;
  final Characteristic? writeCharacteristic;

  const PrinterConnectionStatusUpdate({
    required String deviceId,
    required DeviceConnectionState connectionState,
    GenericFailure<ConnectionError>? failure,
    this.mtu,
    this.writeCharacteristic,
  }) : super(
            deviceId: deviceId,
            connectionState: connectionState,
            failure: failure);

  factory PrinterConnectionStatusUpdate.withConnectionStateUpdate(
    ConnectionStateUpdate update, {
    int? mtu,
    Characteristic? writeCharacteristic,
  }) {
    return PrinterConnectionStatusUpdate(
      deviceId: update.deviceId,
      connectionState: update.connectionState,
      failure: update.failure,
      mtu: mtu,
      writeCharacteristic: writeCharacteristic,
    );
  }
}
