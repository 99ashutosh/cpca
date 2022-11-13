import 'package:cpca/create-account.dart';
import 'package:cpca/homepage.dart';
import 'package:cpca/recruiter_home.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pocketbase/pocketbase.dart';
import 'dart:io';
import 'dart:convert' as convert;
import 'dart:async';
import "secrets.dart";
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

final clientLog = PocketBase(Secrets.pocketbase_url);

class LoginLogoutScreen extends StatefulWidget {
  @override
  State<LoginLogoutScreen> createState() => LoginLogout();
}


class LoginLogout extends State<LoginLogoutScreen> {

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

  Future<int> login(String id, String username, String password) async {
    final adminAuthData = await clientLog.admins.authViaEmail(
        Secrets.testEmail, Secrets.testPassword);

    final DateTime now = DateTime.now();
    final DateTime loginExpiry = DateTime(now.year, now.month, now.day + 7);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(loginExpiry);

    final userCreds = await clientLog.records.getList(
      "users",
      page: 1,
      perPage: 20,
      filter: "device_id = '$id'",
      sort: "-created",
    );

    var jsonResponse = convert.jsonDecode(userCreds.toString());

    if (jsonResponse['totalItems'] != 0) {
      if (jsonResponse['items'][0]['user_name'] == username &&
          jsonResponse['items'][0]['password'] == password) {
        if (jsonResponse['items'][0]['type'] == 'programmer') {
          final body = <String, dynamic>{
            'login_expiry_at': DateTime.parse(formatted).toString()
          };
          final record = await clientLog.records.update(
              'users', jsonResponse['items'][0]['id'], body: body);
          _btnController.success();
          return 1;
        } else {
          final body = <String, dynamic>{
            'login_expiry_at': DateTime.parse(formatted).toString()
          };
          final record = await clientLog.records.update(
              'users', jsonResponse['items'][0]['id'], body: body);
          _btnController.success();
          return 2;
        }
      }
    }
    return 0;
  }



  TextEditingController userNameCntl = TextEditingController();
  TextEditingController passwordCntl = TextEditingController();
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
                                Flexible(child: Text("Log in to continue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
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
                      const SizedBox(
                        height: 130,
                      ),
                      RoundedLoadingButton(
                        width: 100,
                        height: 75,
                        controller: _btnController,
                        loaderSize: 35,
                        //color: Colors.black,
                        successColor: Colors.green,
                        onPressed: () async {
                          if (await login(device_id, userNameCntl.text.toString(), passwordCntl.text.toString()) == 1) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    HomePage()),
                              );
                            });
                          }else if (await login(device_id, userNameCntl.text.toString(), passwordCntl.text.toString()) == 2) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    RecruiterPage()),
                              );
                            });
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
                      ElevatedButton(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                        ),
                        onPressed: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  AccountCreateScreen()),
                            );
                          });
                        },
                        child: const Text('New Here? Create an Account'),
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
          future: _getId(),
        ),
      ),
    );
  }
}