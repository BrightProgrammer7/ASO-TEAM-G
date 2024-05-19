import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'flutter_youtube_downloader.dart';

class Oifik extends StatefulWidget {
  @override
  _YouTubeDownloaderWidgetState createState() => _YouTubeDownloaderWidgetState();
}

class _YouTubeDownloaderWidgetState extends State<Oifik> {
  TextEditingController _urlController = TextEditingController();
  String? _extractedLink = 'Loading...';

  String? youTube_link = "https://www.youtube.com/watch?v=gkR9rblVYP4";
  @override
  void initState() {
    super.initState();
    extractYoutubeLink();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Downloader'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Enter YouTube URL:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              child: TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: 'https://www.youtube.com/watch?v=...',
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: downloadVideo,
              child: Text('Download Video'),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> extractYoutubeLink() async {
    String? link;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      link =
      await (FlutterYoutubeDownloader.extractYoutubeLink(youTube_link!, 18)
      as FutureOr<String?>);
      print("LINK: $link");
    } on PlatformException {
      link = 'Failed to Extract YouTube Video Link.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _extractedLink = link;
    });
  }
  Future<void> downloadVideo() async {
    print("ismail");
    final result = await FlutterYoutubeDownloader.downloadVideo(
        youTube_link!, "Video Title goes Here", 18);
    print(result);
  }
}
