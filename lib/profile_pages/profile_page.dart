import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_home/auth_pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../auth_pages/login_page.dart';
import 'edit_profilepage.dart';
import 'faq_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;
  String? _name;
  String? _email;
  String? _mobile;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _name = 'No user is authenticated';
          _email = 'No user is authenticated';
          _mobile = 'No user is authenticated';
        });
        return;
      }

      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        setState(() {
          _name = userData.data()?['username'] ?? 'No Name';
          _email = userData.data()?['email'] ?? 'No Email';
          _mobile = userData.data()?['mobile'] ?? 'No Mobile';
          _imageUrl = userData.data()?['profile_picture'] ?? null;
        });
      } else {
        setState(() {
          _name = 'No user data found';
          _email = 'No user data found';
          _mobile = 'No user data found';
        });
      }
    } catch (e) {
      setState(() {
        _name = 'Error fetching data';
        _email = 'Error fetching data';
        _mobile = 'Error fetching data';
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final File file = File(image.path);
      await _uploadImage(file);
    }
  }

  Future<void> _uploadImage(File file) async {
    try {
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageReference =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      setState(() {
        _imageUrl = downloadUrl;
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profile_picture': downloadUrl});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload image. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const LoginPage(), // Navigate to LoginPage
              ),
            );
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.cyan.shade100,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 10), // Added space to move logo up
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50, // Smaller size for the logo
                      backgroundImage: _imageUrl != null
                          ? NetworkImage(_imageUrl!)
                          : const AssetImage('assets/images/image1.png')
                              as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 30, // Smaller edit icon
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.cyan,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 14, // Smaller icon size
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5), // Reduced space below avatar
                Text(
                  _name ?? 'Loading...',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 5),
                Text(
                  _email ?? 'Loading...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  _mobile ?? 'Loading...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton(
                  onPressed: () async {
                    bool? profileUpdated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditProfilePage()),
                    );

                    // If profile was updated, refresh user data
                    if (profileUpdated == true) {
                      _fetchUserData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20), // Adjusted space
                _buildProfileMenu(
                  context,
                  title: 'Privacy',
                  icon: Icons.lock,
                  onTap: () {},
                ),
                _buildProfileMenu(
                  context,
                  title: 'Frequently Asked Questions',
                  icon: Icons.help,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const FAQPage()), // Navigate to FAQPage
                    );
                  },
                ),

                _buildProfileMenu(
                  context,
                  title: 'Settings',
                  icon: Icons.settings,
                  onTap: () {},
                ),
                _buildProfileMenu(
                  context,
                  title: 'Invite a Friend',
                  icon: Icons.group_add,
                  onTap: () {},
                ),
                _buildProfileMenu(
                  context,
                  title: 'Logout',
                  icon: Icons.logout,
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                  textColor: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenu(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, size: 18), // Smaller icon size
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 14), // Smaller trailing icon size
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('LOGOUT'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const LoginPage(), // Navigate back to LoginPage
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan[300],
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProfilePage(),
  ));
}
