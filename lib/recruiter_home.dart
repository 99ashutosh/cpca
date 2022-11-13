import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert' as convert;
import "my-account.dart";
import "login-logout.dart";
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import "secrets.dart";
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

final clientRecruiter = PocketBase(Secrets.pocketbase_url);

class RecruiterPage extends StatelessWidget {

  Future<String> getData() async {
    final adminAuthData = await clientRecruiter.admins.authViaEmail(
        Secrets.testEmail, Secrets.testPassword);

    final user_creds = await clientRecruiter.records.getList(
      "users",
      page: 1,
      perPage: 20,
      filter: "type = 'programmer'",
      sort: "-created",
    );

    var jsonResponse = convert.jsonDecode(user_creds.toString());

    return user_creds.toString();
  }


  Future<void> logout() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      var t = iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      var id = androidDeviceInfo.fingerprint; // unique ID on Android

      final adminAuthData = await clientRecruiter.admins.authViaEmail(
          Secrets.testEmail, Secrets.testPassword);

      final DateTime now = DateTime.now();
      //final DateTime loginExpiry = DateTime(now.year, now.month, now.day + 7);
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      final String formatted = formatter.format(now);

      final user_creds = await clientRecruiter.records.getList(
        "users",
        page: 1,
        perPage: 20,
        filter: "device_id = '$id'",
        sort: "-created",
      );

      var jsonResponse = convert.jsonDecode(user_creds.toString());

      final body = <String, dynamic>{
        'login_expiry_at': DateTime.parse(formatted).toString()
      };
      final record = await clientRecruiter.records.update(
          'users', jsonResponse['items'][0]['id'], body: body);
    }
  }

  bool shadowColor = false;
  double? scrolledUnderElevation;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);
    return SafeArea(
      child: Scaffold(
        appBar:AppBar(
            title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Row(children:const [
                    Flexible(child: Text('CPCA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
                  ]),
                  Row(children: const[
                    Flexible(child: Text('A KONTESTS App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                  ])
                ]),
            scrolledUnderElevation: scrolledUnderElevation,
            shadowColor: shadowColor ? Theme.of(context).colorScheme.shadow : null,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.search_rounded),
                tooltip: 'Search',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Search: Not implemented yet')));
                },
              ),
              PopupMenuButton(
                // add icon, by default "3 dot" icon
                // icon: Icon(Icons.book)
                  itemBuilder: (context){
                    return [
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text("My Account"),
                      ),


                      const PopupMenuItem<int>(
                        value: 2,
                        child: Text("Logout"),
                      ),
                    ];
                  },
                  onSelected:(value){
                    if(value == 0){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AccountPage()),
                      );
                    } else if(value == 2){
                      logout();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              LoginLogoutScreen()),
                        );
                      });
                    }
                  }
              ),
            ]
        ),
        body: FutureBuilder(
          builder: (context, snapshot) {
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
                final data = snapshot.data.toString();
                var jsonResponse = convert.jsonDecode(data);
                var userJson = jsonResponse['items'];
                print(userJson);
                final List<int> _items = List<int>.generate(jsonResponse['items'].length, (int index) => index);
                return GridView.builder(
                  shrinkWrap: true,
                  itemCount: jsonResponse['items'].length,
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 5.0,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: evenItemColor,
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:[
                              Row(children:[
                                Flexible(child: Padding (padding: const EdgeInsets.only(left: 5),
                                  child: Text(userJson[index]['user_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                ),
                                )]),

                            ]),
                      ),
                      onTap: ()  {},
                    );
                  },
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
          future: getData(),
        ),
      ),
    );
  }
}