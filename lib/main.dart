import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() {
  runApp(Phoenix(child: MyApp()));}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp( debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Center(child: MyPage())));
  }
}

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  /// Variables
  File imageFile;
  String result;
  String path;
  var resultlabel;
  var resultConfidence;
  var index;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModel().then((value){
      setState(() {});
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Tflite.close();
  }


  loadModel() async{
    await Tflite.loadModel(
        model: 'assets/hastalik.tflite', labels: 'assets/labels.txt');
  }


  /// Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Center(child: Text("Pneumonia Detection")),
        ),
        body: Container(
            child: imageFile == null
                ? Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left:100,right:100),
                    child: OutlinedButton(
                      onPressed: () {
                        GaleridenSec();
                      },
                      child: Row(children: [Icon(Icons.photo_size_select_actual_outlined),Padding(
                        padding: const EdgeInsets.only(left:30),
                        child: const Text('Galeriden Seç',style: TextStyle(fontSize: 16),),
                      )],),
                    ),
                  ),
                  Container(
                    height: 40.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left:100,right:100),
                    child: OutlinedButton(
                      onPressed: () {
                        KameradanSec();
                      },
                      child: Row(children: [Icon(Icons.camera_alt_outlined),Padding(
                        padding: const EdgeInsets.only(left:30),
                        child: const Text('Kameradan Seç',style: TextStyle(fontSize: 16),),
                      )],),
                    ),
                  ),
                ],
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
                    child: result == null ? OutlinedButton(
                      onPressed: () {
                        _classifyImage();
                      },
                      child: const Text('Classify Image',style: TextStyle(fontSize: 16),),
                    ) : null),
                result == null ? Text('') : Text("Olasılık:  %" + ((resultConfidence * 100).round()).toString() +  "  Tahmini Sonuç:  " + resultlabel)
              ],
            )),
      floatingActionButton: imageFile == null ? null : FloatingActionButton(child: Icon(Icons.home),onPressed: (){
        Phoenix.rebirth(context);
      },),);
  }

  /// Get from gallery
  GaleridenSec() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 224,
      maxHeight: 224,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        path = pickedFile.path;
      });
    }
  }

  /// Get from Camera
  KameradanSec() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        path = pickedFile.path;
      });
    }
  }

  _classifyImage() async {
    await Tflite.loadModel(model: "assets/hastalik.tflite",labels: "assets/labels.txt");
    var output = await Tflite.runModelOnImage(
        path: path ?? "",
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5
    );  setState(() {
      result = output.toString();
      resultlabel = output.elementAt(0)['label'];
      index = output.elementAt(0)['index'];
      resultConfidence = output.elementAt(0)['confidence'];
      print(result);
      print(resultlabel);
      print(index);
      print(resultConfidence);
    });

  }
}
