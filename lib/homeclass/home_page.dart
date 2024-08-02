import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_analysis/fieldclass/field_add_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> fieldNames = [];
  String? selectedField;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> names = [];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchFieldNames();
  }

  Future<void> fetchFieldNames() async {
    final CollectionReference fieldsCollection =
    FirebaseFirestore.instance.collection('fields');
    User? user = auth.currentUser;

    try {
      QuerySnapshot snapshot = await firestore.collection('fields').where('userID', isEqualTo: user?.uid).get();
      names = snapshot.docs
          .map((doc) => {
        'id': doc.id,
        'name': doc['name'].toString(),
        'seed' : doc['seedSuggestion'].toString()
      })
          .toList();

      setState(() {
        fieldNames = names;
        if (fieldNames.isNotEmpty) {
          selectedField = fieldNames[0]['id'];
        }
      });

    } catch (e) {
      print("Error fetching field names: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Analysis'),
        backgroundColor: Colors.orange.shade400,
        actions: [

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: Column(
          children: [

        Card(
        margin: const EdgeInsets.all(4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/Untitled_design.png',
                height: 28, // İkonun yüksekliğini ayarlar
                width: 28,  // İkonun genişliğini ayarlar
              ),
              const SizedBox(width: 8.0),
              DropdownButton<String>(
                value: selectedField,
                icon: const Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Icon(Icons.expand_more, color: Colors.black),
                ),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.bold),
                alignment: Alignment.center,
                underline: SizedBox(), // Alt çizgiyi kaldırır
                onChanged: (String? newValue) {
                  setState(() {
                    selectedField = newValue!;
                    selectedIndex = fieldNames.indexWhere((field) => field['id'] == newValue);
                  });
                },
                items: fieldNames.map<DropdownMenuItem<String>>((field) {
                  return DropdownMenuItem<String>(
                    value: field['id'],
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: Text(
                        field['name'],
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
        const Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                'The percentage yield of your soil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [

                AspectRatio(
                  aspectRatio: 1.6,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 48,
                      sections: showingSections(),
                      pieTouchData: PieTouchData(
                        touchCallback: (PieTouchResponse? pieTouchResponse) {
                          setState(() {
                            if (pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse.touchedSection!
                                .touchedSectionIndex;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  child: SvgPicture.asset(
                    getAssetPath(selectedIndex),
                    height: 60,
                    width: 60,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildFeatureCard(
                      context, 'Seed Analyze', 'assets/seed-svgrepo-com.svg', 0,
                      'Detailed analysis of seed performance and suggestions for improvement.'),
                  _buildFeatureCard(context, 'Fertilizer Recommendation',
                      'assets/fertilizer.svg', 1,
                      'Recommendations for the best fertilizers to use based on soil quality.'),
                  _buildFeatureCard(
                      context, 'Inventory Maintenance', 'assets/inventory.svg',
                      2,
                      'Tips and best practices for maintaining your agricultural inventory.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(dataMap.length, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 25 : 16;
      final double radius = isTouched ? 60 : 50;

      return PieChartSectionData(
        color: colorList[i],
        value: dataMap.values.elementAt(i),
        title: '${dataMap.values.elementAt(i)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
    });
  }

  Widget _buildFeatureCard(BuildContext context, String title, String assetPath,
      int index, String detailMessage, {Color? backgroundColor}) {
    backgroundColor ??= Colors.blueGrey.shade50;
    bool isExpanded = expandedIndex == index;

    return Card(
      margin: const EdgeInsets.all(8.0),
      color: backgroundColor,
      child: Column(
        children: [
          ListTile(
            leading: SvgPicture.asset(
              assetPath,
              height: 40,
              width: 40,
            ),
            title: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  expandedIndex = -1;
                } else {
                  expandedIndex = index;
                }
              });
            },
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            child: Visibility(
              visible: isExpanded,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  detailMessage,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getAssetPath(int index) {
    print("mcmc" + index.toString());

    // names değişkeni null ise veya index geçersizse
    if (names == null || index < 0 || index >= names.length) {
      print("ibo: Default asset returned due to null names or invalid index.");
      return 'assets/corn.svg'; // Varsayılan bir SVG yolu
    }

    print("ibo" + names[index]['seed']);

    switch (names[index]['seed']) {
      case "üzüm":
        return 'assets/grapes-svgrepo-com.svg';
      case "domates":
        return 'assets/tomato.svg';
      case "elma":
        return 'assets/apple.svg';
      case "çay":
        return 'assets/tea-cup-mug-svgrepo-com.svg';
      case "şeftali":
        return 'assets/peach.svg';
      case "arpa":
        return 'assets/barley.svg';
      case "patates":
        return 'assets/potato.svg';
      case "lavanta":
        return 'assets/lavender.svg';
      case "biber":
        return 'assets/chili-pepper.svg';
      case "marul":
        return 'assets/lettuce.svg';
      case "havuç":
        return 'assets/carrot-svgrepo-com.svg';
      case "yaban mersini":
        return 'assets/blueberries-svgrepo-com.svg';
      case "üzüm":
        return 'assets/grapes-svgrepo-com.svg';
      case "zeytin":
        return 'assets/olive-1-svgrepo-com.svg';
      case "fasulye":
        return 'assets/beans-svgrepo-com.svg';
      case "buğday":
        return 'assets/wheat-svgrepo-com.svg';

      default:
        return 'assets/corn.svg';
    }
  }

  final dataMap = {
    "Wheat": 75.0,
    "orange" : 25.0
  };

  final colorList = [
    Colors.orange,
    Colors.blue,
    Colors.red,
  ];

  int touchedIndex = -1;
  int expandedIndex = -1;
}
