
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageHandlerWidget extends StatefulWidget {
  @override
  ImageHandlerWidgetState createState() =>
      ImageHandlerWidgetState();
}

class ImageHandlerWidgetState extends State<ImageHandlerWidget> {

  List<File> photos = [];
  List<String> photosUrls = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 100,
            child: listaDeImagenes(),
          )
        ],
      )
    );
  }

  Widget listaDeImagenes() {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return buildAddPhoto();
          }
          File image = photos[index - 1];
          return Stack(
            children: [
              InkWell(
                child: ,
              )
            ],
          );

        },
    );

  }

}