// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bluetooth.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$BluetoothStore on _BluetoothStore, Store {
  Computed<bool> _$isBluetoothSupportedAndOnComputed;

  @override
  bool get isBluetoothSupportedAndOn => (_$isBluetoothSupportedAndOnComputed ??=
          Computed<bool>(() => super.isBluetoothSupportedAndOn))
      .value;

  final _$bluetoothStateAtom = Atom(name: '_BluetoothStore.bluetoothState');

  @override
  BluetoothState get bluetoothState {
    _$bluetoothStateAtom.context.enforceReadPolicy(_$bluetoothStateAtom);
    _$bluetoothStateAtom.reportObserved();
    return super.bluetoothState;
  }

  @override
  set bluetoothState(BluetoothState value) {
    _$bluetoothStateAtom.context.conditionallyRunInAction(() {
      super.bluetoothState = value;
      _$bluetoothStateAtom.reportChanged();
    }, _$bluetoothStateAtom, name: '${_$bluetoothStateAtom.name}_set');
  }

  final _$devicesNearbyAtom = Atom(name: '_BluetoothStore.devicesNearby');

  @override
  ObservableList<FreeRTOSDevice> get devicesNearby {
    _$devicesNearbyAtom.context.enforceReadPolicy(_$devicesNearbyAtom);
    _$devicesNearbyAtom.reportObserved();
    return super.devicesNearby;
  }

  @override
  set devicesNearby(ObservableList<FreeRTOSDevice> value) {
    _$devicesNearbyAtom.context.conditionallyRunInAction(() {
      super.devicesNearby = value;
      _$devicesNearbyAtom.reportChanged();
    }, _$devicesNearbyAtom, name: '${_$devicesNearbyAtom.name}_set');
  }

  final _$activeDeviceAtom = Atom(name: '_BluetoothStore.activeDevice');

  @override
  FreeRTOSDevice get activeDevice {
    _$activeDeviceAtom.context.enforceReadPolicy(_$activeDeviceAtom);
    _$activeDeviceAtom.reportObserved();
    return super.activeDevice;
  }

  @override
  set activeDevice(FreeRTOSDevice value) {
    _$activeDeviceAtom.context.conditionallyRunInAction(() {
      super.activeDevice = value;
      _$activeDeviceAtom.reportChanged();
    }, _$activeDeviceAtom, name: '${_$activeDeviceAtom.name}_set');
  }

  final _$servicesAtom = Atom(name: '_BluetoothStore.services');

  @override
  ObservableList<BluetoothService> get services {
    _$servicesAtom.context.enforceReadPolicy(_$servicesAtom);
    _$servicesAtom.reportObserved();
    return super.services;
  }

  @override
  set services(ObservableList<BluetoothService> value) {
    _$servicesAtom.context.conditionallyRunInAction(() {
      super.services = value;
      _$servicesAtom.reportChanged();
    }, _$servicesAtom, name: '${_$servicesAtom.name}_set');
  }

  final _$isConnectingAtom = Atom(name: '_BluetoothStore.isConnecting');

  @override
  bool get isConnecting {
    _$isConnectingAtom.context.enforceReadPolicy(_$isConnectingAtom);
    _$isConnectingAtom.reportObserved();
    return super.isConnecting;
  }

  @override
  set isConnecting(bool value) {
    _$isConnectingAtom.context.conditionallyRunInAction(() {
      super.isConnecting = value;
      _$isConnectingAtom.reportChanged();
    }, _$isConnectingAtom, name: '${_$isConnectingAtom.name}_set');
  }

  final _$initializeAsyncAction = AsyncAction('initialize');

  @override
  Future<void> initialize() {
    return _$initializeAsyncAction.run(() => super.initialize());
  }

  final _$getDevicesNearbyAsyncAction = AsyncAction('getDevicesNearby');

  @override
  Future<void> getDevicesNearby() {
    return _$getDevicesNearbyAsyncAction.run(() => super.getDevicesNearby());
  }

  final _$stopScanningAsyncAction = AsyncAction('stopScanning');

  @override
  Future<void> stopScanning() {
    return _$stopScanningAsyncAction.run(() => super.stopScanning());
  }

  final _$_BluetoothStoreActionController =
      ActionController(name: '_BluetoothStore');

  @override
  void setBluetoothState(BluetoothState value) {
    final _$actionInfo = _$_BluetoothStoreActionController.startAction();
    try {
      return super.setBluetoothState(value);
    } finally {
      _$_BluetoothStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic disconnect() {
    final _$actionInfo = _$_BluetoothStoreActionController.startAction();
    try {
      return super.disconnect();
    } finally {
      _$_BluetoothStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    final string =
        'bluetoothState: ${bluetoothState.toString()},devicesNearby: ${devicesNearby.toString()},activeDevice: ${activeDevice.toString()},services: ${services.toString()},isConnecting: ${isConnecting.toString()},isBluetoothSupportedAndOn: ${isBluetoothSupportedAndOn.toString()}';
    return '{$string}';
  }
}
