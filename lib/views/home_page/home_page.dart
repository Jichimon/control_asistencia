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
        drawer: MenuDrawer(),
      ),
    );
  }
}

class MenuDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Crear Usuario'),
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
              title: Text('Salir')
            ),
          ],
        ),
      ),
    );
  }
}


