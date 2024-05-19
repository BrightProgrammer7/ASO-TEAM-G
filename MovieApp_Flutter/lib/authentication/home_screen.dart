import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_v2/tflite_v2.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraImage? cameraImage;
  String output = '';
  CameraController? cameraController;
  bool isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    loadModel();
  }

  void initializeCamera() async {
    try {
      final cameras = await availableCameras();
      cameraController = CameraController(
        isFrontCamera ? cameras[1] : cameras[0],
        ResolutionPreset.medium,
      );
      await cameraController!.initialize();
      cameraController!.startImageStream((image) {
        setState(() {
          cameraImage = image;
        });
      });
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void runModel() async {
    if (cameraImage != null) {
      try {
        var predictions = await Tflite.runModelOnFrame(
          bytesList: cameraImage!.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: cameraImage!.height,
          imageWidth: cameraImage!.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 3,
          threshold: 0.1,
          asynch: true,
        );
        setState(() {
          output = '';
          predictions!.forEach((prediction) {
            output +=
            '${prediction['label'].toString().substring(0, 1).toUpperCase()}${prediction['label'].toString().substring(1)} ${(prediction['confidence'] as double).toStringAsFixed(3)}\n';
          });
        });
      } on Exception catch (e) {
        print('Error running model: $e');
      }
    }
  }

  void loadModel() async {
    try {
      await Tflite.loadModel(
        model: 'asset/modele.tflite',
        labels: 'asset/labels.txt',
      );
    } on Exception catch (e) {
      print('Error loading model: $e');
    }
  }

  void toggleCamera() {
    setState(() {
      isFrontCamera = !isFrontCamera;
      cameraController!.dispose();
      cameraController = null;
      initializeCamera();
    });
  }

  void takePicture() async {
    try {
      XFile? picture = await cameraController!.takePicture();
      if (picture != null) {
        // Prédire l'image capturée
        await predictImage(picture.path);
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }
  Future<void> predictImage(String imagePath) async {
    try {
      var predictions = await Tflite.runModelOnImage(
        path: imagePath,
        numResults: 3,
        threshold: 0.1,
        imageMean: 127.5,
        imageStd: 127.5,
      );
      setState(() {
        output = '';
        predictions!.forEach((prediction) {
          output +=
          '${prediction['label'].toString().substring(0, 1).toUpperCase()}${prediction['label'].toString().substring(1)} ${(prediction['confidence'] as double).toStringAsFixed(3)}\n';
        });
      });
    } catch (e) {
      print('Error predicting image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: cameraController == null || !cameraController!.value.isInitialized
                  ? Container()
                  : AspectRatio(
                aspectRatio: cameraController!.value.aspectRatio,
                child: CameraPreview(cameraController!),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: takePicture,
                child: Text('Prendre une photo et prédire'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: toggleCamera,
                child: Text('Changer de caméra'),
              ),
            ],
          ),
          Text(
            output,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    cameraController?.dispose();
    Tflite.close();
  }
}
