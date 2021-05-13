import 'package:control_asistencia/views/create_user/create_user_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:control_asistencia/views/camera_page/camera_view.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {


  HomePage({Key key}) : super(key: key);

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /*
  Scaffold principal
   */
  bool _cameraOn = true;

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Access Control'),
          actions: [
            IconButton(
                icon: _cameraOn ? Icon(Icons.videocam) : Icon(Icons.videocam_off),
                onPressed: () {
                  setState(() {
                    _cameraOn = !_cameraOn;
                  });
                },
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: _cameraOn ? Camera() : Center(child: Text("Camera Off")),
            ),
          ],
        ),
        drawer: menuDrawer(),

      ),
    );
  }

  Widget menuDrawer() {
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black38,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Crear Usuario'),
              onTap: () => navigateTo(context, CreateUserForm()),
            ),
            ListTile(
              leading: Icon(Icons.person_remove),
              title: Text('Borrar Usuario'),
            ),
            ListTile(
              leading: Icon(Icons.assessment),
              title: Text('Reporte de Marcaje'),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app_outlined),
              title: Text('Salir del menu'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
    );
  }

  void navigateTo(BuildContext context, Widget route) {
    setState(() {
      _cameraOn = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => route
          )
      );
    });
  }
}


