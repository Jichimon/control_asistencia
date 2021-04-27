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

  TextEditingController nameCtrl = new TextEditingController();
  TextEditingController phoneNumberCtrl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

  }

  Widget createUserButton() {
    return ElevatedButton(
        onPressed: () {
          //si el form es válido, devolverá true
          if (_formKey.currentState.validate()) {
            //aca llamamos al userController para meter el nuevo usuario a la base de datos
            userController.inputNewUser(nameCtrl.text, phoneNumberCtrl.text);
            return FutureBuilder<void>(
              future: userController.createNewUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  //cuando acabe el metodo Future
                  return SnackBar(content: Text(userController.currentState));
                } else {
                  //mientras el metodo future está en proceso
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar( content: Text(userController.currentState),));
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          }
        },
        child: Text('Guardar'));
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