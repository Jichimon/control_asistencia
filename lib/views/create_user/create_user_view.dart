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

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userController.nameInput(),
              userController.phoneNumberInput(),
              userController.imagesInput(),
              Padding(
                padding: const
                  EdgeInsets.symmetric(vertical: 16.0),
                  child: userController.createUserButton(),
              ),
            ],
          )
        )
    );
  }



}