import "package:mobx/mobx.dart";
import "package:validators/validators.dart";

part "auth_form.store.g.dart";

class AuthFormStore = _AuthFormStore with _$AuthFormStore;

abstract class _AuthFormStore with Store {

    final AuthFormErrorState error  = AuthFormErrorState();

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

    @action
    Future validateUsername(String value) async {
        if (isNull(value) || value.isEmpty) {
            error.email = "Cannot be blank";
            return;
        }

        error.email = null;
    }

}

class AuthFormErrorState = _AuthFormErrorState with _$AuthFormErrorState;

abstract class _AuthFormErrorState with Store {
    @observable
    String email;

    @observable
    String password;

    @computed
    bool get hasErrors => email != null || password != null;
}
