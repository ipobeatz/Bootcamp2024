import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int touchedIndex = -1;
  int expandedIndex = -1;

  final dataMap = {
    "Wheat": 15.0,
    "Beans": 23.0,
    "Maize": 61.0,
  };

  final colorList = [
    Colors.orange,
    Colors.blue,
    Colors.red,
  ];

  String getAssetPath(int index) {
    switch (index) {
      case 0:
        return 'assets/wheat.svg';
      case 1:
        return 'assets/beans.svg';
      case 2:
        return 'assets/corn.svg';
      default:
        return 'assets/corn.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Analysis'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Kırşehir/Çiçekdağı',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: Column(
          children: [
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
                            if (pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  child: SvgPicture.asset(
                    getAssetPath(touchedIndex),
                    height: 60,
                    width: 60,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildFeatureCard(context, 'Seed Analyze', 'assets/corn.svg', 0, 'Detailed analysis of seed performance and suggestions for improvement.'),
                  _buildFeatureCard(context, 'Fertilizer Recommendation', 'assets/fertilizer.svg', 1, 'Recommendations for the best fertilizers to use based on soil quality.'),
                  _buildFeatureCard(context, 'Inventory Maintenance', 'assets/inventory.svg', 2, 'Tips and best practices for maintaining your agricultural inventory.'),
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

  Widget _buildFeatureCard(BuildContext context, String title, String assetPath, int index, String detailMessage) {
    bool isExpanded = expandedIndex == index;

    return Card(
      margin: const EdgeInsets.all(8.0),
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
}
