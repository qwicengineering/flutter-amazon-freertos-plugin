// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_form.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AuthFormStore on _AuthFormStore, Store {
  final _$emailAtom = Atom(name: '_AuthFormStore.email');

  @override
  String get email {
    _$emailAtom.context.enforceReadPolicy(_$emailAtom);
    _$emailAtom.reportObserved();
    return super.email;
  }

  @override
  set email(String value) {
    _$emailAtom.context.conditionallyRunInAction(() {
      super.email = value;
      _$emailAtom.reportChanged();
    }, _$emailAtom, name: '${_$emailAtom.name}_set');
  }

  final _$passwordAtom = Atom(name: '_AuthFormStore.password');

  @override
  String get password {
    _$passwordAtom.context.enforceReadPolicy(_$passwordAtom);
    _$passwordAtom.reportObserved();
    return super.password;
  }

  @override
  set password(String value) {
    _$passwordAtom.context.conditionallyRunInAction(() {
      super.password = value;
      _$passwordAtom.reportChanged();
    }, _$passwordAtom, name: '${_$passwordAtom.name}_set');
  }

  final _$verificationCodeAtom = Atom(name: '_AuthFormStore.verificationCode');

  @override
  String get verificationCode {
    _$verificationCodeAtom.context.enforceReadPolicy(_$verificationCodeAtom);
    _$verificationCodeAtom.reportObserved();
    return super.verificationCode;
  }

  @override
  set verificationCode(String value) {
    _$verificationCodeAtom.context.conditionallyRunInAction(() {
      super.verificationCode = value;
      _$verificationCodeAtom.reportChanged();
    }, _$verificationCodeAtom, name: '${_$verificationCodeAtom.name}_set');
  }

  final _$validateUsernameAsyncAction = AsyncAction('validateUsername');

  @override
  Future<dynamic> validateUsername(String value) {
    return _$validateUsernameAsyncAction
        .run(() => super.validateUsername(value));
  }

  final _$_AuthFormStoreActionController =
      ActionController(name: '_AuthFormStore');

  @override
  void setEmail(String value) {
    final _$actionInfo = _$_AuthFormStoreActionController.startAction();
    try {
      return super.setEmail(value);
    } finally {
      _$_AuthFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPassword(String value) {
    final _$actionInfo = _$_AuthFormStoreActionController.startAction();
    try {
      return super.setPassword(value);
    } finally {
      _$_AuthFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setVerificationCode(String value) {
    final _$actionInfo = _$_AuthFormStoreActionController.startAction();
    try {
      return super.setVerificationCode(value);
    } finally {
      _$_AuthFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    final string =
        'email: ${email.toString()},password: ${password.toString()},verificationCode: ${verificationCode.toString()}';
    return '{$string}';
  }
}

mixin _$AuthFormErrorState on _AuthFormErrorState, Store {
  Computed<bool> _$hasErrorsComputed;

  @override
  bool get hasErrors =>
      (_$hasErrorsComputed ??= Computed<bool>(() => super.hasErrors)).value;

  final _$emailAtom = Atom(name: '_AuthFormErrorState.email');

  @override
  String get email {
    _$emailAtom.context.enforceReadPolicy(_$emailAtom);
    _$emailAtom.reportObserved();
    return super.email;
  }

  @override
  set email(String value) {
    _$emailAtom.context.conditionallyRunInAction(() {
      super.email = value;
      _$emailAtom.reportChanged();
    }, _$emailAtom, name: '${_$emailAtom.name}_set');
  }

  final _$passwordAtom = Atom(name: '_AuthFormErrorState.password');

  @override
  String get password {
    _$passwordAtom.context.enforceReadPolicy(_$passwordAtom);
    _$passwordAtom.reportObserved();
    return super.password;
  }

  @override
  set password(String value) {
    _$passwordAtom.context.conditionallyRunInAction(() {
      super.password = value;
      _$passwordAtom.reportChanged();
    }, _$passwordAtom, name: '${_$passwordAtom.name}_set');
  }

  @override
  String toString() {
    final string =
        'email: ${email.toString()},password: ${password.toString()},hasErrors: ${hasErrors.toString()}';
    return '{$string}';
  }
}
