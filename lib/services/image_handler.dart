
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class ImageHandler {

  final ImagePicker imagePicker = ImagePicker();

  //Singleton Pattern para el constructor
  ImageHandler();
  static final ImageHandler im = ImageHandler();


  Future<Uint8List> getImage(bool fromGallery) async {
    PickedFile pickedFile;
    double maxHeight = 480;
    double maxWidth = 720;
    if (fromGallery) {
      pickedFile = await imagePicker.getImage(source: ImageSource.gallery, maxHeight: maxHeight, maxWidth: maxWidth);
    }
    //si no es con la galeria, es con la camara
    else {
      pickedFile = await imagePicker.getImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front, maxHeight: maxHeight, maxWidth: maxWidth);
    }

    return await pickedFile.readAsBytes();
  }

  Uint8List firstPlane (CameraImage image) {
    return image.planes.first.bytes;
  }

  List<Uint8List> convertFilesToUint8List( List<File> imageFiles) {
    List<Uint8List> bytesPerImage;
    for (File photo in imageFiles) {
      bytesPerImage.add(photo.readAsBytesSync());
    }
    return bytesPerImage;
  }

}