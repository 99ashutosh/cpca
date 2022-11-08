import 'package:flutter/material.dart';

class LoginLogoutScreen extends StatelessWidget {
  @override
  Widget build (BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("This is the logout page!"),
        ),
        body: new Checkbox(
            value: false,
            onChanged: null
        )
    );
  }
}