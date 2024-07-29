import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() {
  runApp(MyApptest());
}

class MyApptest extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApptest> {
  final TextEditingController _controller = TextEditingController();
  String _result = "Enter a number";
  Interpreter? _interpreter;

  @override
  void initState() {
    super.initState();
    loadModel();
    print('Trying to load the model...');
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/simple_random_model.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
      setState(() {
        _result = "Failed to load model: $e";
      });
    }
  }


  Future<void> predictNumber(double input) async {
    if (_interpreter == null) {
      setState(() {
        _result = "Model not loaded";
      });
      return;
    }

    // Girdiyi ve çıktıyı hazırlayın
    var inputTensor = [input];
    var outputTensor = List.generate(1, (index) => List.filled(3, 0.0));  // Güncellendi

    _interpreter!.run(inputTensor, outputTensor);

    // En yüksek olasılıklı sınıfı bulun
    int predictedIndex = outputTensor[0].indexOf(outputTensor[0].reduce((curr, next) => curr > next ? curr : next));

    setState(() {
      _result = "Predicted: $predictedIndex";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('TensorFlow Lite Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter a number',
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  double input = double.tryParse(_controller.text) ?? 0.0;
                  predictNumber(input);
                },
                child: Text('Predict'),
              ),
              SizedBox(height: 16.0),
              Text(
                _result,
                style: TextStyle(fontSize: 24.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
