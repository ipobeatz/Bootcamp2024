import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:field_analysis/fieldclass/SeedSuggestionModel.dart';
import 'package:field_analysis/homeclass/home_page.dart';
import 'package:field_analysis/homeclass/main_screen.dart';

void main() {
  runApp(FieldAddScreen());
}

class FieldAddScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SoilDataInputScreen(),
    );
  }
}

class SoilDataInputScreen extends StatefulWidget {
  @override
  _SoilDataInputScreenState createState() => _SoilDataInputScreenState();
}

class _SoilDataInputScreenState extends State<SoilDataInputScreen> {
  bool nitrogenEnabled = true;
  double nitrogen = 0.5;

  bool phosphorusEnabled = true;
  double phosphorus = 0.4;

  bool potassiumEnabled = true;
  double potassium = 0.85;

  bool calciumEnabled = true;
  double calcium = 0.3;

  bool magnesiumEnabled = true;
  double magnesium = 0.4;

  double pH = 6.9;

  int organicMatter = 1;
  SeedSuggestionModel model = SeedSuggestionModel();

  Marker? singleMarker;
  LatLng selectedLocation = LatLng(41.0082, 28.9784); // Default location (Istanbul)
  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    model.loadModel();
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  void _sendDataToFirestore() async {
    try {
      User? user = auth.currentUser;

      // Yükleme ekranını göster
      _showLoadingDialog();

      double nitrogen_ = double.parse(nitrogen.toStringAsFixed(2));
      double phosphorus_ = double.parse(phosphorus.toStringAsFixed(2));
      double potassium_ = double.parse(potassium.toStringAsFixed(2));
      double calcium_ = double.parse(calcium.toStringAsFixed(2));
      double magnesium_ = double.parse(magnesium.toStringAsFixed(2));
      double pH_ = double.parse(pH.toStringAsFixed(2));
      int organicMatter_ = organicMatter;
      String result = await model.predictSeed([
        nitrogen_,
        phosphorus_,
        potassium_,
        calcium_,
        magnesium_,
        pH_,
        double.parse(organicMatter_.toString()),
      ]);

      String docID = DateTime.now().millisecondsSinceEpoch.toString();
      await _firestore.collection('fields').doc(docID).set({
        'nitrogen': nitrogenEnabled ? double.parse(nitrogen.toStringAsFixed(2)) : null,
        'phosphorus': phosphorusEnabled ? double.parse(phosphorus.toStringAsFixed(2)) : null,
        'potassium': potassiumEnabled ? double.parse(potassium.toStringAsFixed(2)) : null,
        'calcium': calciumEnabled ? double.parse(calcium.toStringAsFixed(2)) : null,
        'magnesium': magnesiumEnabled ? double.parse(magnesium.toStringAsFixed(2)) : null,
        'pH': double.parse(pH.toStringAsFixed(2)),
        'organicMatter': organicMatter,
        'seedSuggestion': result,
        'longitude': selectedLocation.longitude,
        'latitude': selectedLocation.latitude,
        'userID': auth.currentUser?.uid ?? "",
        'name': "test name",
        'info1': '',
        'info2': '',
        'docID': docID
      });

      // Yükleme ekranını 1 saniye sonra kapat ve analiz sonucu gösteren pop-up'ı aç
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context); // Yükleme ekranını kapat
        _showResultDialog(result);
      });
    } catch (e) {
      Navigator.pop(context); // Yükleme ekranını kapat
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send data to Firestore: $e'),
      ));
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Analiz ediliyor..."),
            ],
          ),
        );
      },
    );
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Analiz Sonucu"),
          content: Text(
              "Yapay zeka tabanlı analizler sonucunda, tarlanızın özelliklerine en verimli ürün olarak $result ekilmesi öngörülmüştür."

                  "\n\nYapay zeka, toprağın verimliliğini, iklim koşullarını ve diğer birçok faktörü dikkate alarak bu sonucu sunmuştur."
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Pop-up'ı kapat
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(),
                  ),
                      (route) => false,
                );
              },
              child: Text("Tamam"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double scale = 0.8;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade400,
        title: Text('Soil Data Entry'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 500 * scale,
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  center: selectedLocation,
                  zoom: 13.0,
                  minZoom: 5.0,
                  maxZoom: 23.0,
                  onLongPress: (tapPosition, latLng) {
                    setState(() {
                      singleMarker = Marker(
                        width: 72.0 * scale,
                        height: 72.0 * scale,
                        point: latLng,
                        builder: (ctx) => Icon(Icons.location_on, color: Colors.red, size: 32 * scale),
                      );
                      selectedLocation = latLng;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  if (singleMarker != null) MarkerLayer(markers: [singleMarker!]),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0 * scale),
                    color: Colors.blueGrey.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16.0 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Nitrogen (Azot)",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale),
                              ),
                              Transform.scale(
                                scale: scale,
                                child: Switch(
                                  value: nitrogenEnabled,
                                  onChanged: (bool value) {
                                    setState(() {
                                      nitrogenEnabled = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (nitrogenEnabled) ...[
                            Slider(
                              value: nitrogen,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (double value) {
                                setState(() {
                                  nitrogen = value;
                                });
                              },
                            ),
                            Text("Value: ${nitrogen.toStringAsFixed(2)}", style: TextStyle(fontSize: 14 * scale)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0 * scale),
                    color: Colors.blueGrey.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16.0 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Phosphorus (Fosfor)",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale),
                              ),
                              Transform.scale(
                                scale: scale,
                                child: Switch(
                                  value: phosphorusEnabled,
                                  onChanged: (bool value) {
                                    setState(() {
                                      phosphorusEnabled = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (phosphorusEnabled) ...[
                            Slider(
                              value: phosphorus,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (double value) {
                                setState(() {
                                  phosphorus = value;
                                });
                              },
                            ),
                            Text("Value: ${phosphorus.toStringAsFixed(2)}", style: TextStyle(fontSize: 14 * scale)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0 * scale),
                    color: Colors.blueGrey.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16.0 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Potassium (Potasyum)",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale),
                              ),
                              Transform.scale(
                                scale: scale,
                                child: Switch(
                                  value: potassiumEnabled,
                                  onChanged: (bool value) {
                                    setState(() {
                                      potassiumEnabled = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (potassiumEnabled) ...[
                            Slider(
                              value: potassium,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (double value) {
                                setState(() {
                                  potassium = value;
                                });
                              },
                            ),
                            Text("Value: ${potassium.toStringAsFixed(2)}", style: TextStyle(fontSize: 14 * scale)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0 * scale),
                    color: Colors.blueGrey.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16.0 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Calcium (Kalsiyum)",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale),
                              ),
                              Transform.scale(
                                scale: scale,
                                child: Switch(
                                  value: calciumEnabled,
                                  onChanged: (bool value) {
                                    setState(() {
                                      calciumEnabled = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (calciumEnabled) ...[
                            Slider(
                              value: calcium,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (double value) {
                                setState(() {
                                  calcium = value;
                                });
                              },
                            ),
                            Text("Value: ${calcium.toStringAsFixed(2)}", style: TextStyle(fontSize: 14 * scale)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0 * scale),
                    color: Colors.blueGrey.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16.0 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Magnesium (Magnezyum)",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale),
                              ),
                              Transform.scale(
                                scale: scale,
                                child: Switch(
                                  value: magnesiumEnabled,
                                  onChanged: (bool value) {
                                    setState(() {
                                      magnesiumEnabled = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (magnesiumEnabled) ...[
                            Slider(
                              value: magnesium,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (double value) {
                                setState(() {
                                  magnesium = value;
                                });
                              },
                            ),
                            Text("Value: ${magnesium.toStringAsFixed(2)}", style: TextStyle(fontSize: 14 * scale)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0 * scale),
                    color: Colors.blueGrey.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16.0 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "pH",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale),
                          ),
                          Slider(
                            value: pH,
                            min: 0.0,
                            max: 14.0,
                            onChanged: (double value) {
                              setState(() {
                                pH = value;
                              });
                            },
                          ),
                          Text("Value: ${pH.toStringAsFixed(2)}", style: TextStyle(fontSize: 14 * scale)),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0 * scale),
                    color: Colors.blueGrey.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16.0 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Organic Matter (Organik Madde)",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale)),
                          Slider(
                            value: organicMatter.toDouble(),
                            min: 0.0,
                            max: 2.0,
                            divisions: 2,
                            onChanged: (double value) {
                              setState(() {
                                organicMatter = value.toInt();
                              });
                            },
                          ),
                          Text("Value: $organicMatter", style: TextStyle(fontSize: 14 * scale)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20 * scale),
                  Card(
                    margin: EdgeInsets.all(8.0),
                    color: Colors.orange.shade400,
                    child: ListTile(
                      leading: Icon(Icons.add, size: 35),
                      title: Text(
                        "Analyze It",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      onTap: _sendDataToFirestore,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
