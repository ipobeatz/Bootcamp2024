import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:field_analysis/mapclass/selected_map_model.dart';
import 'dart:math';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Marker> markers = [];
  List<SelectedPlace> selectedPlaces = [];
  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    loadMarkers().then((_) {
      if (selectedPlaces.isNotEmpty) {
        findDensestArea();
      }
    });
  }

  Future<void> loadMarkers() async {
    User? user = auth.currentUser;
    if (user != null) {
      try {
        print("Loading markers for user: ${user.uid}");
        QuerySnapshot snapshot = await firestore.collection('fields').where('userID', isEqualTo: user.uid).get();
        setState(() {
          selectedPlaces = snapshot.docs.map((doc) =>
              SelectedPlace.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
          markers = selectedPlaces.map((place) =>
              Marker(
                width: 80.0,
                height: 80.0,
                point: place.location,
                builder: (ctx) =>
                    GestureDetector(
                      onTap: () => _showEditDialog(place),
                      child: Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
              )).toList();
          print("Markers loaded successfully");
        });
      } catch (e) {
        print("Failed to load markers: $e");
      }
    } else {
      print("No user logged in");
    }
  }

  Future<void> saveMarkers() async {
    User? user = auth.currentUser;
    if (user != null) {
      try {
        print("Saving markers for user: ${user.uid}");
        WriteBatch batch = firestore.batch();
        for (var place in selectedPlaces) {
          DocumentReference docRef = firestore.collection('fields').doc(place.docID);
          batch.update(docRef, place.toJson());
        }
        await batch.commit();
        print("Markers saved successfully");
      } catch (e) {
        print("Failed to save markers: $e");
      }
    } else {
      print("No user logged in");
    }
  }

  void findDensestArea() {
    if (selectedPlaces.isEmpty) return;
    int maxCount = 0;
    LatLng densestPoint = selectedPlaces.first.location;

    for (var basePlace in selectedPlaces) {
      int count = 0;
      for (var otherPlace in selectedPlaces) {
        double distance = calculateDistance(
            basePlace.location, otherPlace.location);
        if (distance < 500) { // Check within 500 meters
          count++;
        }
      }
      if (count > maxCount) {
        maxCount = count;
        densestPoint = basePlace.location;
      }
    }
    mapController.move(densestPoint, 13.0);
  }

  double calculateDistance(LatLng start, LatLng end) {
    var dLat = radians(end.latitude - start.latitude);
    var dLon = radians(end.longitude - start.longitude);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(radians(start.latitude)) * cos(radians(end.latitude)) *
            sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    const double radius = 6371000; // Earth radius in meters
    return radius * c;
  }

  double radians(double degree) {
    return degree * pi / 180.0;
  }

  void _showEditDialog(SelectedPlace place) {
    TextEditingController nameController = TextEditingController(
        text: place.name);
    TextEditingController info1Controller = TextEditingController(
        text: place.info1);
    TextEditingController info2Controller = TextEditingController(
        text: place.info2);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit: ' + place.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(controller: nameController,
                  decoration: InputDecoration(labelText: 'Tarla İsmi')),
              TextField(controller: info1Controller,
                  decoration: InputDecoration(labelText: 'Tarla Detayları')),
              TextField(controller: info2Controller,
                  decoration: InputDecoration(labelText: 'Analiz Sonuçları')),
            ],
          ),
          actions: <Widget>[
            TextButton(child: Text("Cancel"),
                onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: Text("Save"),
              onPressed: () {
                setState(() {
                  place.name = nameController.text;
                  place.info1 = info1Controller.text;
                  place.info2 = info2Controller.text;
                  saveMarkers();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selected Area"),
        backgroundColor: Colors.orange.shade400,
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: LatLng(41.0082, 28.9784),
                zoom: 13.0,
                minZoom: 5.0,
                maxZoom: 18.0,

              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
          Expanded(
            child: selectedPlaces.isNotEmpty
                ? ListView.builder(
              itemCount: selectedPlaces.length,
              itemBuilder: (context, index) {
                SelectedPlace place = selectedPlaces[index];
                return Dismissible(
                  key: UniqueKey(), // Benzersiz bir anahtar kullan
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    // Önce öğeyi listeden kaldır
                    SelectedPlace removedPlace = selectedPlaces.removeAt(index);
                    markers.removeAt(index);

                    setState(() {});

                    try {
                      User? user = auth.currentUser;
                      if (user != null) {
                        DocumentReference docRef = firestore.collection('fields').doc('${removedPlace.docID}');
                        await docRef.delete();
                        print("Deleted marker: ${removedPlace.name}");
                      } else {
                        print("No user logged in");
                      }
                    } catch (e) {
                      print("Failed to delete marker: $e");
                    }

                    // Kullanıcıya öğenin silindiğini bildir
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Deleted ${removedPlace.name}"))
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    elevation: 6,
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                    child: ListTile(
                      title: Text(place.name),
                      subtitle: Text(
                        "${place.location.latitude}, ${place.location.longitude}\nTarla Detayları: ${place.info1}\nAnaliz Sonuçları: ${place.info2}",
                      ),
                      onTap: () => mapController.move(place.location, 15.0),
                    ),
                  ),
                );
              },
            )
                : Center(
              child: Text(
                'Henüz herhangi bir tarla eklenmedi.',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }


}