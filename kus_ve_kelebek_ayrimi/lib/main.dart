import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() => runApp(MaterialApp(
  theme: ThemeData(
    canvasColor: Colors.brown,
  ),
  home: MyApp(),
));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List _outputs;
  File _image;


  @override
  void initState() {//hayati degere sahip bu kod
    //en başta  çalışacak kod gibi bişey oluyor
    // Çerçeve, oluşturduğu her State nesnesi için bu yöntemi tam olarak bir kez çağıracaktır .
    super.initState();
    loadModel().then((value) {
      setState(() {
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuş & kelebek tanıma'),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(2.0, 40.0, 2.0, 100.0),
        child: Column(
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 4,
              child: Center(
                child: _image == null
                    ? Text("Lütfen kuş ya da kelebek resmi gösterin")
                    : Image.file(_image),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            _outputs != null
                ? Text(
              "${_outputs[0]["label"]}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 27.0,
                background: Paint()..color = Colors.orange,
              ),
            )
                : Text("null")
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.fromLTRB(30.0, 0, 0, 0),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceEvenly, //Aradaki boşlugu ayarlıyor
          children: [
            FloatingActionButton(
              onPressed: pickImage2,
              child: Icon(Icons.image),
            ),
            FloatingActionButton(
              onPressed: pickImage,
              child: Icon(Icons.camera_alt),
            ),
          ],
        ),
      ),
    );
  }

  pickImage2() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      // _loading = true;
      _image = image;
    });
    classifyImage(image);
  }

  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _image = image;
    });
    classifyImage(image);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      //  _loading = false;
      _outputs = output;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
