import "package:mobx/mobx.dart";

part "cognito.store.g.dart";

class CognitoStore = _CognitoStore with $CognitoStore;

abstract class _CognitoStore with Store {
    @observable
    int value = 0;

    @action
    void increment() {
        value++;
    }
}
