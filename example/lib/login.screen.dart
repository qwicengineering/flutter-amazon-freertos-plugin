import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:flutter_mobx/flutter_mobx.dart";

import "stores/auth/auth_form.store.dart";
import "stores/cognito/cognito.store.dart";

class LoginScreen extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        final authFormStore = Provider.of<AuthFormStore>(context);
        final cognitoStore = Provider.of<CognitoStore>(context);

        void _onPressedSignIn() async {
            try {
                await cognitoStore.signIn(authFormStore.email, authFormStore.password);
                Navigator.pushNamed(context, "/bluetoothDevices");
            } catch (e) {
                print("Error: Cognito _onPressedSignIn");
                print(e);
            }
        }

        void _onPressedRegister() async {
            try {
                await cognitoStore.register(authFormStore.email, authFormStore.password);
                Navigator.pushNamed(context, "/verifyUser");
            } catch (e) {
                print("Error: Cognito _onPressedRegister");
                print(e);
            }
        }

        return Observer(name: "LoginScreen",
            builder: (_) => Scaffold(
                appBar: AppBar(
                    title: Text("Login screen")
                ),
                body: Form(
                    child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                            children: <Widget>[
                                Observer(
                                    builder: (_) => TextField(
                                        onChanged: (value) => authFormStore.email = value,
                                        decoration: InputDecoration(
                                            labelText: "Email",
                                            hintText: "Enter email",
                                            errorText: authFormStore.error.email
                                        ),
                                    ),
                                ),
                                Observer(
                                    builder: (_) => TextField(
                                        onChanged: (value) => authFormStore.password = value,
                                        decoration: InputDecoration(
                                            labelText: "Password",
                                            hintText: "Enter password",
                                            errorText: authFormStore.error.password
                                        ),
                                    ),
                                ),
                                Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                            RaisedButton(
                                                child: Text("Log in"),
                                                onPressed: _onPressedSignIn,
                                            ),
                                            RaisedButton(
                                                child: Text("Register"),
                                                onPressed: _onPressedRegister,
                                            )
                                        ],
                                    ),
                                ),
                            ],
                        )
                    )
                )
            )
        );
    }   
}
