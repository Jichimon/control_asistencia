import 'package:flutter/material.dart';

class CreateUserForm extends StatefulWidget {

  @override
  CreateUserFormState createState() {
    return CreateUserFormState();
  }
}

class CreateUserFormState extends State<CreateUserForm> {

  final _formKey = GlobalKey<FormState>();
  String nameFromForm;
  String phoneNumberFromForm;

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
              imagesInput();
              Padding(
                padding: const
                  EdgeInsets.symmetric(vertical: 16.0),
                  child: submitButton(),
              ),
            ],
          )
        )
    );
  }



}