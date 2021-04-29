import 'package:control_asistencia/views/create_user/create_user_view.dart';
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
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Access Control'),
        ),
        body: Camera(),
        drawer: menuDrawer(),
        onDrawerChanged: (value){ CameraState.isStreamming = value; },

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
          context,
          MaterialPageRoute( builder: (context) => route, )
      );
    });

  }
}


