import 'package:control_asistencia/services/database_connection_service.dart';
import 'package:control_asistencia/views/create_user/create_user_view.dart';
import 'package:control_asistencia/views/home_page/home_page.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Access Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/createUser': (context) => CreateUserForm(),
      },
    );
  }
}
