
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';

import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class ImageHandler {

  List<File> images = [];
  final ImagePicker imagePicker = ImagePicker();

  Future getImage(bool fromGallery) async {
    PickedFile pickedFile;
    if (fromGallery) {
      pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    }
    //si no es con la galeria, es con la camara
    else {
      pickedFile = await imagePicker.getImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    }
  }

  Uint8List firstPlane (CameraImage image) {
    return image.planes.first.bytes;
  }



}