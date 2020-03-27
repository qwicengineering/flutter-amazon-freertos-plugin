import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:flutter_mobx/flutter_mobx.dart";

import "cognito/cognito.store.dart";

class LoginScreen extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        final cognitoStore = Provider.of<CognitoStore>(context);

        return Observer(name: "LoginScreen",
            builder: (_) => Scaffold(
                body: Column(
                    children: <Widget>[
                        Text("${cognitoStore.value}")
                    ],
                )
            )
        );
    }   
}
