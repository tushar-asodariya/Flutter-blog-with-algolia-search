import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
class UploadMultipleImageDemo extends StatefulWidget {
  String _displayName;
  String uid;
  UploadMultipleImageDemo(this._displayName, this.uid) : super();

  final String title = 'Firebase Storage';

  @override
  UploadMultipleImageDemoState createState() => UploadMultipleImageDemoState();
}

class UploadMultipleImageDemoState extends State<UploadMultipleImageDemo> {
  //
  bool launching = false;
  String _path;
  Map<String, String> _paths;
  String _extension;
  FileType _pickType;
  bool _multiPick = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<StorageUploadTask> _tasks = <StorageUploadTask>[];
  String _displayUserName;
  String dataId;
  final db = Firestore.instance;
  final _formKey = GlobalKey<FormState>();
  String title;
  String description;
  String mediaUrl;


  void openFileExplorer() async {
    try {
      _multiPick = false;
      _pickType = FileType.ANY;
      _path = null;
      if (_multiPick) {
        _paths = await FilePicker.getMultiFilePath(
            type: _pickType, fileExtension: _extension);
      } else {
        _path = await FilePicker.getFilePath(
            type: _pickType, fileExtension: _extension);
      }

    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
  }

 void  uploadToFirebase() {
    if(_tasks.length >0 )
      _tasks.clear();
    if (_multiPick) {
      _paths.forEach((fileName, filePath) => {upload(fileName, filePath)});
    } else
      if(_path != null){
      String fileName = _path.split('/').last;
      String filePath = _path;
      upload(DateTime.now().toString()+'_'+fileName, filePath);
    }
  }

  void upload(String fileName, String filePath) {
    _extension = fileName.toString().split('.').last;
    StorageReference storageRef =
    FirebaseStorage.instance.ref().child(fileName);
    final StorageUploadTask uploadTask = storageRef.putFile(
      File(filePath),

    );
    setState(() {
      _tasks.add(uploadTask);
    });

  }



  //String _bytesTransferred(StorageTaskSnapshot snapshot) {
 //   return '${snapshot.bytesTransferred}/${snapshot.totalByteCount}';
 // }

  void createData()  {

    if(_formKey.currentState.validate())
      {
        _formKey.currentState.save();
        //DocumentReference ref =
           uploadToFirebase();
        if(_tasks.isEmpty)
          uploadDataWithoudMedia(widget._displayName,widget.uid);
      }

  }


  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    if(_tasks.isNotEmpty) {
      _tasks.forEach((StorageUploadTask task) {
        final Widget tile = UploadTaskListTile(
            task: task,
            onDismissed: () => setState(() => _tasks.remove(task)),
            onComplete: () => uploadData(task.lastSnapshot.ref,widget._displayName, widget.uid));

        children.add(tile);
      });
    }


    return   Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Create  Post'),
        ),
        body:
        Container(
          padding: EdgeInsets.all(20.0),
          child:
          Form (
            key: _formKey,
            child:Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(widget._displayName,
                style: TextStyle(
                    fontSize: 30.0
                ),
              ),
              TextFormField(
                decoration: InputDecoration(

                  labelText: 'Title',
                ),
                validator: (String value) {
                  if(value.isEmpty){
                    return 'Please enter some title';
                  }
                  return null;
                },
                onSaved: (String value) => title = value,
              ),
              SizedBox(height: 10.0,),
              TextFormField(
                maxLines: 5,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)
                    ),
                    labelText: 'Description',
                    alignLabelWithHint: true
                ),
                validator: (String value) {
                  if(value.isEmpty){
                    return 'Please enter some details';
                  }
                  return null;
                },
                onSaved: (String value) => description = value,
              ),
              SizedBox(height: 10.0,),
              Center(
              child:FlatButton(

                child: Text('Upload Media', style: TextStyle(fontSize: 25.0, color: Colors.blue)),
                onPressed: () => openFileExplorer(),
              ),),
              SizedBox(height: 20.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(

                    onPressed: () {
                     title = '';
                     description = '';
                     mediaUrl = '';
                     _tasks.clear();
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.blue, fontSize: 20),
                    ),
                  ),
                  SizedBox(height: 5,width: 10,),
                  RaisedButton(
                    onPressed: () => createData() ,//=> Navigator.pop(context),
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.blue, fontSize: 20),
                    ),
                  )
                ],
              ),

              SizedBox(
                height: 20.0,
              ),
              Flexible(
                child: ListView(
                  children: children,
                ),
              ),



            ],
          ),
        ),),

    );




  }



  Future<void> uploadData(StorageReference ref,String email, String uid) async {



    final String url = await ref.getDownloadURL();

    mediaUrl = url;
    var uuid = Uuid();
    await db.collection('BlogDemo')
        .document(uid)
        .collection('allPost')
        .document()
        .setData
      (<String, dynamic>
      {
        ///uuid.v1().toString(): {
          'title': '$title',
          'desc': '$description',
          'mediaUrl': '$mediaUrl',
      'time':DateTime.now(),
      'email':'$email'
       // }
          });
    title = '';
    description = '';
    mediaUrl = '';
    _tasks.clear();
    print('Uploaded');
    Navigator.pop(context);


  }

  Future<void> uploadDataWithoudMedia(String email, String uid) async {



    //final String url = await ref.getDownloadURL();

    mediaUrl = "";
    var uuid = Uuid();
    await db.collection('BlogDemo')
        .document(uid)
        .collection('allPost')
        .document()
        .setData
      (<String, dynamic>
    {
      ///uuid.v1().toString(): {
      'title': '$title',
      'desc': '$description',
      'mediaUrl': '$mediaUrl',
      'time':DateTime.now(),
      'email':'$email'
      // }
    });
    title = '';
    description = '';
    mediaUrl = '';
    _tasks.clear();

    print('Uploaded');



    Navigator.pop(context);


  }

}



