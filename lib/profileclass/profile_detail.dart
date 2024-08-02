import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_analysis/homeclass/main_screen.dart';

class ProfileDetail extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfileDetail> {
  User? user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    setState(() {
      isLoading = true;
    });
    if (user != null) {
      try {
        DocumentSnapshot userProfileSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (userProfileSnapshot.exists) {
          setState(() {
            userProfile = userProfileSnapshot;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('No user profile available.');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Error fetching user profile: $e');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print('No user logged in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade400,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).maybePop(context).then((value) {
              if (value == false) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(initialIndex: 3), // 4. sekmeye yönlendirin (Profile)
                  ),
                );
              }
            });
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userProfile == null
          ? Center(child: Text("No user profile available."))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20),
              Text('Personal Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Divider(color: Colors.blueGrey),
              SizedBox(height: 10),
              _buildTextField(
                label: 'First Name',
                icon: Icons.person,
                initialValue: userProfile?.get('firstName') ?? '',
              ),
              SizedBox(height: 10),
              _buildTextField(
                label: 'Last Name',
                icon: Icons.person_outline,
                initialValue: userProfile?.get('lastName') ?? '',
              ),
              SizedBox(height: 10),
              _buildTextField(
                label: 'Email',
                icon: Icons.email,
                initialValue: user?.email ?? 'No email',
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required IconData icon, required String initialValue}) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      readOnly: true,
    );
  }
}
