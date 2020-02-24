import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login_demo/auth.dart';
import 'package:login_demo/auth_provider.dart';
import 'dart:math';
import 'package:login_demo/auth.dart';
import 'package:login_demo/auth_provider.dart';

import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/scaled_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:algolia/algolia.dart';
import 'package:login_demo/fileUploadDownload.dart';
class HomePage extends StatelessWidget {

  const HomePage({this.onSignedOut});
  final VoidCallback onSignedOut;

  Future<void> _signOut(BuildContext context) async {
    try {
      final BaseAuth auth = AuthProvider.of(context).auth;
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }
  void getUsernamId(BuildContext context) async {
    String displayName;
    String uid;
    final BaseAuth auth = AuthProvider.of(context).auth;
    await auth.currentUser().then((String userId) {
      uid = userId;


    });
    await auth.currentUserName().then((String userName) {

      displayName = userName;


    });

    Navigator.push<dynamic>(context, MaterialPageRoute<dynamic>(
        builder: (_) => UploadMultipleImageDemo(displayName, uid)
    ));
  }
  @override//new blog
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog'),
        actions: <Widget>[
          FlatButton(
            child: Text('Logout', style: TextStyle(fontSize: 17.0, color: Colors.white)),
            onPressed: () => _signOut(context),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => getUsernamId(context),
          )
        ],
      ),
      body: Container(
        child: Home()//FilePickerDemo()//NewPost()//
      ),
    );
  }
}

class Post {
  final String title;
  final String body;

  Post(this.title, this.body);
}

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //TextEditingController _searchText = TextEditingController(text: "thir");
  List<AlgoliaObjectSnapshot> _results = [];
  String searchQuery;
  bool _searching = false;
  final _homeFormKey = GlobalKey<FormState>();
  void _search() async {
    if(_homeFormKey.currentState.validate()) {
      _homeFormKey.currentState.save();
      setState(() {
        _searching = true;
      });

      Algolia algolia = Algolia.init(
        applicationId: 'TSHPKTI8ZT',
        apiKey: '5c60f765d535b31c71926630dd111d4f',
      );

      AlgoliaQuery query = algolia.instance.index('users');

      query = query.search(searchQuery);
      _results.clear();
      _results = (await query.getObjects()).hits;
      
      setState(() {
        _searching = false;
      });
    }
  }


  final SearchBarController<Post> _searchBarController = SearchBarController();
  bool isReplay = false;

  Future<List<Post>> _getALlPosts(String text) async {

    await Future.delayed(
        Duration(seconds: text.length == 4 ? 10 : 1),
        ()  {

        }
    );
    //if (isReplay) return [Post("Replaying !", "Replaying body")];
    if (text.length == 5) throw Error();
    if (text.length == 6) return [];
    List<Post> posts = [];

    var random = new Random();
    for (int i = 0; i < 10; i++) {
      posts.add(Post(
          "$text $i", "body random number : ${random.nextInt(100)}"));
    }

    return posts;
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child:
        Form (
        key: _homeFormKey,
        child:Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
        Text("Search",),

        TextFormField(
        decoration: InputDecoration(
          hintText: "Search query here...",

        ),
        validator: (String value) {
        if(value.isEmpty){
        return 'Please enter some title';
        }
        return null;
        },
        onSaved: (String value) => searchQuery = value,
        ),
        SizedBox(height: 10.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton(
                color: Colors.blue,
                child: Text(
                  "Search",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _search,
              ),
            ],
          ),
          Expanded(
            child: _searching == true
                ? Center(
              child: Text("Searching, please wait..."),
            )
                : _results.isEmpty
                ? Center(
              child: Text("No results found."),
            )
                : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (BuildContext ctx, int index) {
                AlgoliaObjectSnapshot snap = _results[index];
                print(snap.data.toString());
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      (index + 1).toString(),
                    ),
                  ),
                  title: Text(snap.data['title'] ),
                  subtitle: Text(snap.data['desc']),
                  trailing: Text(snap.data['email']),

                );
              },
            ),
          ),
        ],
      ),

        )
        /*Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Search"),
            TextField(
              decoration: InputDecoration(hintText: "Search query here..."),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  color: Colors.blue,
                  child: Text(
                    "Search",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _search,
                ),
              ],
            ),
            Expanded(
              child: _searching == true
                  ? Center(
                child: Text("Searching, please wait..."),
              )
                  : _results.isEmpty
                  ? Center(
                child: Text("No results found."),
              )
                  : ListView.builder(
                itemCount: _results.length,
                itemBuilder: (BuildContext ctx, int index) {
                  AlgoliaObjectSnapshot snap = _results[index];
                  print(snap.data.toString());
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        (index + 1).toString(),
                      ),
                    ),
                    title: Text(snap.data['title']),
                    subtitle: Text(snap.data['desc']),
                  );
                },
              ),
            ),
          ],
        ),*/
      )
    );
  }
}

class Detail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Text("Detail"),
          ],
        ),
      ),
    );
  }
}

void _newPost(BuildContext context)
{
  Alert(
      context: context,
      title: "New Post",
      content: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(

              labelText: 'Title',
            ),
          ),
          SizedBox(height: 10.0,),
          TextField(
            maxLines: 5,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0)
              ),
              labelText: 'Description',
              alignLabelWithHint: true
            ),
          ),
          SizedBox(height: 10.0,),
          FlatButton(

            child: Text('Upload Media', style: TextStyle(fontSize: 17.0, color: Colors.blue)),
            onPressed: () {},
          ),
        ],
      ),
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Save",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ]).show();
}