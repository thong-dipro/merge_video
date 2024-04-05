import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_frame_extractor/video_frame_extractor.dart';

class VideoExtracting extends StatefulWidget {
  const VideoExtracting({super.key});

  @override
  State<VideoExtracting> createState() => _VideoExtractingState();
}

class _VideoExtractingState extends State<VideoExtracting> {
  List<String> frames = [];
  bool isLoading = false;
  Future<void> _extractVideoToFrames(String videoUrl) async {
    final result = await VideoFrameExtractor.fromNetwork(
      videoUrl: videoUrl,
      imagesCount: 27,
      destinationDirectoryPath: '/storage/emulated/0/Download',
      onProgress: (progress) {},
    );
    setState(() {
      frames = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Video Extracting'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  FilePicker.platform
                      .pickFiles(
                    type: FileType.video,
                  )
                      .then((value) {
                    if (value != null && value.files.isNotEmpty) {
                      _extractVideoToFrames(value.files.first.path ?? '');
                    }
                  });
                },
                child: const Text('Extract Video to Frames'),
              ),
              if (isLoading)
                const CupertinoActivityIndicator()
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: frames.length,
                    itemBuilder: (context, index) {
                      return Image.file(
                        File(frames[index]),
                      );
                    },
                  ),
                ),
            ],
          ),
        ));
  }
}
