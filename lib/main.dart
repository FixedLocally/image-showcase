import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:img_showcase/expandable_fab.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Showcase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Image Showcase'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool? hasImage;
  late File img;

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((value) {
      File file = File("${value.path}/test.png");
      img = file;
      setState(() {
        hasImage = file.existsSync();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (hasImage != null)
              if (hasImage!)
                Image.file(img)
              else
                const Text("No image found")
            else
              const CircularProgressIndicator()
          ],
        ),
      ),
      floatingActionButton: ExpandableFloatingActionButton(
        icon: const Icon(Icons.image),
        openIcon: const Icon(Icons.clear),
        items: const [
          ExpandableFloatingActionButtonItem(
            icon: Icon(Icons.collections),
            value: 0,
          ),
          ExpandableFloatingActionButtonItem(
            icon: Icon(Icons.camera),
            value: 1,
          ),
        ],
        onPressed: (i) {
          switch (i) {
            case 0:
              _chooseImage(ImageSource.gallery);
              break;
            case 1:
              _chooseImage(ImageSource.camera);
              break;
          }
        },
      ),
    );
  }

  void _chooseImage(ImageSource source) async {
    NavigatorState nav = Navigator.of(context);
    XFile? value = await ImagePicker().pickImage(source: source);
    if (value != null) {
      Uint8List bytes = await value.readAsBytes();
      nav.push(
        MaterialPageRoute(
          builder: (_) {
            return CropRoute(
              bytes: bytes,
              onCropped: (bytes) {
                // force the image to reload
                imageCache.clear();
                imageCache.clearLiveImages();
                // write and reload image
                img.writeAsBytes(bytes);
                setState(() {
                  hasImage = true;
                });
                nav.pop();
              },
            );
          },
        ),
      );
    }
  }
}

class CropRoute extends StatefulWidget {
  final Uint8List bytes;
  final void Function(Uint8List) onCropped;

  const CropRoute({
    Key? key,
    required this.bytes,
    required this.onCropped,
  }) : super(key: key);

  @override
  State<CropRoute> createState() => _CropRouteState();
}

class _CropRouteState extends State<CropRoute> {
  final CropController _controller = CropController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crop Image"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _controller.crop();
            },
          )
        ],
      ),
      body: Crop(
        controller: _controller,
        image: widget.bytes,
        onCropped: (img) {
          widget.onCropped(img);
        },
      ),
    );
  }
}
