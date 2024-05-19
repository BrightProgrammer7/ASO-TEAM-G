import 'dart:convert';
import 'package:http/http.dart' as http;
class Result {
  late String? title;
  late String? thumb;
  late String? filesize_audio;
  late String? filesize_video;
  late String? audio;
  late String? audio_asli;
  late String? video;
  late String? video_asli;

  Result({this.title, this.thumb, this.filesize_audio, this.filesize_video,
    this.audio, this.audio_asli, this.video, this.video_asli});

  factory Result.createPostResult(Map object){
    return Result(
      title: object['title'],
      thumb: object['thumb'],
      filesize_audio: object['filesize_audio'],
      filesize_video: object['filesize_video'],
      audio: object['audio'],
      audio_asli: object['audio_asli'],
      video: object['video'],
      video_asli: object['video_asli'],
    );
  }
  static Future connectToApi(String url) async{
    print("ismaiiil");
    String apiUrl = 'https://ytdl.akuari.my.id/download//youtube?link=' + url;
    //String apiUrl = 'https://www.youtube.com/watch?v=-Jh4824usMs';
    final response = await http.get(Uri.parse(apiUrl));
    if(response.statusCode == 200) {
      print("ook");
      return Result.createPostResult(jsonDecode(response.body));
    } else {
      print("Failed to load url");
      throw Exception('Failed to load url');
    }
  }
}