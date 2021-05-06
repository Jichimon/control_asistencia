
import 'package:control_asistencia/views/create_user/image_handler_widget.dart';
import 'package:flutter/material.dart';
import 'package:control_asistencia/controllers/user_controller.dart';

class CreateUserForm extends StatefulWidget {

  @override
  CreateUserFormState createState() {
    return CreateUserFormState();
  }
}

class CreateUserFormState extends State<CreateUserForm> {

  final _formKey = GlobalKey<FormState>();
  final userController = UserController();
  final imageHandlerWidget = ImageHandlerWidget();

  TextEditingController nameCtrl = new TextEditingController();
  TextEditingController phoneNumberCtrl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create New User'),
          automaticallyImplyLeading: false,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: Center(
          child:
            Form(
                key: _formKey,
                child: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        nameInput(),
                        phoneNumberInput(),
                        imagesInput(),
                        Padding(
                          padding: const
                          EdgeInsets.symmetric(vertical: 16.0),
                          child: createUserButton(),
                    ),
                  ],
                )
            )
          )
        )
    );
  }

  Widget nameInput(){
    return TextFormField(
      controller: nameCtrl,
      decoration: const InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Escriba su nombre aquí',
          labelText: 'Nombre: '
      ),
      validator: (value) => _validateName(value),
    );
  }

  Widget phoneNumberInput() {
    return TextFormField(
      controller: phoneNumberCtrl,
      decoration: const InputDecoration(
          icon: Icon(Icons.phone),
          hintText: 'Escriba su numero de telefono',
          labelText: 'Nro. Teléfono: '
      ),
      validator: (value) => _validatePhoneNumber(value),
    );
  }

  Widget imagesInput() {
    return imageHandlerWidget;
  }

  Widget createUserButton() {
    return ElevatedButton(
        onPressed: () {
          //si el form es válido, devolverá true
          if (_formKey.currentState.validate()) {
            //aca llamamos al userController para meter el nuevo usuario a la base de datos
            userController.currentState = UserController.STATE_IN_PROCESS;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar( content: Text(userController.currentState),));
            return FutureBuilder<void>(
              future: userController.createNewUser(nameCtrl.text, phoneNumberCtrl.text, ImageHandlerWidgetState.images),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  //cuando acabe el metodo Future
                  showResult(context);
                  _formKey.currentState.reset();
                  ImageHandlerWidgetState.images = [];
                  return  SnackBar( content: Text(userController.currentState));
                } else {
                  //mientras el metodo future está en proceso
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          }
        },
        child: Text('Guardar'));
  }

  Future<Widget> showResult(BuildContext context){
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create User"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("El resultado del proceso es: "),
                Text(userController.currentState)
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Dale"),
              onPressed: () {
                setState(() {  });
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }



  //validations_____

  bool isValidName(String str) {
    String pattern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(str);
  }

  bool isValidPhoneNumber(String str) {
    String pattern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(str);
  }

  String _validateName(String value) {
    if (value.length == 0) {
      return "El nombre es obligatorio";
    } else if (!isValidName(value)) {
      return "¿Su nombre tiene números? ? ?";
    }
    //si pasa la validacion
    return null;
  }

  String _validatePhoneNumber(String value) {
    if (value.length == 0) {
      return "El numero es obligatorio";
    } else if (!isValidPhoneNumber(value)) {
      return "Solo se aceptan numeros en este campo";
    }
    return null;
  }

}