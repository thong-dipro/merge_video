import 'package:path_provider/path_provider.dart';

abstract class FFMpegHelper {
  static Future<FFMpegResponse> mergeVideo({
    required String firstVideo,
    required String secondVideo,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    String rawDocumentPath = appDir.path;
    final outputPath =
        '$rawDocumentPath/output3${DateTime.now().millisecondsSinceEpoch}.mp4';
    return FFMpegResponse(
      query:
          '-i $firstVideo -i $secondVideo -filter_complex "[0:v] [0:a] [1:v] [1:a] concat=n=2:v=1:a=1 [v] [a]" -map "[v]" -map "[a]" $outputPath',
      filePath: outputPath,
    );
  }
}

class FFMpegResponse {
  final String query;
  final String filePath;

  FFMpegResponse({
    required this.query,
    required this.filePath,
  });
}
