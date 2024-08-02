import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math' as math;  // Dart'ın matematik kütüphanesini içe aktar

class SeedSuggestionModel {
  late Interpreter _interpreter;
  // Sınıf isimlerinizin listesini modelinizin çıktı boyutuna uygun olarak güncelleyin
  List<String> classNames = [
    'buğday', 'domates', 'elma', 'çay', 'şeftali',
    'arpa', 'patates', 'lavanta', 'biber', 'marul',
    'havuç', 'yaban mersini', 'üzüm', 'zeytin', 'fasulye'
  ];

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/seed_suggestion2.tflite');
    print("Model yüklendi");
  }

  Future<String> predictSeed(List<double> input) async {
    try {
      var inputTensor = [input];
      var outputTensor = List<List<double>>.filled(1, List<double>.filled(15, 0.0));
      _interpreter.run(inputTensor, outputTensor);
      int predictedIndex = outputTensor[0].indexOf(outputTensor[0].reduce(math.max));


      print("adana" + classNames[predictedIndex]);

      return classNames[predictedIndex];


    } catch (e) {
      print("Error during prediction: $e");
      return "Prediction error";
    }
  }


  void dispose() {
    _interpreter.close();
    print("Model kapatıldı");
  }
}

