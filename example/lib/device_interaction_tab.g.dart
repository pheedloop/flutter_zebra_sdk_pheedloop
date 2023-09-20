// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_interaction_tab.dart';

// **************************************************************************
// FunctionalDataGenerator
// **************************************************************************

abstract class $DeviceInteractionViewModel {
  const $DeviceInteractionViewModel();

  DiscoveredDevice get device;
  String get deviceId;
  Connectable get connectableStatus;
  DeviceConnectionState get connectionStatus;
  BlePrinterConnector get deviceConnector;
  PrinterConnectionStatusUpdate get printerConnectionState;

  DeviceInteractionViewModel copyWith({
    DiscoveredDevice? device,
    String? deviceId,
    Connectable? connectableStatus,
    DeviceConnectionState? connectionStatus,
    BlePrinterConnector? deviceConnector,
    PrinterConnectionStatusUpdate? printerConnectionState,
  }) =>
      DeviceInteractionViewModel(
        device: device ?? this.device,
        deviceId: deviceId ?? this.deviceId,
        connectableStatus: connectableStatus ?? this.connectableStatus,
        connectionStatus: connectionStatus ?? this.connectionStatus,
        deviceConnector: deviceConnector ?? this.deviceConnector,
        printerConnectionState:
            printerConnectionState ?? this.printerConnectionState,
      );

  DeviceInteractionViewModel copyUsing(
      void Function(DeviceInteractionViewModel$Change change) mutator) {
    final change = DeviceInteractionViewModel$Change._(
      this.device,
      this.deviceId,
      this.connectableStatus,
      this.connectionStatus,
      this.deviceConnector,
      this.printerConnectionState,
    );
    mutator(change);
    return DeviceInteractionViewModel(
      device: change.device,
      deviceId: change.deviceId,
      connectableStatus: change.connectableStatus,
      connectionStatus: change.connectionStatus,
      deviceConnector: change.deviceConnector,
      printerConnectionState: change.printerConnectionState,
    );
  }

  @override
  String toString() =>
      "DeviceInteractionViewModel(device: $device, deviceId: $deviceId, connectableStatus: $connectableStatus, connectionStatus: $connectionStatus, deviceConnector: $deviceConnector, printerConnectionState: $printerConnectionState)";

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      other is DeviceInteractionViewModel &&
      other.runtimeType == runtimeType &&
      device == other.device &&
      deviceId == other.deviceId &&
      connectableStatus == other.connectableStatus &&
      connectionStatus == other.connectionStatus &&
      deviceConnector == other.deviceConnector &&
      printerConnectionState == other.printerConnectionState;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode {
    var result = 17;
    result = 37 * result + device.hashCode;
    result = 37 * result + deviceId.hashCode;
    result = 37 * result + connectableStatus.hashCode;
    result = 37 * result + connectionStatus.hashCode;
    result = 37 * result + deviceConnector.hashCode;
    result = 37 * result + printerConnectionState.hashCode;
    return result;
  }
}

class DeviceInteractionViewModel$Change {
  DeviceInteractionViewModel$Change._(
    this.device,
    this.deviceId,
    this.connectableStatus,
    this.connectionStatus,
    this.deviceConnector,
    this.printerConnectionState,
  );

  DiscoveredDevice device;
  String deviceId;
  Connectable connectableStatus;
  DeviceConnectionState connectionStatus;
  BlePrinterConnector deviceConnector;
  PrinterConnectionStatusUpdate printerConnectionState;
}

// ignore: avoid_classes_with_only_static_members
class DeviceInteractionViewModel$ {
  static final device = Lens<DeviceInteractionViewModel, DiscoveredDevice>(
    (deviceContainer) => deviceContainer.device,
    (deviceContainer, device) => deviceContainer.copyWith(device: device),
  );

  static final deviceId = Lens<DeviceInteractionViewModel, String>(
    (deviceIdContainer) => deviceIdContainer.deviceId,
    (deviceIdContainer, deviceId) =>
        deviceIdContainer.copyWith(deviceId: deviceId),
  );

  static final connectableStatus =
      Lens<DeviceInteractionViewModel, Connectable>(
    (connectableStatusContainer) =>
        connectableStatusContainer.connectableStatus,
    (connectableStatusContainer, connectableStatus) =>
        connectableStatusContainer.copyWith(
            connectableStatus: connectableStatus),
  );

  static final connectionStatus =
      Lens<DeviceInteractionViewModel, DeviceConnectionState>(
    (connectionStatusContainer) => connectionStatusContainer.connectionStatus,
    (connectionStatusContainer, connectionStatus) =>
        connectionStatusContainer.copyWith(connectionStatus: connectionStatus),
  );

  static final deviceConnector =
      Lens<DeviceInteractionViewModel, BlePrinterConnector>(
    (deviceConnectorContainer) => deviceConnectorContainer.deviceConnector,
    (deviceConnectorContainer, deviceConnector) =>
        deviceConnectorContainer.copyWith(deviceConnector: deviceConnector),
  );

  static final printerConnectionState =
      Lens<DeviceInteractionViewModel, PrinterConnectionStatusUpdate>(
    (printerConnectionStateContainer) =>
        printerConnectionStateContainer.printerConnectionState,
    (printerConnectionStateContainer, printerConnectionState) =>
        printerConnectionStateContainer.copyWith(
            printerConnectionState: printerConnectionState),
  );
}
