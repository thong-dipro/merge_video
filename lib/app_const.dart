abstract class AppConstants {
  static const double _fps = 27.5;
  static Duration timeDuration = Duration(
    microseconds: (1 / _fps * 1000000).toInt(),
  );
}
