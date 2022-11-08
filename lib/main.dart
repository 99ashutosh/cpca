import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
import "my-account.dart";
import "login-logout.dart";
import "settings.dart";


final List<int> _items = List<int>.generate(51, (int index) => index);
const List<String> list = <String>['Top Stories', 'Newest'];
final List<String> entries = <String>['A Story here!', 'Button', 'Comments'];
final List<int> colorCodes = <int>[600, 500, 100];


void main() {
  runApp(const AppBarApp());
}

class AppBarApp extends StatelessWidget {
  const AppBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: const Color(0xff6750a4),
        useMaterial3: true,
        //primaryColor: Color(0xFF6200EE),
      ),
      // Decide which user to login?
      // How to choose login screen or home screen
      home: const AppBarExample(),
    );
  }
}

class AppBarExample extends StatefulWidget {
  const AppBarExample({super.key});

  @override
  State<AppBarExample> createState() => _AppBarExampleState();
}

class _AppBarExampleState extends State<AppBarExample> {
  int _selectedDestination = 0;
  bool shadowColor = false;
  double? scrolledUnderElevation;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    bool _pinned = true;
    bool _snap = false;
    bool _floating = false;


    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: false,
            snap: true,
            floating: true,
            expandedHeight: 100.0,
            toolbarHeight: 100.0,
            //flexibleSpace: const FlexibleSpaceBar(
              title: const DropdownButtonExample(),
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
                        PopupMenuItem<int>(
                          value: 0,
                          child: Text("My Account"),
                        ),

                        PopupMenuItem<int>(
                          value: 1,
                          child: Text("Settings"),
                        ),

                        PopupMenuItem<int>(
                          value: 2,
                          child: Text("Logout"),
                        ),
                      ];
                    },
                    onSelected:(value){
                      if(value == 0){
                        Navigator.push(
                            context,
                            new MaterialPageRoute(builder: (context) => new AccountPage()),
                        );
                      } else if(value == 1){
                        Navigator.push(
                          context,
                          new MaterialPageRoute(builder: (context) => new SettingsScreen()),
                        );
                      }else if(value == 2){
                        Navigator.push(
                          context,
                          new MaterialPageRoute(builder: (context) => new LoginLogoutScreen()),
                        );
                      }
                    }
                ),
              ]
            //),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return Container(
                  alignment: Alignment.center,
                  // tileColor: _items[index].isOdd ? oddItemColor : evenItemColor,
                  //margin: const EdgeInsets.symmetric(vertical: 00.0),
                  height: 100.0,
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    itemCount: entries.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 50,
                        color: Colors.amber[colorCodes[index]],
                        child: Center(child: Text('${entries[index]}')),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                  ),
                );
              },
              childCount: 20,
            ),
          ),

        ],
      ),
    );
  }
}

class DropdownButtonExample extends StatefulWidget {
  const DropdownButtonExample({super.key});

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
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
