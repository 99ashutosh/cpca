import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:pocketbase/pocketbase.dart';
import "secrets.dart";
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import "homepage.dart";
import "login-logout.dart";

final client = PocketBase(Secrets.pocketbase_url);


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CPCA',
      theme: ThemeData(
        brightness: Brightness.light,
        //colorSchemeSeed: const Color.fromRGBO(
        //    91, 255, 77, 1.0),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        //colorSchemeSeed: const Color.fromRGBO(
        //    91, 255, 77, 1.0),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: DummyPage(),
    );
  }
}class DummyPage extends StatelessWidget {

  Future<String?> getUserData() async {
    var deviceInfo = DeviceInfoPlugin();

    var androidDeviceInfo = await deviceInfo.androidInfo;
    var id = androidDeviceInfo.fingerprint;
    final adminAuthData = await client.admins.authViaEmail(
          Secrets.testEmail, Secrets.testPassword);

    final result = await client.records.getList(
        "users",
        page: 1,
        perPage: 20,
        filter: "device_id = '$id'",
        sort: "-created",
    );
    return result.toString();
  }

  bool shadowColor = false;
  double? scrolledUnderElevation;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);
    return SafeArea(
      child: Scaffold (
        body: FutureBuilder(
          builder: (ctx, snapshot) {
            // Checking if future is resolved or not
            if (snapshot.connectionState == ConnectionState.done) {
              // If we got an error
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} occurred',
                    style: const TextStyle(fontSize: 18),
                  ),
                );

                // if we got our data
              } else if (snapshot.hasData) {
                var jsonResponse = convert.jsonDecode(snapshot.data as String);
                final DateTime now = DateTime.now();
                final DateFormat formatter = DateFormat('yyyy-MM-dd');
                final String formatted = formatter.format(now);
                final DateTime todayTime = DateTime.parse(formatted);
                final DateTime loginExpiry = jsonResponse['items'].length == 0 ? todayTime : DateTime.parse(jsonResponse['items'][0]['login_expiry_at']);

                if (todayTime.compareTo(loginExpiry) == 0 || todayTime.compareTo(loginExpiry) > 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          LoginLogoutScreen()),
                    );
                  });
                } else if (todayTime.compareTo(loginExpiry) < 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                });
                    }


                return Container (
                  color: Colors.white,
                );
              }
            }

            // Displaying LoadingSpinner to indicate waiting state
            return const Center(
              child: CircularProgressIndicator(),
            );
          },

          // Future that needs to be resolved
          // inorder to display something on the Canvas
          future: getUserData(),
        ),
      ),
    );
  }
}

