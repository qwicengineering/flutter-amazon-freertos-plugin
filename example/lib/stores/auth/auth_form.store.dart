import "package:mobx/mobx.dart";

part "auth_form.store.g.dart";

class AuthFormStore = _AuthFormStore with _$AuthFormStore;

abstract class _AuthFormStore with Store {
    @observable
    String email = "";

    @observable
    String password = "";

    @action
    void setEmail(String value) {
        email = value;
    }

    @action
    void setPassword(String value) {
        password = value;
    }
}