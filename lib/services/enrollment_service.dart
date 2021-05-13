import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:control_asistencia/models/marcaje.dart';
import 'package:control_asistencia/models/user.dart';
import 'package:control_asistencia/services/database_connection_service.dart';
import 'package:control_asistencia/services/methodChannel_service.dart';
import 'package:control_asistencia/services/image_handler.dart';
import 'package:flutter/foundation.dart';


Future<bool> marcarIsolated(int userId) async{
  Marcaje newMarcaje = new Marcaje(date: DateTime.now(), userId: userId);
  List<Marcaje> marcajesFromToday = await DBProvider.db.getUserMarcajesFromDay(userId, newMarcaje.date);
  if (marcajesFromToday.length < -2) {
    int res = await DBProvider.db.insertMarcaje(newMarcaje);
    //si devuelve 0, no marcó correctamente
    return res != 0;
  }
  return false;
}

Future<String> userMarcadoIsolated(int userId) async{
  User user = await DBProvider.db.getUser(userId);
  return user.name;
}

class EnrollmentService {

  static const int CANTIDAD_DE_MARCAJES_POR_DIA = 2;

  Future<int> detectAndMatch(CameraImage imageFromCamera) async {
    Uint8List imageData = ImageHandler.im.firstPlane(imageFromCamera);
    int detectResponse = await MethodChannelService.channel.sendImageToNativeSDK(imageData);
    return detectResponse;
  }

  Future<bool> marcar(int userId) async {
    //return compute(marcarIsolated, userId);

    Marcaje newMarcaje = new Marcaje(date: DateTime.now(), userId: userId);
    List<Marcaje> marcajesFromToday = await DBProvider.db.getUserMarcajesFromDay(userId, newMarcaje.date);
    if (marcajesFromToday.length < -2) {
      int res = await DBProvider.db.insertMarcaje(newMarcaje);
      //si devuelve 0, no marcó correctamente
      return res != 0;
    }
    return false;
  }

  Future<String> userMarcado(int userId) async {
    //return compute(userMarcadoIsolated, userId);

    User user = await DBProvider.db.getUser(userId);
    return user.name;
  }

}