import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pocketbase/pocketbase.dart';
import 'dart:io';
import 'dart:convert' as convert;
import 'dart:async';

import "secrets.dart";
import 'package:rounded_loading_button/rounded_loading_button.dart';

final clientAcc = PocketBase(Secrets.pocketbase_url);

class AccountPage extends StatefulWidget {
  @override
  State<AccountPage> createState() => AccountPageS();
}


class AccountPageS extends State<AccountPage> {

  Future<String?> getAccountData() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      var deviceId = androidDeviceInfo.fingerprint; // unique ID on Android
      final adminAuthData = await clientAcc.admins.authViaEmail(Secrets.testEmail, Secrets.testPassword);
      final userCreds = await clientAcc.records.getList(
        "users",
        page: 1,
        perPage: 20,
        filter: "device_id = '$deviceId'",
        sort: "-created",
      );
      print(userCreds.toString());
      return userCreds.toString();


    }
  }

  TextEditingController userNameCntl = TextEditingController();
  TextEditingController passwordCntl = TextEditingController();
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();


  @override
  Widget build (BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            title: const Text('CPCA'),
        ),
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
                // Extracting data from snapshot object
                final jsonResponse = convert.jsonDecode(snapshot.data.toString());
                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 100.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:[
                              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                Flexible(child: Image.asset('assets/cpca_icon.png')),
                              ]),
                              const SizedBox(height: 130),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children:const [
                                Flexible(child: Text("Username: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19))),
                              ]),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                Flexible(child: Text( jsonResponse['items'][0]['user_name'] , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50))),
                              ]),
                              const SizedBox(height: 40),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children:const [
                                Flexible(child: Text("Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19))),
                              ]),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                Flexible(child: Text(jsonResponse['items'][0]['password'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50))),
                              ]),
                              const SizedBox(height: 40)
                            ]),
                      )
                    ],
                  ),
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
          future: getAccountData(),
        ),
      ),
    );
  }
}