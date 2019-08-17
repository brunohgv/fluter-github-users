import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new AppState();
  }
}

class AppState extends State<App> {
  bool _loading = true;
  var _users = [];
  int _lastId = 0;

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _fetchMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future _fetchMore() async {
    final String url = 'https://api.github.com/users?since=$_lastId&per_page=20';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        this._users.addAll(json.decode(response.body));
      });
    }
    setState(() {
      _loading = false;
      _lastId = this._users[this._users.length - 1]['id'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('App List'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  this._loading = true;
                });
                _fetchMore();
              },
            )
          ],
        ),
        body: Center(
          child: this._loading ? CircularProgressIndicator() :
          Center(
            child: ListView.separated(
              itemCount: this._users.length - 1,
              separatorBuilder: (context, i) {
                return Divider();
              },
              controller: this._scrollController,
              itemBuilder: (context, i) {
                final _user = this._users[i];
                return Row(
                  children: <Widget>[
                    Image.network(
                      _user['avatar_url'],
                      fit: BoxFit.contain,
                      height: 60,
                      width: 60,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _user['login'],
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          InkWell(
                            child: Text(
                              _user['html_url'],
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                            onTap: () => launch(_user['html_url']),
                          )
                        ],
                      ),
                    ),
                    Divider(),
                  ],
                );
              },
              
            ),
          ),
        ),
      ),
    );
  }
}