import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build (BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Account page"),
        ),
        body: new Checkbox(
            value: false,
            onChanged: null
        )
    );
  }
}