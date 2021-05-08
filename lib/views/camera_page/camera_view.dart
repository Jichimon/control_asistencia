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

  static bool isStreamming = false;


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


  Widget cameraPreview(){
    return FutureBuilder<void>(
      future: initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          //si el controlador (future) está inicializado, mostramos el preview
          //child: FloatingActionButton(onPressed: () {handleImageStreamming();}
          return CameraPreview(controller,);
        } else {
          //si no, mostramos un indicador de carga
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<void> detect(CameraImage image) async{
    setState(() {
      isDetecting = true;
    });
    int res = await matchingService.detectAndMatch(image);
    debugPrint("______________ CODIGO DE RESPUESTA POR PARTE DE LA PLATAFORMA DETECT AND MATCH: " + res.toString() + " _______________");
    if ( res < 0) { //si no detecta ni match nada, se sale
      if (res == -1) {
        //si detectó el rostro pero no hay en la base de datos
        String message = 'No se encuentra en la base de datos usted. Intentelo de nuevo';
        Color color = Colors.orangeAccent;
        setState(() {
          //showResult(context, message, color);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message), backgroundColor: color,));
        });
      }
      return;
    }
    //si hizo match en el SDK, marca en la base de datos
    bool pudoMarcar = await matchingService.marcar(res);
    if (pudoMarcar) {
      String userName = await matchingService.userMarcado(res);
      //si pudo marcar mostrar mensaje de que el user $nombre se marcó correctamente
      String message = 'El usuario $userName acaba de marcar';
      Color color = Colors.lightGreen;
      setState(() {
        //showResult(context, message, color);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message), backgroundColor: color,));
      });
    } else {
      //si no pudo marcar, mostrar mensaje para que lo siga intentando
      String message = 'No se pudo guardar el marcaje, intentelo de nuevo';
      Color color = Colors.redAccent;
      setState(() {
        //showResult(context, message, color);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message), backgroundColor: color,));
      });
    }
  }

  void analyzeEachImage(CameraImage image) async{
      isStreamming = true;
      //await Future.delayed(Duration(milliseconds : 2000));
      debugPrint("______________ THIS IMAGE IS NOT SENDED TO DETECTING _______________");

      if(!isDetecting) {
        setState(() {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("detecting face"),));
        });
        await detect(image).whenComplete(() => { isDetecting = false });
      }

  }

  void handleImageStreamming() {
    if (isStreamming) {
      controller.stopImageStream();
      setState(() {

      });
    } else {
      streaming();
    }
  }


  Future<void> streaming() async{
    if (!isStreamming) {
      await Future.delayed(Duration(milliseconds : 2000));
      controller.startImageStream((CameraImage image)=> {
        analyzeEachImage(image)
      });
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
    return Container(child: cameraPreview());
  }

  @override
  void deactivate() {
    if (isStreamming) {
      Future.delayed(Duration.zero, () async {
        await controller.stopImageStream();
        await controller.dispose();
        isStreamming = false;
      });
    }
    isOpen = false;
    super.deactivate();
  }


  @override
  Future<void> dispose() async{
    // Dispose of the controller when the widget is disposed.
    Future.delayed(Duration.zero, () async {
      //comentar esta linea de abajo si no funca
      if (isStreamming) {
        await controller.stopImageStream();
      }
      await controller.dispose();
      isOpen = false;
    });
    super.dispose();
  }




}