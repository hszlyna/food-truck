import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _registerUser() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final values = _formKey.currentState!.value;

      int result = await DatabaseHelper.instance.registerUser({
        'name': values['name'],
        'email': values['email'],
        'phone': values['phone'],
        'username': values['username'],
        'password': values['password'],
      });

      if (result == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Username already exists!',
              style: TextStyle(color: Colors.white), // White text
            ),
            backgroundColor: Colors.red, // Red background for error
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User registered successfully!',
              style: TextStyle(color: Colors.white), // White text
            ),
            backgroundColor: Colors.green, // Green background for success
          ),
        );
        Navigator.pop(context); // Return to login page
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: ListView(
            children: [
              FormBuilderTextField(
                name: 'name',
                decoration: InputDecoration(labelText: 'Name'),
                validator: FormBuilderValidators.required(),
              ),
              FormBuilderTextField(
                name: 'email',
                decoration: InputDecoration(labelText: 'Email'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
              ),
              FormBuilderTextField(
                name: 'phone',
                decoration: InputDecoration(labelText: 'Phone'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                  FormBuilderValidators.minLength(10),
                ]),
              ),
              FormBuilderTextField(
                name: 'username',
                decoration: InputDecoration(labelText: 'Username'),
                validator: FormBuilderValidators.required(),
              ),
              FormBuilderTextField(
                name: 'password',
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(6),
                ]),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerUser,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
