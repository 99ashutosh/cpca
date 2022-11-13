import 'package:cpca/homepage.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'dart:convert' as convert;
import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import "secrets.dart";
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

final clientAcc = PocketBase(Secrets.pocketbase_url);

class AccountCreateScreen extends StatefulWidget {
  @override
  State<AccountCreateScreen> createState() => AccountCreate();
}


class AccountCreate extends State<AccountCreateScreen> {

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.fingerprint; // unique ID on Android
    }
  }

  Future<bool> createAccount(String id, String username, String password) async {
    final adminAuthData = await clientAcc.admins.authViaEmail(Secrets.testEmail, Secrets.testPassword);

    final DateTime now = DateTime.now();
    final DateTime loginExpiry = DateTime(now.year, now.month, now.day + 7);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(loginExpiry);

    final body = <String, dynamic>{'device_id': id, 'user_name': username, 'password': password, 'login_expiry_at': DateTime.parse(formatted).toString()};
    final record = await clientAcc.records.create('users', body: body);
    var response = convert.jsonDecode(record.toString());
    if (response['code'] == 400 || response['code'] == 403) {
      return false;
    }
    return true;
  }

  TextEditingController userNameCntl = TextEditingController();
  TextEditingController passwordCntl = TextEditingController();
  TextEditingController repasswordCntl = TextEditingController();
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();


  @override
  Widget build (BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                final device_id = snapshot.data as String;
                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 100.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:[
                              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children:const [
                                Flexible(child: Text("Welcome to", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50))),
                              ]),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children:const [
                                Flexible(child: Text("CPCA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50))),
                              ]),
                              const SizedBox(height: 40),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children:const [
                                Flexible(child: Text("Create a new account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
                              ]),
                              const SizedBox(height: 40)
                            ]),
                      ),
                      Padding(
                        //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextField(
                          controller: userNameCntl,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'User name',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 15, bottom: 0),
                        //padding: EdgeInsets.symmetric(horizontal: 15),

                        child: TextField(
                          controller: passwordCntl,
                          obscureText: true,
                          cursorColor: Colors.black,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 15, bottom: 0),
                        //padding: EdgeInsets.symmetric(horizontal: 15),

                        child: TextField(
                          controller: repasswordCntl,
                          obscureText: true,
                          cursorColor: Colors.black,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Retype Password',
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 100,
                      ),
                      RoundedLoadingButton(
                        width: 100,
                        height: 75,
                        controller: _btnController,
                        loaderSize: 35,
                        //color: Colors.black,
                        successColor: Colors.green,
                        onPressed: () async {
                          if (passwordCntl.text == repasswordCntl.text) {
                            if (await createAccount(
                                device_id, userNameCntl.text.toString(),
                                passwordCntl.text.toString())) {
                              _btnController.success();
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) =>
                                      HomePage()),
                                );
                              });
                            } else {
                              _btnController.error();
                              Timer(const Duration(seconds: 3), () {
                                _btnController.reset();
                              });
                            }
                          } else {
                            _btnController.error();
                            Timer(const Duration(seconds: 3), () {
                              _btnController.reset();
                            });
                          }
                          },
                        child: const Icon(
                          Icons.arrow_forward,
                          size: 35.0,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 130,
                      ),
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
          future: _getId(),
        ),
      ),
    );
  }
}