import 'package:control_asistencia/services/database_connection_service.dart';
import 'package:control_asistencia/services/methodChannel_service.dart';
import 'package:control_asistencia/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserController {

  static const String STATE_CREATED_SUCCESFUL = "User Created Succesfully";
  static const String STATE_IN_PROCESS = "Processing Data";
  static const String STATE_CREATION_FAILED = "User not created";

  String nameFromForm;
  String phoneNumberFromForm;
  String currentState;
  MethodChannelService methodChannelService;
  bool finishCreationProcess = false;

  void inputNewUser(String name, String phoneNumber) {
    this.nameFromForm = name;
    this.phoneNumberFromForm = phoneNumber;
    this.currentState = UserController.STATE_IN_PROCESS;
  }

  Future<void> createNewUser() async{
    User newUser = new User(name: nameFromForm, phoneNumber: phoneNumberFromForm);

    //insertando el user a la base de datos de marcaje....
    int res = await DBProvider.db.insertUser(newUser);


    //insertando el user al SDK
    //MethodChannelService.channel.sendUserArgumentsToNativeSDK(nameFromForm, images);

    if (res != 0) { //si se crea correctamente res = id del usuario creado
      this.currentState = UserController.STATE_CREATED_SUCCESFUL;
    } else {
      this.currentState = UserController.STATE_CREATION_FAILED;
    }
    finishCreationProcess = true;
  }




}