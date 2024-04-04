import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:merge_video/ffmpeg_helper.dart';
import 'package:merge_video/loading_status.dart';
import 'package:video_player/video_player.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late VideoPlayerController _controller;
  bool _isLoadvideo = false;
  LoadingStatus _loadingStatus = LoadingStatus.initialize;
  List<String> _videos = [];

  @override
  void initState() {
    super.initState();
  }

  void _loadVideo(String path) {
    _controller = VideoPlayerController.file(
      File(path),
    )..initialize().then((_) {
        setState(() {
          _isLoadvideo = true;
        });
      }).catchError((err) {
        print("videoplayer error $err");
      });
  }

  Future<void> _onCombineVideo() async {
    FFMpegResponse result = await FFMpegHelper.mergeVideo(
      firstVideo: _videos.first,
      secondVideo: _videos.last,
    );
    setState(() {
      _isLoadvideo = false;
      _loadingStatus = LoadingStatus.loading;
    });
    print("query ${result.query}");
    FFmpegKit.execute(
      result.query,
    ).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        // SUCCESS
        _loadVideo(result.filePath);
        print("success");
      } else if (ReturnCode.isCancel(returnCode)) {
        print("cancel");
        // CANCEL
      } else {
        session.getAllLogs().then((logs) {
          for (var element in logs) {
            print("errorffmpeg ${element.getMessage()}");
          }
        });
        print("error data ${session.getAllLogs()}");
        // ERROR
      }
      setState(() {
        _loadingStatus = LoadingStatus.loaded;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Player"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              FilePicker.platform
                  .pickFiles(
                type: FileType.video,
              )
                  .then((value) {
                if (value != null) {
                  setState(() {
                    _videos = [
                      ..._videos,
                      value.files.first.path!,
                    ];
                  });
                }
              });
            },
            child: const Text("Select Video"),
          ),
          SizedBox(
            height: 150,
            child: ListView.separated(
              itemBuilder: (context, index) {
                return ListTile(
                  trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        _videos.removeAt(index);
                      });
                    },
                    icon: const Icon(Icons.delete),
                  ),
                  title: Text(
                    _videos[index],
                    maxLines: 2,
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemCount: _videos.length,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _onCombineVideo();
            },
            child: const Text("Combine Videos"),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Center(
              child: _isLoadvideo
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : Center(
                      child: _loadingStatus.isLoading
                          ? const CircularProgressIndicator()
                          : const Text("No Video Loaded"),
                    ),
            ),
          ),
          const SizedBox(
            height: 50,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: const Icon(
          Icons.merge,
        ),
      ),
    );
  }
}
