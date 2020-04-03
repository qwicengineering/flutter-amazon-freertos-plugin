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
  List<FreeRTOSDevice> get devicesNearby {
    _$devicesNearbyAtom.context.enforceReadPolicy(_$devicesNearbyAtom);
    _$devicesNearbyAtom.reportObserved();
    return super.devicesNearby;
  }

  @override
  set devicesNearby(List<FreeRTOSDevice> value) {
    _$devicesNearbyAtom.context.conditionallyRunInAction(() {
      super.devicesNearby = value;
      _$devicesNearbyAtom.reportChanged();
    }, _$devicesNearbyAtom, name: '${_$devicesNearbyAtom.name}_set');
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
  String toString() {
    final string =
        'bluetoothState: ${bluetoothState.toString()},devicesNearby: ${devicesNearby.toString()},isBluetoothSupportedAndOn: ${isBluetoothSupportedAndOn.toString()}';
    return '{$string}';
  }
}
