import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

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
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) {
                  return AlertDialog(
                    content: Row(
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(width: 10),
                        Text("Cropping, please wait..."),
                      ],
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
      body: Crop(
        controller: _controller,
        image: widget.bytes,
        onCropped: (img) {
          Navigator.pop(context);
          widget.onCropped(img);
        },
      ),
    );
  }
}
