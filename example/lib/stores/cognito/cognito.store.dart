import "package:mobx/mobx.dart";
import "package:flutter_cognito_plugin/flutter_cognito_plugin.dart";

part "cognito.store.g.dart";

class CognitoStore = _CognitoStore with _$CognitoStore;

abstract class _CognitoStore with Store {

    _CognitoStore() {
        initialize();
    }

    @observable
    UserState userState;

    @action
    void setUserState(UserState value) {
        userState = value;
    }

    @action
    void signIn() {
        print("signin");
    }

    @action
    Future<void> initialize() async {
        try {
            await Cognito.initialize();
            userState = await Cognito.getCurrentUserState();
            print("userState: $userState");
            Cognito.registerCallback(setUserState);
        } catch (e) {
            print("Unable to initlize Cognito");
            print(e);
        }
    }
}
