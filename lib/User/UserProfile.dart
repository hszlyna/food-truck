import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../db/database_helper.dart';

class UserProfilePage extends StatefulWidget {
  final int userId;

  UserProfilePage({required this.userId});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _userProfile = {};
  bool _isPassVisible = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await DatabaseHelper.instance.getUserInfo(widget.userId);
    if (profile != null) {
      setState(() {
        _userProfile = profile; // Assign non-null profile to _userProfile
      });
    }
  }

  Future<void> _updateUserProfile() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final updatedInfo = _formKey.currentState!.value;
      await DatabaseHelper.instance.updateUserInfo(widget.userId, updatedInfo);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile updated successfully!',
            style: TextStyle(color: Colors.white), // White text
          ),
          backgroundColor: Colors.green, // Green background for success
        ),
      );
      _loadUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while _userProfile is empty
    if (_userProfile.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          initialValue: _userProfile, // _userProfile is now guaranteed to be non-null
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
                name: 'password',
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
                  FormBuilderValidators.minLength(6),
                ]),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUserProfile,
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
