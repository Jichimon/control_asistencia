import 'dart:typed_data';

import 'package:flutter/services.dart';

class MethodChannelService {

  //Singleton Pattern para el constructor
  MethodChannelService();
  static final MethodChannelService channel = MethodChannelService();

  static const platform = const MethodChannel('control_asistencia/flutter/canalDeDatos');


  Future<int> sendImageToNativeSDK(Uint8List image) async {
    try {
      return await platform.invokeMethod('setImageToIdentify', image);

      // -10 si no detectó un rostro en la imagen
      // -1 si no existe un match con un template de la DB

    } on PlatformException catch (e) {
      throw e.toString();
    }
  }

  Future<int> onInit() async {
    try {
      Future<int> response = platform.invokeMethod('onInit');
      return response;
    } on PlatformException catch(e) {
      throw e.toString();
    }
  }

  Future<int> sendUserArgumentsToNativeSDK(int userId, List<Uint8List> images) async {
    try{
      return platform.invokeMethod('setNewUser', <String, dynamic>{   'userId': userId,
                                                                      'images': images,
      });
    } on PlatformException catch(e) {
      throw e.toString();
    }
  }
}