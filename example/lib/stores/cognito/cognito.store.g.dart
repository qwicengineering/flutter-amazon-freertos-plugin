// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cognito.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$CognitoStore on _CognitoStore, Store {
  final _$userStateAtom = Atom(name: '_CognitoStore.userState');

  @override
  UserState get userState {
    _$userStateAtom.context.enforceReadPolicy(_$userStateAtom);
    _$userStateAtom.reportObserved();
    return super.userState;
  }

  @override
  set userState(UserState value) {
    _$userStateAtom.context.conditionallyRunInAction(() {
      super.userState = value;
      _$userStateAtom.reportChanged();
    }, _$userStateAtom, name: '${_$userStateAtom.name}_set');
  }

  final _$initializeAsyncAction = AsyncAction('initialize');

  @override
  Future<void> initialize() {
    return _$initializeAsyncAction.run(() => super.initialize());
  }

  final _$_CognitoStoreActionController =
      ActionController(name: '_CognitoStore');

  @override
  void setUserState(UserState value) {
    final _$actionInfo = _$_CognitoStoreActionController.startAction();
    try {
      return super.setUserState(value);
    } finally {
      _$_CognitoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void signIn() {
    final _$actionInfo = _$_CognitoStoreActionController.startAction();
    try {
      return super.signIn();
    } finally {
      _$_CognitoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    final string = 'userState: ${userState.toString()}';
    return '{$string}';
  }
}
