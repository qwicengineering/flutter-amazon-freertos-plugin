import "package:mobx/mobx.dart";
import "package:flutter_cognito_plugin/flutter_cognito_plugin.dart";

part "cognito.store.g.dart";

class CognitoStore = _CognitoStore with _$CognitoStore;

abstract class _CognitoStore with Store {
    @observable
    UserState userState;

    @action
    void setUserState(UserState value) {
        userState = value;
    }

    bool get isUserSignIn {
        return userState == UserState.SIGNED_IN;
    }

    @action
    Future<void> signIn(String email, String password) async {
        try {
            var response = await Cognito.signIn(email, password);
            print(response);
        } catch (e) {
            print("Error: Unable to sign in");
            print(e);
        }
    }

    @action 
    Future<void> register(String email, String password) async {
        try {
            var response = await Cognito.signUp(email, password);
            print(response);
        } catch (e) {
            print("Error: Unable to register");
            print(e);
        }
    }

    @action
    Future<void> verify(String email, String code) async {
        try {
            var response = await Cognito.confirmSignUp(email, code);
            print(response);
        } catch (e) {
            print("Error: Unable to verify");
            print(e);
        }
    }

    @action
    Future<void> resendCode(String email) async {
        try {
            var response = await Cognito.resendSignUp(email);
            print(response);
        } catch (e) {
            print("Error: Resend code");
            print(e);
        }
    }

    @action
    Future<void> signOut() async {
        try {
            await Cognito.signOut();
        } catch (e) {
            print("Error signing out");
            print(e);
        }
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
