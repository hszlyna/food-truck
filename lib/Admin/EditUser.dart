import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../db/database_helper.dart';

class EditUserPage extends StatefulWidget {
  final Map<String, dynamic> user; // User data to be edited
  final VoidCallback onUpdate; // Callback to refresh the dashboard

  EditUserPage({required this.user, required this.onUpdate});

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for user details
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

  bool _isPassVisible = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['name']);
    _emailController = TextEditingController(text: widget.user['email']);
    _phoneController = TextEditingController(text: widget.user['phone']);
    _passwordController = TextEditingController(text: widget.user['password']);
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      final updatedUser = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text.trim(),
      };

      try {
        // Update the user in the database
        await DatabaseHelper.instance.adminUpdateUser(widget.user['userid'], updatedUser);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User updated successfully!')),
        );

        widget.onUpdate(); // Refresh the dashboard
        Navigator.pop(context); // Go back to the admin dashboard
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit User')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name field
              FormBuilderTextField(
                name: 'name',
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              SizedBox(height: 16),

              // Email field
              FormBuilderTextField(
                name: 'email',
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
              ),
              SizedBox(height: 16),

              // Phone field
              FormBuilderTextField(
                name: 'phone',
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                  FormBuilderValidators.minLength(10),
                ]),
              ),
              SizedBox(height: 16),

              // Password field
              FormBuilderTextField(
                name: 'password',
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPassVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPassVisible = !_isPassVisible;  // Toggle password visibility
                      });
                    },
                  ),
                ),
                obscureText: !_isPassVisible,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(6, errorText: 'Password must be at least 6 characters long'),
                ]),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUser,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