class UploadTaskListTile extends StatelessWidget {
  const UploadTaskListTile(
      {Key key, this.task, this.onDismissed, this.onComplete})
      : super(key: key);

  final StorageUploadTask task;
  final VoidCallback onDismissed;
  final VoidCallback onComplete;


  String get status {
    String result;
    if (task.isComplete) {
      if (task.isSuccessful) {
        result = 'Complete';
        onComplete();
      } else if (task.isCanceled) {
        result = 'Canceled';
      } else {
        result = 'Failed ERROR: ${task.lastSnapshot.error}';
      }
    } else if (task.isInProgress) {
      result = 'Uploading';
    } else if (task.isPaused) {
      result = 'Paused';
    }
    return result;
  }

  String _bytesTransferred(StorageTaskSnapshot snapshot) {
    return '${snapshot.bytesTransferred}/${snapshot.totalByteCount}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StorageTaskEvent>(
      stream: task.events,
      builder: (BuildContext context,
          AsyncSnapshot<StorageTaskEvent> asyncSnapshot) {
        Widget subtitle;
        if (asyncSnapshot.hasData) {
          final StorageTaskEvent event = asyncSnapshot.data;
          final StorageTaskSnapshot snapshot = event.snapshot;
          subtitle = Text('$status: ${_bytesTransferred(snapshot)} bytes sent');
        } else {
          subtitle = const Text('Starting...');
        }
        return Dismissible(
          key: Key(task.hashCode.toString()),
          onDismissed: (_) => onDismissed(),
          child: ListTile(
            title: Text('Upload Task #${task.hashCode}'),
            subtitle: subtitle,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Offstage(
                  offstage: !task.isInProgress,
                  child: IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: () => task.pause(),
                  ),
                ),
                Offstage(
                  offstage: !task.isPaused,
                  child: IconButton(
                    icon: const Icon(Icons.file_upload),
                    onPressed: () => task.resume(),
                  ),
                ),
                Offstage(
                  offstage: task.isComplete,
                  child: IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () => task.cancel(),
                  ),
                ),

              ],
            ),
          ),
        );
      },
    );
  }
}