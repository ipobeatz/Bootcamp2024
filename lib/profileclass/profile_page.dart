import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_analysis/profileclass/profile_detail.dart';
import 'package:field_analysis/auth/sign_in.dart';

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
    setState(() {
      isLoading = true;
    });
    if (user != null) {
      try {
        print("ibobo" + user!.uid);
        DocumentSnapshot userProfile = await FirebaseFirestore.instance
            .collection('users').doc(user!.uid).get();
        if (userProfile.exists) {
          setState(() {
            this.userProfile = userProfile;
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

  void _changePassword(BuildContext context) {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmNewPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Şifre Değiştir'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: currentPasswordController,
                  decoration: InputDecoration(
                      hintText: "Mevcut şifrenizi girin"),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(hintText: "Yeni şifre girin"),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: confirmNewPasswordController,
                  decoration: InputDecoration(
                      hintText: "Yeni şifreyi onaylayın"),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Güncelle'),
              onPressed: () {
                if (newPasswordController.text ==
                    confirmNewPasswordController.text) {
                  _reauthenticateAndChangePassword(
                      currentPasswordController.text,
                      newPasswordController.text,
                      context
                  );
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                      SnackBar(content: Text("Yeni şifreler eşleşmiyor")));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _reauthenticateAndChangePassword(String currentPassword,
      String newPassword, BuildContext context) {
    AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!, password: currentPassword);

    user!.reauthenticateWithCredential(credential).then((_) {
      user!.updatePassword(newPassword).then((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Şifre başarıyla güncellendi"))
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Şifre güncellenemedi"))
        );
      });
    }).catchError((error) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mevcut şifre doğru değil"))
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade400,
        title: Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userProfile == null
          ? Center(child: Text("No user profile available."))
          : SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/icon2.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 3),
            Text(
              userProfile!.get('firstName') ?? 'First Name Not Available',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              userProfile!.get('email') ?? 'Email Not Available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 30),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('My Profile'),
              trailing: Icon(Icons.keyboard_arrow_right_sharp),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => ProfileDetail()),
                );
              },
            ),
            Divider(height: 1, thickness: 1),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Change Password'),
              trailing: Icon(Icons.keyboard_arrow_right_sharp),
              onTap: () {
                _changePassword(context);
              },
            ),
            Divider(height: 1, thickness: 1),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log Out'),
              trailing: Icon(Icons.keyboard_arrow_right_sharp),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Çıkış Yap'),
                      content: Text('Gerçekten çıkmak istediğinize emin misiniz?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Hayır'),
                          onPressed: () {
                            Navigator.of(context).pop(); // Dialog'u kapat
                          },
                        ),
                        TextButton(
                          child: Text('Evet'),
                          onPressed: () {
                            FirebaseAuth.instance.signOut().then((_) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              );
                            });
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
