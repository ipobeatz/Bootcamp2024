import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Search Page Content',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  void testFirebaseConnection() async {
    try {
      await FirebaseFirestore.instance.collection('test').doc('testDoc').set({'field': 'value'});
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('test').doc('testDoc').get();
      print('Firebase connection test successful, read: ${snapshot.get('field')}');
    } catch (e) {
      print('Firebase connection test failed: $e');
    }
  }
}
