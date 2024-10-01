import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_home/auth_pages/forget_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _previousPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _isPreviousPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userData.exists) {
        _nameController.text = userData.data()?['username'] ?? '';
        _phoneController.text = userData.data()?['mobile'] ?? '';
      }
    }
  }

  // Function to re-authenticate user
  Future<void> _reauthenticateUser() async {
    if (user != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user!.email!,
          password: _previousPasswordController
              .text, // Get current password from user input
        );
        await user!.reauthenticateWithCredential(credential);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Re-authentication failed: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (user != null) {
          // Update other profile information in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .update({
            'username': _nameController.text,
            'mobile': _phoneController.text,
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ));

          // If new password is provided, re-authenticate and update password
          if (_newPasswordController.text.isNotEmpty) {
            if (_newPasswordController.text !=
                _confirmPasswordController.text) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                    'New password and confirm password do not match.'),
                backgroundColor: Colors.red,
              ));
              return;
            }

            await _reauthenticateUser(); // Re-authenticate before changing the password

            try {
              await user!.updatePassword(_newPasswordController.text);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Password updated successfully!'),
                backgroundColor: Colors.green,
              ));
            } on FirebaseAuthException catch (e) {
              if (e.code == 'requires-recent-login') {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text(
                      'You need to log in again to update your password.'),
                  backgroundColor: Colors.red,
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Failed to update password: ${e.message}'),
                  backgroundColor: Colors.red,
                ));
              }
            }
          }

          Navigator.pop(context, true); // Go back to ProfilePage after update
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.cyan,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        decoration:
                            const InputDecoration(labelText: 'Phone Number'),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _previousPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Enter Previous Password',
                          suffixIcon: IconButton(
                            icon: Icon(_isPreviousPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isPreviousPasswordVisible =
                                    !_isPreviousPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isPreviousPasswordVisible,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _newPasswordController,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          suffixIcon: IconButton(
                            icon: Icon(_isNewPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isNewPasswordVisible = !_isNewPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isNewPasswordVisible,
                        validator: (value) {
                          if (value != null &&
                              value.length < 6 &&
                              value.isNotEmpty) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          suffixIcon: IconButton(
                            icon: Icon(_isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isConfirmPasswordVisible,
                        validator: (value) {
                          if (value != null &&
                              value.length < 6 &&
                              value.isNotEmpty) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan),
                        child: const Text('Save'),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _navigateToForgotPassword,
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
