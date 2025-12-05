import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/database_helper.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'registration.dart';
import 'userProv.dart';
import 'MainMenu.dart';
import '../Home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _loginUser() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final values = _formKey.currentState!.value;
      final username = values['username'];
      final password = values['password'];

      final user = await DatabaseHelper.instance.loginUser(username, password);

      if (user != null) {
        // Store userId in the UserProvider
        Provider.of<UserProvider>(context, listen: false).setUserId(user['userid']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login successful! Welcome ${user['name']}',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.purple,
          ),
        );

        // Navigate to the MainMenu
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainMenuPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid username or password',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Home()),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: ListView(
            children: [
              // Add the food truck vector image from an online source
              Image.network(
                'https://img.freepik.com/free-vector/food-truck-concept-illustration_114360-13241.jpg', // Replace with the actual image URL
                height: 150,
                fit: BoxFit.contain,
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
                validator: FormBuilderValidators.required(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loginUser,
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.white), // White text color
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent, // Purple background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners for the button
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Add padding for better button size
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationPage()),
                  );
                },
                child: Text('Don\'t have an account? Register here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
