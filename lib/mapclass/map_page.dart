import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'selected_map_model.dart';
import 'dart:math';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? placesString = prefs.getStringList('markers');
    if (placesString != null) {
      setState(() {
        selectedPlaces = placesString.map((placeString) => SelectedPlace.fromJson(jsonDecode(placeString))).toList();
        markers = selectedPlaces.map((place) => Marker(
          width: 80.0,
          height: 80.0,
          point: place.location,
          builder: (ctx) => GestureDetector(
            onTap: () => _showEditDialog(place),
            child: Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        )).toList();
      });
    }
  }

  void findDensestArea() {
    if (selectedPlaces.isEmpty) return;
    int maxCount = 0;
    LatLng densestPoint = selectedPlaces.first.location;

    for (var basePlace in selectedPlaces) {
      int count = 0;
      for (var otherPlace in selectedPlaces) {
        double distance = calculateDistance(basePlace.location, otherPlace.location);
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
    TextEditingController nameController = TextEditingController(text: place.name);
    TextEditingController info1Controller = TextEditingController(text: place.info1);
    TextEditingController info2Controller = TextEditingController(text: place.info2);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit: ' + place.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Place Name')),
              TextField(controller: info1Controller, decoration: InputDecoration(labelText: 'Info 1')),
              TextField(controller: info2Controller, decoration: InputDecoration(labelText: 'Info 2')),
            ],
          ),
          actions: <Widget>[
            TextButton(child: Text("Cancel"), onPressed: () => Navigator.of(context). pop()),
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

  Future<void> saveMarkers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> placesString = selectedPlaces.map((place) => jsonEncode(place.toJson())).toList().cast<String>();
    await prefs.setStringList('markers', placesString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selected Area")),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: LatLng(41.0082, 28.9784), // Default center location
                zoom: 13.0,
                minZoom: 5.0,
                maxZoom: 18.0,
                onLongPress: (tapPosition, latLng) {
                  setState(() {
                    _addMarker(latLng, "Long Pressed Area");
                  });
                },
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
            child: ListView.builder(
              itemCount: selectedPlaces.length,
              itemBuilder: (context, index) {
                SelectedPlace place = selectedPlaces[index];
                return Dismissible(
                  key: Key(place.name + index.toString()), // Ensure a unique key
                  direction: DismissDirection.endToStart, // Enable swipe to dismiss from right to left
                  onDismissed: (direction) {
                    setState(() {
                      selectedPlaces.removeAt(index);
                      markers.removeAt(index);
                      saveMarkers();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Deleted ${place.name}"))
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: Text(place.name),
                    subtitle: Text("${place.location.latitude}, ${place.location.longitude}\nTarla Detayları: ${place.info1}\nAnaliz Sonuçları: ${place.info2}"),
                    onTap: () => mapController.move(place.location, 15.0),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addMarker(LatLng point, String markerType) {
    setState(() {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: point,
          builder: (ctx) => Container(
            child: Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        ),
      );
      selectedPlaces.add(SelectedPlace(name: "$markerType ${selectedPlaces.length + 1}", location: point));
      saveMarkers();
    });
  }
}
