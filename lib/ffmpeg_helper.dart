import 'package:path_provider/path_provider.dart';

abstract class FFMpegHelper {
  static Future<FFMpegResponse> mergeVideo({
    required String firstVideo,
    required String secondVideo,
  }) async {
    final outputPath = await getFilePath('mp4');
    const double frameTime = 0.0364;
    return FFMpegResponse(
      query:
          '''-t ${30 - frameTime} -i $firstVideo -ss $frameTime -i $secondVideo -filter_complex "[0:v] [0:a] [1:v] [1:a] concat=n=2:v=1:a=1 [v] [a]" -map "[v]" -map "[a]" $outputPath''',
      filePath: outputPath,
    );
  }

  static Future<FFMpegResponse> getFirstFrame({
    required String video,
  }) async {
    final outputPath = await getFilePath('jpeg');
    return FFMpegResponse(
      query: '''-i $video -vframes 1 $outputPath''',
      filePath: outputPath,
    );
  }

  static Future<FFMpegResponse> extractVideoToFrames({
    required String video,
  }) async {
    final outputPath = await getFilePath('');
    return FFMpegResponse(
      query: ''' -i $video  "${outputPath}frame_%03d.jpg"''',
      filePath: outputPath,
    );
  }

  static Future<String> getFilePath(
    String extension,
  ) async {
    final appDir = await getApplicationDocumentsDirectory();
    String rawDocumentPath = appDir.path;
    return '$rawDocumentPath/output';
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
