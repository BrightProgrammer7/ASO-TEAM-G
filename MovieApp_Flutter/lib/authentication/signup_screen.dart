import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:r08fullmovieapp/authentication/reusubale_widget.dart';
import 'package:r08fullmovieapp/authentication/signin_screen.dart';
import 'package:tflite_v2/tflite_v2.dart';
import '../utils/color_utils.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  CameraImage? cameraImage;
  String output = '';
  double nbr=3;
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
      print("PRES");
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
          var nbr1=predictions[0];
          nbr=nbr1['confidence'];
        });
      });
    } catch (e) {
      print('Error predicting image: $e');
    }
  }

  final _auth = FirebaseAuth.instance;
  final _formkey = GlobalKey<FormState>();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [

                Colors.black, // Ajoutez la couleur noire
                Colors.white
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
                child: Column(
                  children: <Widget>[
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
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black, backgroundColor: Colors.white, // Texte noir
                          ),
                          child: Text('take a picture'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: toggleCamera,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black, backgroundColor: Colors.white, // Texte noir
                          ),
                          child: Text('change camera'),
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

                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter UserName", Icons.person_outline,

                        false,
                        _userNameTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter Email Id", Icons.person_outline, false,
                        _emailTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter Password", Icons.lock_outlined, true,
                        _passwordTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    firebaseUIButton(context, "Sign Up",() {

                      FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                          .then((value) {
                        CollectionReference ref = FirebaseFirestore.instance.collection('users');
                        var user = _auth.currentUser;
                        if(nbr>0.5){
                          ref.doc(user!.uid).set({'email': _emailTextController.text, 'rool': "adult"});
                        }
                        else{
                          ref.doc(user!.uid).set({'email': _emailTextController.text, 'rool': "enfant"});
                        }
                        print("Created New Account : $user");
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => SignInScreen()));
                      }).onError((error, stackTrace) {
                        print("Error ${error.toString()}");
                      });
                    })
                  ],
                ),
              ))),
    );
  }
  void signUp(String email, String password, String rool) async {
    CircularProgressIndicator();
    if (_formkey.currentState!.validate()) {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {postDetailsToFirestore(email, rool)})
          .catchError((e) {});
    }
  }

  postDetailsToFirestore(String email, String rool) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = _auth.currentUser;
    CollectionReference ref = FirebaseFirestore.instance.collection('users');
    ref.doc(user!.uid).set({'email': _emailTextController.text, 'rool': rool});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }
  @override
  void dispose() {
    super.dispose();
    cameraController?.dispose();
    Tflite.close();
  }
}