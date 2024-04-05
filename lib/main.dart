import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:merge_video/app_const.dart';
import 'package:merge_video/ffmpeg_helper.dart';
import 'package:merge_video/loading_status.dart';
import 'package:merge_video/video_extracting.dart';
import 'package:merge_video/view_image.dart';
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
      }).catchError((_) {});
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
    FFmpegKit.execute(
      result.query,
    ).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        // SUCCESS
        _loadVideo(result.filePath);
        log("success");
      } else if (ReturnCode.isCancel(returnCode)) {
        log("cancel");
        // CANCEL
      } else {
        log("error data ${session.getAllLogs()}");
        // ERROR
      }
      setState(() {
        _loadingStatus = LoadingStatus.loaded;
      });
    });
  }

  Future<void> _getFirstFrame() async {
    FFMpegResponse result = await FFMpegHelper.getFirstFrame(
      video: _videos.first,
    );
    FFmpegKit.execute(
      result.query,
    ).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        // SUCCESS
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ViewImage(
              imageUrl: result.filePath,
            ),
          ),
        );
      } else if (ReturnCode.isCancel(returnCode)) {
        log("cancel");
        // CANCEL
      } else {
        log("error data ${session.getAllLogs()}");
        // ERROR
      }
      setState(() {
        _loadingStatus = LoadingStatus.loaded;
      });
    });
  }

  Future<void> _extractFrame() async {
    FFMpegResponse result = await FFMpegHelper.extractVideoToFrames(
      video: _videos.first,
    );
    FFmpegKit.execute(
      result.query,
    ).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        // SUCCESS
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ViewImage(
              imageUrl: '${result.filePath}frame_001.png',
            ),
          ),
        );
      } else if (ReturnCode.isCancel(returnCode)) {
        log("cancel");
        // CANCEL
      } else {
        log("error data ${session.getAllLogs()}");
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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const VideoExtracting(),
                ),
              );
            },
            icon: const Icon(Icons.image),
          ),
        ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _onCombineVideo();
                },
                child: const Text("Combine Videos"),
              ),
              ElevatedButton(
                onPressed: () {
                  _extractFrame();
                },
                child: const Text("First Frame"),
              ),
            ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _controller.seekTo(
                      _controller.value.position - AppConstants.timeDuration,
                    );
                  });
                },
                icon: const Icon(
                  Icons.replay_10,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _controller.seekTo(
                      _controller.value.position + AppConstants.timeDuration,
                    );
                  });
                },
                icon: const Icon(
                  Icons.forward_10,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 50,
          )
        ],
      ),
      floatingActionButton: _isLoadvideo
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}
