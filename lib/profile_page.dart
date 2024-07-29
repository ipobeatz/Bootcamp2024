import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userProfile = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userProfile.exists) {
          print('User Name: ${userProfile.get('firstName')} ${userProfile.get('lastName')}');
        } else {
          print('No user profile available.');
        }
      } catch (e) {
        print('Error fetching user profile: $e');
      }
    } else {
      print('No user logged in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userProfile == null
          ? Center(child: Text("No user profile available."))
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: ${userProfile!.get('firstName')}', style: TextStyle(fontSize: 18)),
            Text('Surname: ${userProfile!.get('lastName')}', style: TextStyle(fontSize: 18)),
            Text('Email: ${user!.email}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
