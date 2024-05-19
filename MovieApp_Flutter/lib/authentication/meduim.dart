import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeDownloader extends StatefulWidget {
  @override
  _YouTubeDownloaderWidgetState createState() => _YouTubeDownloaderWidgetState();

}
class _YouTubeDownloaderWidgetState extends State<YouTubeDownloader> {
  TextEditingController _urlController = TextEditingController();

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

              onPressed:_downloadVideo,
              child: Text('Download Video'),
            ),
          ],
        ),
      ),
    );
  }

