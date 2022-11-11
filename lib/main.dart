import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert' as convert;
import "my-account.dart";
import "login-logout.dart";
import "settings.dart";

const List<String> list = <String>['KONTESTS','Top Stories', 'Newest'];
final List<String> entries = <String>['A Story here!', 'Button', 'Comments'];
final List<int> colorCodes = <int>[600, 500, 100];



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CPCA',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xff6750a4),
        useMaterial3: true,
        //primaryColor: Color(0xFF6200EE),
      ),
      // to hide debug banner
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {

  Future<String> getData() async {
    var url = Uri.parse('https://kontests.net/api/v1/all');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      return response.body.toString();
      //print({response.body});
    }
    return response.statusCode.toString();
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
          title: const DropdownMenu(),
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
                        value: 1,
                        child: Text("Settings"),
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
                    } else if(value == 1){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsScreen()),
                      );
                    }else if(value == 2){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginLogoutScreen()),
                      );
                    }
                  }
              ),
            ]
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
                    style: TextStyle(fontSize: 18),
                  ),
                );

                // if we got our data
              } else if (snapshot.hasData) {
                // Extracting data from snapshot object
                final data = snapshot.data as String;
                var jsonResponse = convert.jsonDecode(data);
                final List<int> _items = List<int>.generate(jsonResponse.length, (int index) => index);
                return GridView.builder(
                  shrinkWrap: true,
                  itemCount: jsonResponse.length,
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
                          color: _items[index].isOdd ? oddItemColor : evenItemColor,
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:[
                              Row(children:[
                                Flexible(child: Text(jsonResponse[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
                              ]),
                              Row(children:[
                                Flexible(child: Text(jsonResponse[index]['site'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                              ])
                            ]),
                      ),
                      onTap: () async {
                        var compUrl = Uri.parse(jsonResponse[index]['url']);
                        if (await canLaunchUrl(compUrl)) {
                          await launchUrl(compUrl,  mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error has occurred')));
                        }
                      },
                    );
                  },
                );
              }
            }

            // Displaying LoadingSpinner to indicate waiting state
            return Center(
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

class DropdownMenu extends StatefulWidget {
  const DropdownMenu({super.key});

  @override
  State<DropdownMenu> createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<DropdownMenu> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      underline: Container(
        height: 0,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),

        );
      }).toList(),
    );
  }
}