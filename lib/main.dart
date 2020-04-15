import 'dart:convert';

import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:covid19_app/note.dart';
import 'package:covid19_app/global.dart';

void main() => runApp(MyApp());

// Add AWS Load Balancer URL here
var awsURl = 'http://a657c150480c74a08a74e5d7acfebc71-696643302.us-east-1.elb.amazonaws.com';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covid19 Dashboard',
      theme: ThemeData(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  List<Note> _countries = List<Note>();
  List<String> _labels = List<String>();
  List<int> _global = List<int>();

  Future<List<Note>> fetchCountries() async {
    var url = awsURl + '/countries';
    var response = await http.get(url);

    var notes = List<Note>();

    if (response.statusCode == 200) {
      var notesJson = json.decode(response.body);
      for (var noteJson in notesJson) {
        notes.add(Note.fromJson(noteJson));
      }
    }
    return notes;
  }

  Future<List<Note>> search(String search) async {
    //await Future.delayed(Duration(seconds: 2));

    var url = awsURl + '/countries/' + search;
    var response = await http.get(url);

    List<Note> _result = new List<Note>();

    if (response.statusCode == 200) {
      var resultJson = json.decode(response.body);
      _result.add(Note.fromJson(resultJson));
    }
    return _result;
  }

  Future<List<Global>> fetchAll() async {
    var url = awsURl + '/all';
    var response = await http.get(url);

    var all = List<Global>();
    all.add(new Global(0, 0, 0, 0));
    if (response.statusCode == 200) {
      var globalsJson = json.decode(response.body);
      all[0].cases = globalsJson["cases"];
      all[0].deaths = globalsJson["deaths"];
      all[0].recovered = globalsJson["recovered"];
      all[0].active = globalsJson["active"];
    }
    return all;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {

    fetchAll().then((value) {
      setState(() {
        _global.add(value[0].cases);
        _global.add(value[0].deaths);
        _global.add(value[0].recovered);
        _global.add(value[0].active);

        _labels.add("Coronavirus Cases");
        _labels.add("Deaths");
        _labels.add("Recovered");
        _labels.add("Active Cases");
      });
    });

    fetchCountries().then((value) {
      setState(() {
        _countries.addAll(value);
      });
    });
    super.initState();
  }

  // Search list
  _searchListView() {
    return SafeArea(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SearchBar<Note>(
            hintText: "Search Country",
            placeHolder: _countryListView(),
            loader: Text("loading..."),
            onSearch: search,
            onItemFound: (Note note, int index) {
              return Card(
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: 32.0, bottom: 32.0, left: 16.0, right: 16.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                note.country + "\n",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Cases: " + note.cases.toString(),
                                style: TextStyle(
                                    fontSize: 20, color: Colors.grey.shade600),
                              ),
                              Text(
                                "Deaths: " +
                                    note.deaths.toString() +
                                    ' | ' +
                                    "Critical: " +
                                    _countries[index].critical.toString(),
                                style: TextStyle(
                                    fontSize: 20, color: Colors.grey.shade600),
                              ),
                              Text(
                                "Recovered: " + note.recovered.toString(),
                                style: TextStyle(
                                    fontSize: 20, color: Colors.grey.shade600),
                              ),
                            ]),
                        new Container(
                          child: Image.network(
                            note.image["flag"],
                            scale: 4,
                          ),
                          alignment: Alignment.topCenter,
                        ),
                      ],
                    )),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 3,
                margin: EdgeInsets.all(10),
              );
            },
          )),
    );
  }

  // Global List
  _globalListView() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
              padding: const EdgeInsets.only(
                  top: 32.0, bottom: 32.0, left: 16.0, right: 16.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _labels[index],
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _global[index].toString(),
                          style: TextStyle(
                              fontSize: 40, color: Colors.grey.shade600),
                        ),
                      ])
                ],
              )),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 3,
          margin: EdgeInsets.all(10),
        );
      },
      itemCount: _global.length,
    );
  }

  // All Country List
  _countryListView() {
    return Scrollbar(
        child: ListView.builder(
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
              padding: const EdgeInsets.only(
                  top: 32.0, bottom: 32.0, left: 16.0, right: 16.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _countries[index].country + '\n',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Cases: " + _countries[index].cases.toString(),
                          style: TextStyle(
                              fontSize: 20, color: Colors.grey.shade600),
                        ),
                        Text(
                          "Deaths: " +
                              _countries[index].deaths.toString() +
                              ' | ' +
                              "Critical: " +
                              _countries[index].critical.toString(),
                          style: TextStyle(
                              fontSize: 20, color: Colors.grey.shade600),
                        ),
                        Text(
                          "Recovered: " +
                              _countries[index].recovered.toString(),
                          style: TextStyle(
                              fontSize: 20, color: Colors.grey.shade600),
                        ),
                      ]),
                  new Container(
                    child: Image.network(
                      _countries[index].image["flag"],
                      scale: 4,
                    ),
                    alignment: Alignment.topCenter,
                  ),
                ],
              )),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 3,
          margin: EdgeInsets.all(10),
        );
      },
      itemCount: _countries.length,
    ));
  }

  _screen(int index) {
    if (index == 0)
      return _globalListView();
    else if (index == 1) return _searchListView();

  }

  static List<Widget> _widgetOptions = <Widget>[
    Text(
      'All',
      style: optionStyle,
    ),
    Text(
      'Country Specific',
      style: optionStyle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Covid19 Pandemic'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: _screen(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            title: Text('Countries'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.pink,
      ),
    );
  }
}
