import 'dart:typed_data';

import 'package:control_asistencia/services/database_connection_service.dart';
import 'package:control_asistencia/services/methodChannel_service.dart';
import 'package:control_asistencia/models/user.dart';

class UserController {

  static const String STATE_CREATED_SUCCESSFUL = "User Created Successfully";
  static const String STATE_IN_PROCESS = "Processing Data";
  static const String STATE_CREATION_FAILED = "User not created";


  String currentState;
  MethodChannelService methodChannelService;
  bool finishCreationProcess = false;

  Future<void> createNewUser(String nameFromForm, String phoneNumberFromForm, List<Uint8List> imagesFromForm) async{

    User newUser = new User(name: nameFromForm, phoneNumber: phoneNumberFromForm);

    //insertando el user a la base de datos de marcaje....
    int res = await DBProvider.db.insertUser(newUser);

    if (res != 0) { //si se crea correctamente res = id del usuario creado
      //enviando la info del user al SDK
      int response = await MethodChannelService.channel.sendUserArgumentsToNativeSDK(res, imagesFromForm);
      print(response);
      this.currentState = UserController.STATE_CREATED_SUCCESSFUL;
    } else {
      this.currentState = UserController.STATE_CREATION_FAILED;
    }
    finishCreationProcess = true;
  }




}