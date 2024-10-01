import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_home/upload_home/add_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  String? _imageUrl;
  String? _email;

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
          _email = 'No user is authenticated';
          _imageUrl = null;
        });
        return;
      }

      // Fetch the document from Firestore for the current user
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        setState(() {
          _email = user.email;
          _imageUrl = userData.data()?['profile_picture'];
        });
      } else {
        setState(() {
          _email = 'No user data found';
          _imageUrl = null;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _email = 'Error fetching data';
        _imageUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _imageUrl != null
                      ? NetworkImage(_imageUrl!)
                      : const AssetImage('assets/images/image1.png')
                          as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(
                  _email ?? 'Loading...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
                Icons.add_home_work_outlined), // Icon for Rent Your Home
            title: const Text('Rent Your Home'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddHomePage()),
              );
            },
          ),
          // Add more ListTiles for additional drawer items
        ],
      ),
    );
  }
}
