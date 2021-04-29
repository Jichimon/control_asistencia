
import 'dart:typed_data';

import 'package:control_asistencia/services/image_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageHandlerWidget extends StatefulWidget {

  static const FROM_GALLERY = true;
  static const FROM_CAMERA = false;

  @override
  ImageHandlerWidgetState createState() =>
      ImageHandlerWidgetState();


}

class ImageHandlerWidgetState extends State<ImageHandlerWidget> {

  static List<Uint8List> images = [];

  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          Container(
            height: 100,
            child: listaDeImagenes(),
          )
        ],
    );
  }

  Widget listaDeImagenes() {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return buildAddPhoto();
          }
          Uint8List image = images[index - 1];
          return Stack(
            children: <Widget>[
              showImage(image),
            ],
          );
        },
    );

  }

  Widget showImage(Uint8List image) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.all(5),
        height: 100,
        width: 100,
        color: Colors.white24,
        child: Image.memory(image),
      ),
    );
  }

  Widget buildAddPhoto() {
    return InkWell(
      onTap: () => showSelectionDialog(context),
      child: Container(
        margin: EdgeInsets.all(5),
        height: 100,
        width: 100,
        color: Colors.black38,
        child: Center(
          child: Icon(
            Icons.add_to_photos,
            color: Colors.white38,
          ),
        ),
      ),
    );
  }


  Future<void> showSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("De dónde quieres tomar la foto?"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: Text("Galería"),
                      onTap: () {
                        debugPrint("++++++++++++++++++++++++++++++++++++++++++++++ " + images.length.toString());
                        setImage(context, ImageHandlerWidget.FROM_GALLERY);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Text("Cámara"),
                      onTap: () {
                        setImage(context, ImageHandlerWidget.FROM_CAMERA);
                      },
                    )
                  ],
                ),
              ));
        });
  }

  void setImage(context, bool fromGallery) async {
    Uint8List image = await ImageHandler.im.getImage(fromGallery);
    setState(() {
      if (image != null) {
        images.add(image);
        debugPrint(" ++++++++++++++++++++++++++++++++   image exists");
        debugPrint("++++++++++++++++++++++++++++++++++++++++++++++ " + images.length.toString());
      }
    });
    Navigator.of(context).pop();
  }


}