import 'dart:typed_data';

import 'package:flutter/services.dart';

class MethodChannelService {

  //Singleton Pattern para el constructor
  MethodChannelService();
  static final MethodChannelService channel = MethodChannelService();

  static const platform = const MethodChannel('control_asistencia/flutter/canalDeDatos');


  Future<void> sendImageToNativeSDK(Uint8List image) async {
    try {
      return platform.invokeMethod('setImageToIdentify', [image]);
    } on PlatformException catch (e) {
      throw 'Unable to analyze the images sent';
    }
  }

  Future<int> onInit() async {
    try {
      int response = await platform.invokeMethod('onInit');
      return response;
    } on PlatformException catch(e) {
      throw 'Unable to receive a response';
    }
  }

  Future<void> sendUserArgumentsToNativeSDK(int userId, List<Uint8List> images) async {
    try{
      return platform.invokeMethod('setNewUser', <String, dynamic>{   'userId': userId,
                                                                      'images': images,
      });
    } on PlatformException catch(e) {
      throw 'Unable to reach new User data';
    }
  }
}