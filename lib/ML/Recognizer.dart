import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Recognition.dart';

class Recognizer {
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;
  static const int WIDTH = 112;
  static const int HEIGHT = 112;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, Recognition> registered = {};

  Recognizer({int? numThreads}) {
    _interpreterOptions = InterpreterOptions();

    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }
    loadModel();
    loadRegisteredFaces();
  }

  Future<void> loadRegisteredFaces() async {
    try {
      QuerySnapshot snapshot =
      await firestore.collection('registered_faces').get();
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        String name = doc['name'];
        List<double> embedding =
        (doc['embedding'] as String).split(',').map(double.parse).toList();
        registered[name] = Recognition(name, Rect.zero, embedding, 0);
      }
      print('Loaded registered faces: ${registered.length}');
    } catch (e) {
      print('Error loading registered faces: $e');
    }
  }

  Future<void> registerFaceInDB(String name, List<double> embedding) async {
    try {
      // Create a map to store the face information
      Map<String, dynamic> faceData = {
        'name': name,
        'embedding':
        embedding.join(","), // Convert embedding to comma-separated string
      };

      // Add the data to the 'registered_faces' collection in Firebase
      await firestore.collection('registered_faces').doc(name).set(faceData);
      print('Successfully registered face: $name');
    } catch (e) {
      // Log an error message if something goes wrong
      print('Error registering face: $e');
    }
  }

  Future<void> loadModel() async {
    try {
      interpreter =
      await Interpreter.fromAsset('assets/mobile_face_net.tflite');
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  List<dynamic> imageToArray(img.Image inputImage) {
    img.Image resizedImage =
    img.copyResize(inputImage, width: WIDTH, height: HEIGHT);
    List<double> flattenedList =
    resizedImage.getBytes().map((value) => value.toDouble()).toList();
    Float32List float32Array = Float32List.fromList(flattenedList);
    int channels = 3;
    int height = HEIGHT;
    int width = WIDTH;
    Float32List reshapedArray = Float32List(1 * height * width * channels);
    for (int c = 0; c < channels; c++) {
      for (int h = 0; h < height; h++) {
        for (int w = 0; w < width; w++) {
          int index = c * height * width + h * width + w;
          reshapedArray[index] =
              (float32Array[c * height * width + h * width + w] - 127.5) /
                  127.5;
        }
      }
    }
    return reshapedArray.reshape([1, 112, 112, 3]);
  }

  Recognition recognize(img.Image image, Rect location) {
    var input = imageToArray(image);

    // Prepare output for the model
    List output = List.filled(1 * 192, 0).reshape([1, 192]);
    final runs = DateTime.now().millisecondsSinceEpoch;
    interpreter.run(input, output);
    final run = DateTime.now().millisecondsSinceEpoch - runs;
    print('Time to run inference: $run ms$output');

    List<double> outputArray = output.first.cast<double>();

    // Find the nearest registered face
    Pair pair = findNearest(outputArray);
    print("distance= ${pair.distance}");

    // Create Recognition object
    Recognition recognition =
    Recognition(pair.name, location, outputArray, pair.distance);

    // Save the recognition result
    if (pair.name != "Unknown") {
      saveRecognition(pair.name);
    } else {
      print("No match found. Recognition skipped.");
    }

    return recognition;
  }

  void saveRecognition(String name) async {
    final timestamp = Timestamp.now();

    await FirebaseFirestore.instance.collection('recognition_history').add({
      'name': name,
      'timestamp': timestamp,
    });

    print('Recognition saved for $name at $timestamp');
  }

  Pair findNearest(List<double> emb) {
    Pair pair = Pair("Unknown", -5);
    for (MapEntry<String, Recognition> item in registered.entries) {
      final String name = item.key;
      List<double> knownEmb = item.value.embeddings;
      double distance = 0;
      for (int i = 0; i < emb.length; i++) {
        double diff = emb[i] - knownEmb[i];
        distance += diff * diff;
      }
      distance = sqrt(distance);
      if (pair.distance == -5 || distance < pair.distance) {
        pair.distance = distance;
        pair.name = name;
      }
    }
    return pair;
  }

  void close() {
    interpreter.close();
  }
}

class Pair {
  String name;
  double distance;
  Pair(this.name, this.distance);
}