import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build (BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Settings page"),
        ),
        body: new Checkbox(
            value: false,
            onChanged: null
        )
    );
  }
}