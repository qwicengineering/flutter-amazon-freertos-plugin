import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:flutter_mobx/flutter_mobx.dart";

import "stores/auth/auth_form.store.dart";
import "stores/cognito/cognito.store.dart";

class LoginScreen extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        final authStore = Provider.of<AuthFormStore>(context);
        final cognitoStore = Provider.of<CognitoStore>(context);

        return Observer(name: "LoginScreen",
            builder: (_) => Scaffold(
                appBar: AppBar(
                    title: Text("Login screen")
                ),
                body: Column(
                    children: <Widget>[
                        Text("This is a text ${cognitoStore.value}")
                    ],
                )
            )
        );
    }   
}
