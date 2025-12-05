import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../db/database_helper.dart';
import 'admin_dash.dart';
import '../Home.dart';

class AdminLoginPage extends StatefulWidget {
  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  Future<void> _loginAdmin() async {
    if (_fbKey.currentState!.saveAndValidate()) {
      final username = _fbKey.currentState!.fields['username']!.value.trim();
      final password = _fbKey.currentState!.fields['password']!.value.trim();

      // Check predefined credentials
      if (username == 'admin' && password == 'admin123') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful! Welcome, Admin.')),
        );

        // Navigate to the Admin Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardPage()),
        );
      } else {
        // Check credentials in the database
        final admin = await DatabaseHelper.instance.loginAdmin(username, password);

        if (admin != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login successful! Welcome, Admin.')),
          );

          // Navigate to the Admin Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboardPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid username or password')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home), // Icon for the top-left button
          onPressed: () {
            // Navigate to the Main Menu or Home page
            Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Home()),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _fbKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add Image Icon above Username field
              Image.network(
                'https://static.vecteezy.com/system/resources/thumbnails/036/964/102/small_2x/employee-gradient-icon-vector.jpg', width: 100, height: 100,
              ),
              SizedBox(height: 20),
              Text(
                'Admin Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Username Field
              FormBuilderTextField(
                name: 'username',
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              SizedBox(height: 16),
              // Password Field
              FormBuilderTextField(
                name: 'password',
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity, // Ensure it takes up 100% of the width
                child: ElevatedButton(
                  onPressed: _loginAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple, // Purple background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners for the button
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12), // Vertical padding for button size
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.white), // White text color
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
