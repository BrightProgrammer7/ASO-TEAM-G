import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:r08fullmovieapp/RepeatedFunction/reviewui.dart';
import 'package:r08fullmovieapp/RepeatedFunction/sliderlist.dart';
import 'package:tflite_v2/tflite_v2.dart';
import '../HomePage/HomePage.dart';
import '../RepeatedFunction/TrailerUI.dart';
import '../RepeatedFunction/favoriateandshare.dart';
import '../RepeatedFunction/repttext.dart';
import 'package:r08fullmovieapp/apikey/apikey.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../main.dart';

class TvSeriesDetails extends StatefulWidget {
  var id;
  TvSeriesDetails({this.id});

  @override
  State<TvSeriesDetails> createState() => _TvSeriesDetailsState();
}

class _TvSeriesDetailsState extends State<TvSeriesDetails> {
  var tvseriesdetaildata;
  CameraImage? cameraImage;
  CameraController? cameraController;
  String output = '';
  List<Map<String, dynamic>> TvSeriesDetails = [];
  List<Map<String, dynamic>> TvSeriesREview = [];
  List<Map<String, dynamic>> similarserieslist = [];
  List<Map<String, dynamic>> recommendserieslist = [];
  List<Map<String, dynamic>> seriestrailerslist = [];
  //List<CameraDescription> cameras = [];
  Future<void>? initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize the camera
    //_initializeCamera();
    loadCamera();
    loadmodel();
  }
  loadCamera() {
    cameraController = CameraController(cameras![1], ResolutionPreset.high);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      } else {
        setState(() {
          cameraController!.startImageStream((imageStream) {
            cameraImage = imageStream;
            runModel();
          });
        });
      }
    });
  }

  runModel() async {
    if (cameraImage != null) {
      var predictions = await Tflite.runModelOnFrame(
          bytesList: cameraImage!.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: cameraImage!.height,
          imageWidth: cameraImage!.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 2,
          threshold: 0.1,
          asynch: true);
      setState(() {
        output = '';
        predictions!.forEach((prediction) {
          output +=
          '${prediction['label'].toString().substring(0, 1).toUpperCase()}${prediction['label'].toString().substring(1)} ${(prediction['confidence'] as double).toStringAsFixed(3)}\n';
        });
      });
    }
  }

  loadmodel() async {
    await Tflite.loadModel(
        model: "assets/model_person.tflite", labels: "assets/labels1.txt");
  }



  Future<void> tvseriesdetailfunc() async {
    var tvseriesdetailurl = 'https://api.themoviedb.org/3/tv/' +
        widget.id.toString() +
        '?api_key=$apikey';
    var tvseriesreviewurl = 'https://api.themoviedb.org/3/tv/' +
        widget.id.toString() +
        '/reviews?api_key=$apikey';
    var similarseriesurl = 'https://api.themoviedb.org/3/tv/' +
        widget.id.toString() +
        '/similar?api_key=$apikey';
    var recommendseriesurl = 'https://api.themoviedb.org/3/tv/' +
        widget.id.toString() +
        '/recommendations?api_key=$apikey';
    var seriestrailersurl = 'https://api.themoviedb.org/3/tv/' +
        widget.id.toString() +
        '/videos?api_key=$apikey';

    var tvseriesdetailresponse = await http.get(Uri.parse(tvseriesdetailurl));
    if (tvseriesdetailresponse.statusCode == 200) {
      tvseriesdetaildata = jsonDecode(tvseriesdetailresponse.body);
      for (var i = 0; i < 1; i++) {
        TvSeriesDetails.add({
          'backdrop_path': tvseriesdetaildata['backdrop_path'],
          'title': tvseriesdetaildata['original_name'],
          'vote_average': tvseriesdetaildata['vote_average'],
          'overview': tvseriesdetaildata['overview'],
          'status': tvseriesdetaildata['status'],
          'releasedate': tvseriesdetaildata['first_air_date'],
        });
      }
      for (var i = 0; i < tvseriesdetaildata['genres'].length; i++) {
        TvSeriesDetails.add({
          'genre': tvseriesdetaildata['genres'][i]['name'],
        });
      }
      for (var i = 0; i < tvseriesdetaildata['created_by'].length; i++) {
        TvSeriesDetails.add({
          'creator': tvseriesdetaildata['created_by'][i]['name'],
          'creatorprofile': tvseriesdetaildata['created_by'][i]['profile_path'],
        });
      }
      for (var i = 0; i < tvseriesdetaildata['seasons'].length; i++) {
        TvSeriesDetails.add({
          'season': tvseriesdetaildata['seasons'][i]['name'],
          'episode_count': tvseriesdetaildata['seasons'][i]['episode_count'],
        });
      }
    }

    var tvseriesreviewresponse = await http.get(Uri.parse(tvseriesreviewurl));
    if (tvseriesreviewresponse.statusCode == 200) {
      var tvseriesreviewdata = jsonDecode(tvseriesreviewresponse.body);
      for (var i = 0; i < tvseriesreviewdata['results'].length; i++) {
        TvSeriesREview.add({
          'name': tvseriesreviewdata['results'][i]['author'],
          'review': tvseriesreviewdata['results'][i]['content'],
          "rating": tvseriesreviewdata['results'][i]['author_details']
          ['rating'] ==
              null
              ? "Not Rated"
              : tvseriesreviewdata['results'][i]['author_details']['rating']
              .toString(),
          "avatarphoto": tvseriesreviewdata['results'][i]['author_details']
          ['avatar_path'] ==
              null
              ? "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png"
              : "https://image.tmdb.org/t/p/w500" +
              tvseriesreviewdata['results'][i]['author_details']
              ['avatar_path'],
          "creationdate":
          tvseriesreviewdata['results'][i]['created_at'].substring(0, 10),
          "fullreviewurl": tvseriesreviewdata['results'][i]['url'],
        });
      }
    }

    var similarseriesresponse = await http.get(Uri.parse(similarseriesurl));
    if (similarseriesresponse.statusCode == 200) {
      var similarseriesdata = jsonDecode(similarseriesresponse.body);
      for (var i = 0; i < similarseriesdata['results'].length; i++) {
        similarserieslist.add({
          'poster_path': similarseriesdata['results'][i]['poster_path'],
          'name': similarseriesdata['results'][i]['original_name'],
          'vote_average': similarseriesdata['results'][i]['vote_average'],
          'id': similarseriesdata['results'][i]['id'],
          'Date': similarseriesdata['results'][i]['first_air_date'],
        });
      }
    }

    var recommendseriesresponse = await http.get(Uri.parse(recommendseriesurl));
    if (recommendseriesresponse.statusCode == 200) {
      var recommendseriesdata = jsonDecode(recommendseriesresponse.body);
      for (var i = 0; i < recommendseriesdata['results'].length; i++) {
        recommendserieslist.add({
          'poster_path': recommendseriesdata['results'][i]['poster_path'],
          'name': recommendseriesdata['results'][i]['original_name'],
          'vote_average': recommendseriesdata['results'][i]['vote_average'],
          'id': recommendseriesdata['results'][i]['id'],
          'Date': recommendseriesdata['results'][i]['first_air_date'],
        });
      }
    }

    var tvseriestrailerresponse = await http.get(Uri.parse(seriestrailersurl));
    if (tvseriestrailerresponse.statusCode == 200) {
      var tvseriestrailerdata = jsonDecode(tvseriestrailerresponse.body);
      for (var i = 0; i < tvseriestrailerdata['results'].length; i++) {
        if (tvseriestrailerdata['results'][i]['type'] == "Trailer") {
          seriestrailerslist.add({
            'key': tvseriestrailerdata['results'][i]['key'],
          });
        }
      }
      seriestrailerslist.add({'key': 'aJ0cZTcTh90'});
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(14, 14, 14, 1),
      body: FutureBuilder(
        future: tvseriesdetailfunc(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    onPressed: () {
                      SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.manual,
                        overlays: [SystemUiOverlay.bottom],
                      );
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown,
                      ]);
                      Navigator.pop(context);
                    },
                    icon: Icon(FontAwesomeIcons.circleArrowLeft),
                    iconSize: 28,
                    color: Colors.white,
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                              (route) => false,
                        );
                      },
                      icon: Icon(FontAwesomeIcons.houseUser),
                      iconSize: 25,
                      color: Colors.white,
                    ),
                  ],
                  backgroundColor: Color.fromRGBO(18, 18, 18, 0.5),
                  expandedHeight: MediaQuery.of(context).size.height * 0.35,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: FittedBox(
                      fit: BoxFit.fill,
                      child: trailerwatch(
                        trailerytid: seriestrailerslist[0]['key'],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    addtofavoriate(
                      id: widget.id,
                      type: 'tv',
                      Details: TvSeriesDetails,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10, top: 10),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: tvseriesdetaildata['genres']!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(right: 10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(25, 25, 25, 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: genrestext(
                                  TvSeriesDetails[index + 1]['genre'].toString(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    // Replace this Container with Camera preview
                    Container(
                      child: Column(
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
                          Text(
                            "",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),

                          ),
                          GestureDetector(
                            onTap: () {
                              closeApp();
                            },
                            child: Text(
                              "Serie Overview", // Utilisez votre variable ici
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),)

                        ],
                      ),
                    )
                    ,

                    /*Container(
                      padding: EdgeInsets.only(left: 10, top: 12),
                      child: tittletext("Series Overview : "),
                      //Series Overview
                    ),*/
                    Container(
                      padding: EdgeInsets.only(left: 10, top: 20),
                      child: overviewtext(
                        TvSeriesDetails[0]['overview'].toString(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 10),
                      child: ReviewUI(revdeatils: TvSeriesREview),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 10, top: 20),
                      child: boldtext("Status : " +
                          TvSeriesDetails[0]['status'].toString()),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 10, top: 20),
                      child: tittletext("Created By : "),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 10, top: 10),
                      height: 150,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: tvseriesdetaildata['created_by']!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(right: 10),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(25, 25, 25, 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 45,
                                      backgroundImage: NetworkImage(
                                        'https://image.tmdb.org/t/p/w500' +
                                            TvSeriesDetails[index + 4]
                                            ['creatorprofile']
                                                .toString(),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    genrestext(
                                      TvSeriesDetails[index + 4]['creator']
                                          .toString(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 10, top: 20),
                      child: normaltext("Total Seasons : " +
                          tvseriesdetaildata['seasons'].length.toString()),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 10, top: 20),
                      child: normaltext("Release date : " +
                          TvSeriesDetails[0]['releasedate'].toString()),
                    ),
                    sliderlist(
                      similarserieslist,
                      'Similar Series',
                      'tv',
                      similarserieslist.length,
                    ),
                    sliderlist(
                      recommendserieslist,
                      'Recommended Series',
                      'tv',
                      recommendserieslist.length,
                    ),
                    Container(),
                  ]),
                ),
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(color: Colors.amber.shade400),
            );
          }
        },
      ),
    );
  }
  void closeApp() {
    SystemNavigator.pop();
  }
}
