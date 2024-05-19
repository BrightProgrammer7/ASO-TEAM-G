import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeDownloaderWidget extends StatefulWidget {
  final String videoId;

  const YouTubeDownloaderWidget({Key? key, required this.videoId})
      : super(key: key);

  @override
  _YouTubeDownloaderWidgetState createState() =>
      _YouTubeDownloaderWidgetState();
}

class _YouTubeDownloaderWidgetState extends State<YouTubeDownloaderWidget> {
  String _downloadUrl = '';
  String _downloadStatus = '';

  @override
  void initState() {
    super.initState();
    _fetchDownloadUrl();
  }

  Future<void> _fetchDownloadUrl() async {
    var yt = YoutubeExplode();
    var manifest = await yt.videos.streamsClient.getManifest(widget.videoId);
    var audio = manifest.audioOnly.last;
    setState(() {
      _downloadUrl = audio.url.toString();
    });
    yt.close();
  }

  Future<void> _downloadVideo() async {
    try {
      final directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      final savePath = directory!.path;
      final taskId = await FlutterDownloader.enqueue(
        url: _downloadUrl,
        savedDir: savePath,
        fileName: 'video.mp4',
        showNotification: true,
        openFileFromNotification: true,
      );
      setState(() {
        _downloadStatus = 'Téléchargement en cours...';
      });
      FlutterDownloader.registerCallback((id, status, progress) {
        if (taskId == id && status == DownloadTaskStatus.complete) {
          setState(() {
            print("::: ");
            _downloadStatus = 'Téléchargement terminé!';
          });
        }
        else{
          _downloadStatus = 'Téléchargement Pas terminer';
        }
      });
    } catch (error) {
      setState(() {
        print("Erreur ismil: $error");
        _downloadStatus = 'Erreur lors du téléchargement: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Téléchargement YouTube'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_downloadUrl.isNotEmpty)
              ElevatedButton(
                onPressed: _downloadVideo,
                child: Text('Télécharger la vidéo'),
              ),
            SizedBox(height: 20),
            if (_downloadStatus.isNotEmpty)
              Text(_downloadStatus),
          ],
        ),
      ),
    );
  }
}