import 'dart:io';

import 'package:camera/camera.dart';
import 'package:control_asistencia/services/methodChannel_service.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Camera extends StatefulWidget {

  @override
  CameraState createState() {
    return CameraState();
  }
}

class CameraState extends State<Camera> {

  static bool isStreamming = true;

  CameraController controller;
  Future<void> initializeControllerFuture;
  List<CameraDescription> cameras;
  int selectedCameraIndex;
  bool isOpen;
  bool isDetecting = false;



  Future initCamera(CameraDescription cameraDescription) async{
    if( controller != null) {
      await controller.dispose();
    }

    if (Platform.isAndroid) {
      controller = CameraController(cameraDescription, ResolutionPreset.medium, imageFormatGroup: ImageFormatGroup.jpeg);
    } else if (Platform.isIOS) {
      controller = CameraController(cameraDescription, ResolutionPreset.medium, imageFormatGroup: ImageFormatGroup.bgra8888);
    }

    controller.addListener(() {
      if (mounted) {
        setState(() { });
      }
    });

    if (controller.value.hasError) {
      print('Error de Camara ${controller.value.errorDescription}');
    }

    try {
      int res = await MethodChannelService.channel.onInit();
      debugPrint("CODIGO DE RESPUESTA POR PARTE DE LA PLATAFORMA CON METHOD CHANNEL ON INIT:" + res.toString());
      initializeControllerFuture = controller.initialize();
      initializeControllerFuture.whenComplete(() => streaming() );
    } catch(e) {
      String error = 'Error ${e.code} \nError message: ${e.description}';
      debugPrint(error);
    }
    if (mounted) {
      setState(() { isOpen = true; });
    }
  }


  Widget cameraPreview(){
    if (!isOpen) {
      initCamera(cameras[selectedCameraIndex]).then((value) { });
    }
    return FutureBuilder<void>(
      future: initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          //si el controlador (future) está inicializado, mostramos el preview
          return CameraPreview(controller);
        } else {
          //si no, mostramos un indicador de carga
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }


  void streaming(){
    controller.startImageStream((image) => {
      //debugPrint("streaming + image planes:" + image.planes.length.toString())
      //TODO para cada imagen, detectar si hay un rostro

      //TODO para cada imagen con rostro, buscar el match

      //TODO enrollment service

    });
  }


  @override
  void initState() {
    super.initState();
    //comprobamos las camaras que hay en el equipo
    availableCameras().then((value) {
      cameras = value;
      if(cameras.length > 0){
        setState(() {
          //  seleccionar la camara para trabajar
          //  0 -> camara trasera
          //  1 -> camara frontal
          selectedCameraIndex = 1;
        });
        initCamera(cameras[selectedCameraIndex]).then((value) {
        });
      } else {
        print('No camera available');
      }
    }).catchError((e){
      print('Error : ${e.code}');
    });
  }



  @override
  Widget build(BuildContext context) {
    return Container(child: cameraPreview());
  }


  @override
  Future<void> dispose() async{
    // Dispose of the controller when the widget is disposed.
    Future.delayed(Duration.zero, () async {
      //comentar esta linea de abajo si no funca
      await controller.stopImageStream();
      await controller.dispose();
      isOpen = false;
    });
    super.dispose();
  }


}