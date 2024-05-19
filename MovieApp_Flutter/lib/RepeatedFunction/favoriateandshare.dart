import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:r08fullmovieapp/SqfLitelocalstorage/NoteDbHelper.dart';
import 'package:r08fullmovieapp/RepeatedFunction/repttext.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../authentication/meduim.dart';
import '../maps/map_screen.dart';
import '../maps/nouvelle_page.dart';

// Importez la nouvelle page


class addtofavoriate extends StatefulWidget {
  var id, type, Details;
  addtofavoriate({
    this.id,
    this.type,
    this.Details,
  });

  @override
  State<addtofavoriate> createState() => _addtofavoriateState();
}

class _addtofavoriateState extends State<addtofavoriate> {
  Future checkfavoriate() async {
    FavMovielist()
        .search(widget.id.toString(), widget.Details[0]['title'].toString(),
        widget.type)
        .then((value) {
      if (value == 0) {
        print('notanythingfound');
        favoriatecolor = Colors.white;
      } else {
        //print the tmdbname and tmdbid and tmdbtype and tmdbrating from database
        print('surelyfound');
        favoriatecolor = Colors.red;
      }
    });
    await Future.delayed(Duration(milliseconds: 100));
  }

  Color? favoriatecolor;

  addatatbase(
      id,
      name,
      type,
      rating,
      customcolor,
      ) async {
    if (customcolor == Colors.white) {
      FavMovielist().insert({
        'tmdbid': id,
        'tmdbtype': type,
        'tmdbname': name,
        'tmdbrating': rating,
      });
      favoriatecolor = Colors.red;
      Fluttertoast.showToast(
          msg: "Added to Favorite",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (customcolor == Colors.red) {
      FavMovielist().deletespecific(id, type);
      favoriatecolor = Colors.white;
      Fluttertoast.showToast(
          msg: "Removed from Favorite",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  void initState() {
    super.initState();
    checkfavoriate();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            width: MediaQuery.of(context).size.width / 2,
            child: FutureBuilder(
              future: checkfavoriate(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    height: 55,
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      height: 50,
                      width: 50,
                      child: IconButton(
                        icon: Icon(Icons.favorite,
                            color: favoriatecolor, size: 30),
                        onPressed: () {
                          print('pressed');
                          setState(() {
                            addatatbase(
                              widget.id.toString(),
                              widget.Details[0]['title'].toString(),
                              widget.type,
                              widget.Details[0]['vote_average'].toString(),
                              favoriatecolor,
                            );
                          });
                        },
                      ),
                    ),
                  );
                } else {
                  return Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width,
                  );
                }
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()),
              );
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  normaltext("Cinema"),
                  SizedBox(width: 10),

                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _downloadVideo();
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.mobile_friendly, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  normaltext("Download"),
                  SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
Future<void> _downloadVideo() async {
  PermissionStatus status = await Permission.storage.request();
  print("le status: $status");
  try {
    //var status1 = await Permission.storage.request();

    //print("ISMAIL:: $status1");
    //print("ISMAIL1:: $status");
    //if (status.isGranted) {
    var ytExplode = YoutubeExplode();
    var video = await ytExplode.videos.get(url);
    var manifest = await ytExplode.videos.streamsClient.getManifest(video.id);
    var streamInfo = manifest.muxed.withHighestBitrate();
    final appDocDir = await getExternalStorageDirectory();
    final downloadPath = '/storage/emulated/0/Movies';
    //Directory tempDir = await DownloadsPathProvider.downloadsDirectory;
    Directory? directory = await getExternalStorageDirectory();
    String tempPath = directory.toString();

    //final savePath = '${appDocDir!.path}/${video.title}.mp4';
    final savePath = '$downloadPath/${video.title}.mp4';
    print("LE PATH. $savePath");
    var file = File(savePath);
    print("Save. $savePath");
    var fileStream = file.openWrite();
    var stream = ytExplode.videos.streamsClient.get(streamInfo);
    await stream.pipe(fileStream);

    await fileStream.flush();
    await fileStream.close();

    print('Video downloaded to: $savePath');
    final taskId = await FlutterDownloader.enqueue(
      url: streamInfo.url.toString(),
      savedDir: downloadPath,
      fileName: '${video.title}.mp4',
      showNotification: true,
      openFileFromNotification: true,
    );

    FlutterDownloader.registerCallback((id, status, progress) {
      if (taskId == id) {
        print('Download task ($id) is in status ($status) and progress ($progress)');
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Video downloaded successfully.'),
      ),
    );
    //}
    /*else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission denied.'),
          ),
        );
      }*/
  } catch (e) {
    print('Failed to download video: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to download video: $e'),
      ),
    );
  }
}
}
