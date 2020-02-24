import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
class FilePickerDemo extends StatefulWidget {
  @override
  _FilePickerDemoState createState() =>  _FilePickerDemoState();
}

class _FilePickerDemoState extends State<FilePickerDemo> {
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  bool _hasValidMime = false;
  FileType _pickingType;
  File _selectedFile;
  TextEditingController _controller =  TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
  }

  void _openFileExplorer() async {
    _pickingType = FileType.ANY;
    _multiPick = false;
    if (_pickingType != FileType.CUSTOM || _hasValidMime) {
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
    return   Scaffold(

        body:  Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50.0),
              child:  SingleChildScrollView(
                child:  Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
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

                      child: Text('Upload Media', style: TextStyle(
                          fontSize: 25.0, color: Colors.blue)),
                      onPressed: () => _openFileExplorer(),
                    ),

                    /*RaisedButton(
                        onPressed: () => _openFileExplorer(),
                        child:  Text("Open file picker"),
                      ),*/

                  SizedBox(height: 20,),
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
                          onPressed: ()  {
                            final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(_fileName);
                            final StorageUploadTask uploadTask = firebaseStorageRef.putFile(_selectedFile);

                          },//=> Navigator.pop(context),
                          child: Text(
                            "Save",
                            style: TextStyle(color: Colors.blue, fontSize: 20),
                          ),
                        )
                      ],
                    ),
                    Builder(
                      builder: (BuildContext context) => _loadingPath
                          ? Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: const CircularProgressIndicator())
                          : _path != null || _paths != null
                          ?  Container(
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
                                final String name = 'File Name : ' +
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

                  ],
                ),
              ),
            ),

    );
  }
}