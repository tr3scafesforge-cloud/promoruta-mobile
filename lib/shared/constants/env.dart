import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get mapboxAccessToken {
    final fromDotenv = dotenv.env['MAPBOX_ACCESS_TOKEN'];
    if (fromDotenv != null && fromDotenv.isNotEmpty) {
      return fromDotenv;
    }
    return const String.fromEnvironment(
      'MAPBOX_ACCESS_TOKEN',
      defaultValue: '',
    );
  }
}
