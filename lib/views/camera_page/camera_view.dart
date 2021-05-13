import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:control_asistencia/services/enrollment_service.dart';
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

  final EnrollmentService matchingService = EnrollmentService();
  CameraController controller;
  Future<void> initializeControllerFuture;
  List<CameraDescription> cameras;
  int selectedCameraIndex;
  bool isOpen = false;
  bool isDetecting = false;
  bool detectSomething = false;




  Future initCamera(CameraDescription cameraDescription) async{
    if( controller != null) {
      await controller.dispose();
    }

    if (Platform.isAndroid) {
      controller = CameraController(cameraDescription, ResolutionPreset.medium, imageFormatGroup: ImageFormatGroup.jpeg, enableAudio: false);
    } else if (Platform.isIOS) {
      controller = CameraController(cameraDescription, ResolutionPreset.medium, imageFormatGroup: ImageFormatGroup.bgra8888, enableAudio: false);
    }

    if (controller.value.hasError) {
      print('Error de Camara ${controller.value.errorDescription}');
    }

    try {
      int res = await MethodChannelService.channel.onInit();
      debugPrint("CODIGO DE RESPUESTA POR PARTE DE LA PLATAFORMA CON METHOD CHANNEL ON INIT:" + res.toString());
      initializeControllerFuture = controller.initialize();
      isOpen = true;
      initializeControllerFuture.whenComplete(() => streaming());
    } catch(e) {
      String error = 'Error ${e.code} \nError message: ${e.description}';
      debugPrint(error);
    }
    if (mounted) {
      setState(() { });
    }
  }


  Widget cameraPreview(BuildContext context){
    return FutureBuilder<void>(
      future: initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          //si el controlador (future) está inicializado, mostramos el preview
          //child: FloatingActionButton(onPressed: () {handleImageStreamming();}
          return CameraPreview(controller);
        } else {
          //si no, mostramos un indicador de carga
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<void> detect(CameraImage image) async{
    isDetecting = true;
    int res = await matchingService.detectAndMatch(image).whenComplete(() => { isDetecting = false });
    debugPrint("______________ CODIGO DE RESPUESTA POR PARTE DE LA PLATAFORMA DETECT AND MATCH: " + res.toString() + " _______________");
    if (res < 0) { //si no detecta ni match nada, se sale
      if (res == -1) {
        //si detectó el rostro pero no hay en la base de datos
        String message = 'No se encuentra en la base de datos usted. Intentelo de nuevo';
        MaterialAccentColor color = Colors.orangeAccent;
      //  ScaffoldMessenger.of(context)
      //        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color,));
        debugPrint("______________ MENSAJE DE RESPUESTA DE LA PLATAFORMA: " + message + " _______________");

      }
      return;
    }
    //si hizo match en el SDK, marca en la base de datos
    detectSomething = true;
    String userName = await matchingService.userMarcado(res);
    //si pudo marcar mostrar mensaje de que el user $nombre se marcó correctamente
    String message = 'Hola $userName , linda sonrisa';
    MaterialColor color = Colors.lightGreen;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color,));
    detectSomething = false;

    /*bool pudoMarcar = await matchingService.marcar(res).whenComplete(() => {detectSomething = false});
    if (pudoMarcar) {
      String userName = await matchingService.userMarcado(res);
      //si pudo marcar mostrar mensaje de que el user $nombre se marcó correctamente
      String message = 'El usuario $userName acaba de marcar';
      MaterialColor color = Colors.lightGreen;
      ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message), backgroundColor: color,));
    } else {
      //si no pudo marcar, mostrar mensaje para que lo siga intentando
      String userName = await matchingService.userMarcado(res);
      //si pudo marcar mostrar mensaje de que el user $nombre se marcó correctamente
      String message = 'No se pudo guardar el marcaje, intentelo de nuevo';
      MaterialAccentColor color = Colors.redAccent;
      ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message), backgroundColor: color,));
    }*/
  }

  void analyzeEachImage(CameraImage image) async{
      //await Future.delayed(Duration(milliseconds : 200));
      debugPrint("______________ THIS IMAGE IS NOT SENDED TO DETECTING _______________");

      if(!isDetecting && !detectSomething && mounted) {
        await detect(image);
      }

  }


  void streaming(){
    if (!controller.value.isStreamingImages) {
      Future.delayed(Duration(milliseconds : 2000)).then((value) =>
          controller.startImageStream((CameraImage image)=> {
            analyzeEachImage(image)
          })
      );
    }
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
    return Container(child: cameraPreview(context));
  }



  @override
  void deactivate() {
    if (controller.value.isStreamingImages) {
      isOpen = false;
      controller.stopImageStream().whenComplete(() => super.deactivate());
      isDetecting = false;
    } else {
      super.deactivate();
    }
  }


  @override
  void dispose(){
    // Dispose of the controller when the widget is disposed.
    isOpen = false;
    if (controller != null && controller.value.isStreamingImages) {
      controller.stopImageStream().then((_) {
        controller.dispose();
      });
    }
    Future.delayed(Duration(milliseconds: 200));
    super.dispose();
  }




}