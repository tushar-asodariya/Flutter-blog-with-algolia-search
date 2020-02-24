import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login_demo/auth.dart';
import 'package:login_demo/auth_provider.dart';
import 'dart:math';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/scaled_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
class NewPost extends StatefulWidget{
  final String title;
  final String caption;

  NewPost(
  {
    Key key,
    this.title,
    this.caption
}) : super(key : key);
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost>{
  String _fileName;
  File _selectedFile;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  bool _hasValidMime = false;
  FileType _pickingType;
  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
  }

  void _openFileExplorer() async {
    _pickingType = FileType.ANY;
    _controller.text = _extension = '';
    _multiPick = false;
    if ( _hasValidMime) {
      setState(() => _loadingPath = true);
      try {
        if (_multiPick) {
          _path = null;
          _paths = await FilePicker.getMultiFilePath(
              type: _pickingType, fileExtension: _extension);
        } else {
          _paths = null;
          _path = await FilePicker.getFilePath(
              type: _pickingType, fileExtension: _extension);
        }
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return;
      setState(() {
        _loadingPath = false;
        _fileName = _path != null
            ? _path.split('/').last
            : _paths != null ? _paths.keys.toString() : '...';
      });
    }
    if(_path.isNotEmpty)
      _selectedFile = File(_path);
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10.0),
      child: Column(
        children: <Widget>[
          Text("New Post",

          style: TextStyle(
              fontSize: 30.0
          ),
          ),
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
            onPressed: _openFileExplorer,
          ),
          Builder(
            builder: (BuildContext context) => _loadingPath
                ? Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: const CircularProgressIndicator())
                : _path != null || _paths != null
                ? Container(
              padding: const EdgeInsets.only(bottom: 30.0),
              height: MediaQuery.of(context).size.height * 0.50,
              child:  Scrollbar(
                  child:  ListView.separated(
                    itemCount: _paths != null && _paths.isNotEmpty
                        ? _paths.length
                        : 1,
                    itemBuilder: (BuildContext context, int index) {
                      final bool isMultiPath =
                          _paths != null && _paths.isNotEmpty;
                      final String name = 'File $index: ' +
                          (isMultiPath
                              ? _paths.keys.toList()[index]
                              : _fileName ?? '...');
                      final path = isMultiPath
                          ? _paths.values.toList()[index].toString()
                          : _path;

                      return  ListTile(
                        title:  Text(
                          name,
                        ),
                        subtitle:  Text(path),
                      );
                    },
                    separatorBuilder:
                        (BuildContext context, int index) =>
                     Divider(),
                  )),
            )
                :  Container(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(

                onPressed: () {},//=> Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.blue, fontSize: 20),
                ),
              ),
              SizedBox(height: 5,width: 10,),
              RaisedButton(
                onPressed: () {},//=> Navigator.pop(context),
                child: Text(
                  "Save",
                  style: TextStyle(color: Colors.blue, fontSize: 20),
                ),
              )
            ],
          )

        ],
      )
    )
    ;
  }

}