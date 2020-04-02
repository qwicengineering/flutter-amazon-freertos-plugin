import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:flutter_mobx/flutter_mobx.dart";

import "stores/auth/auth_form.store.dart";
import "stores/cognito/cognito.store.dart";

class VerifyUserScreen extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        final authFormStore = Provider.of<AuthFormStore>(context);
        final cognitoStore = Provider.of<CognitoStore>(context);

        void _onPressedVerify() async {
            try {
                await cognitoStore.verify(authFormStore.email, authFormStore.verificationCode);
                Navigator.pushNamed(context, "/bluetoothDevices");
            } catch (e) {
                print("Error: Unable to _onPressedVerify");
                print(e);
            }
        }

        void _onPressedResendCode() async {
            try {
                await cognitoStore.resendCode(authFormStore.email);
            } catch (e) {
                print("Error: Unable to resend code");
                print(e);
            }
        }

        return Observer(name: "VerifyUserScreen",
            builder: (_) => Scaffold(
                appBar: AppBar(
                    title: Text("Confirm")
                ),
                body: Form(
                    child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                            children: <Widget>[
                                Observer(
                                    builder: (_) => TextField(
                                        onChanged: (value) => authFormStore.verificationCode = value,
                                        decoration: InputDecoration(
                                            labelText: "Verification code",
                                            hintText: "Enter your verification code",
                                            errorText: authFormStore.error.email
                                        ),
                                    ),
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                        RaisedButton(
                                            child: Text("Verify"),
                                            onPressed: _onPressedVerify,
                                        ),
                                        RaisedButton(
                                            child: Text("Resend code"),
                                            onPressed: _onPressedResendCode,
                                        )
                                    ],
                                ),
                            ],
                        )
                    )
                )
            )
        );
    }   
}
