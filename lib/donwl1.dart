import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:down_ld/file_storage.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';

import 'package:path_provider/path_provider.dart';

class Donw1 extends StatefulWidget {
  const Donw1({super.key});

  @override
  State<Donw1> createState() => _Donw1State();
}

class _Donw1State extends State<Donw1> {
  @override
  void initState() {
    super.initState();
  }

  Future<File> _downloadFile(String url, String filename) async {
    http.Client client = new http.Client();

    var req = await http.get(Uri.parse(url));
    var bytes = req.bodyBytes;
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _downloadFile(
              'https://images.unsplash.com/photo-1688371464319-0fb102189aca?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1578&q=80',
              '123');
        },
        child: const Icon(Icons.download_rounded),
      ),
      appBar: AppBar(title: Text('Donwladoa')),
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Text('Extracted Link '),
        ],
      ),
    );
  }
}

class FileDownloaderScreen extends StatefulWidget {
  const FileDownloaderScreen({Key? key}) : super(key: key);

  @override
  State createState() => _FileDownloaderScreenState();
}

class _FileDownloaderScreenState extends State {
  var myList = {"name": "GeeksForGeeks"};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // First parameter will data you want store .
            // It must be a in form of string
            // Second parameter will be the file name with extensions.
            FileStorage.writeCounter(myList.toString(), "geeksforgeeks.txt");
          },
          tooltip: 'Save File',
          child: const Icon(Icons.save),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            ElevatedButton(
                onPressed: () {
                  downloadFile();
                },
                child: Text('aaa')),
            ElevatedButton(
                onPressed: () {
                  getVideoUrlFromYoutube(
                      'https://total.wpexplorer.com/docs/get-embed-urllink-youtube-video/');
                },
                child: Text('YOUTUBE BUTTON'))
          ],
        ),
      ),
    );
  }

  ///
  /// download file function
  downloadFile() async {
    var time = DateTime.now().microsecondsSinceEpoch;
    var path = '/storage/emulated/0/Download/image-$time.mp4';
    var file = File(path);
    var res = await get(Uri.parse(
        'https://total.wpexplorer.com/docs/get-embed-urllink-youtube-video/'));

    print(res.body);
    // file.writeAsBytes(res.bodyBytes).then((value) {
    //   print(value);
    //   print('downloaded');
    // }).catchError((err) {
    //   print(err);
    // });
  }

  static String _getVideoId(String url) {
    try {
      var id = '';
      // id = url.substring(url.indexOf('?v=') + '?v='.length);
      url = url.replaceAll("https://www.youtube.com/watch?v=", "");
      url = url.replaceAll("https://m.youtube.com/watch?v=", "");

      print(
          "https://www.youtube.com/get_video_info?video_id=${id}&el=embedded&ps=default&eurl=&gl=US&hl=en");
      return 'https://www.youtube.com/get_video_info?video_id=${id}&el=embedded&ps=default&eurl=&gl=US&hl=en';
    } catch (e) {
      return e.toString();
    }
  }

  static Future<List<String>> getVideoUrlFromYoutube(String youtubeUrl) async {
    // Extract the info url using the past method
    var link = await _getVideoId(youtubeUrl);

    // Checker if the link is valid
    if (link == null) {
      print('Null Video Id from Link: $youtubeUrl');
      // Logger().error('Player Error', 'Null Video Id from Link: $youtubeUrl');
    }

    // Links Holder
    var links = <String>[]; // This could turn into a map if one desires it

    // Now make the request
    var networkClient = Dio();
    var response = await networkClient.get(link);

    // To make autocomplete easier
    var responseText = response.data.toString();

    // This sections the chuck of data into multiples so we can parse it
    var sections = Uri.decodeFull(responseText).split('&');

    // This is the response json we are looking for
    var playerResponse = <String, dynamic>{};

    // Optimized better
    for (int i = 0; i < sections.length; i++) {
      String s = sections[i];

      // We can have multiple '=' inside the json, we want to divide the chunk by only the first equal
      int firstEqual = s.indexOf('=');

      // Sanity Check
      if (firstEqual < 0) {
        continue;
      }

      // Here we create the key value of the chunk of data
      String key = s.substring(0, firstEqual);
      String value = s.substring(firstEqual + 1);

      // This is the key that holds the mp4 information
      if (key == 'player_response') {
        playerResponse = jsonDecode(value);
        break;
      }
    }

    // Now that we have the json we need, we can start pointing to the links that holds the mp4
    // The node we need
    Map data = playerResponse['streamingData'];

    // Aggregating the data
    if (data['formats'] != null) {
      var formatLinks = [];
      formatLinks = data['formats'];
      if (formatLinks != null) {
        formatLinks.forEach((element) {
          // you can read the map here to get additional video infomation
          // like quality width height and bitrate
          // For this example however I just want the url
          links.add(element['url']);
        });
      }
    }

    // And adaptive ones also
    if (data['adaptiveFormats'] is List) {
      var formatLinks = [];
      formatLinks = data['adaptiveFormats'];
      formatLinks.forEach((element) {
        // you can read the map here to get additional video infomation
        // like quality width height and bitrate
        // For this example however I just want the url
        links.add(element['url']);
      });
    }

    // Finally return the links for the player
    return links.isNotEmpty
        ? links
        : [
            '<Holder Video>' // This video Url will be the url we will use if there is an error with the method. Because we don't want to break do we? :)
          ];
  }
}
