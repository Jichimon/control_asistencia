import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Camera extends StatefulWidget {

  @override
  _CameraState createState() {
    return _CameraState();
  }
}

class _CameraState extends State<Camera> {

  CameraController controller;
  Future<void> initializeControllerFuture;
  List<CameraDescription> cameras;
  int selectedCameraIndex;


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
      initializeControllerFuture = controller.initialize();
      initializeControllerFuture.whenComplete(() => streaming());
    } catch(e) {
      String error = 'Error ${e.code} \nError message: ${e.description}';
    }
    if (mounted) {
      setState(() { });
    }
  }


  Widget cameraPreview(){
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
      debugPrint("streaming + image planes:" + image.planes.length.toString())
    });
  }


  @override
  void initState() {
    super.initState();
    //comporbamos las camaras que hay en el equipo
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
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    controller.dispose();
    controller.stopImageStream();
    super.dispose();
  }

}