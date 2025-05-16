import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/now_playing.dart';

class ApiService {
  static const String apiUrl = 'https://radio.stellarfm.fr/api/nowplaying';

  static Future<NowPlaying?> fetchNowPlaying() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final station = data.firstWhere(
          (s) => s['station']['name'] == 'StellarFM',
          orElse: () => null,
        );

        if (station != null) {
          return NowPlaying.fromApiJson(station);
        }
      } else {
        print('API error ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur API: $e');
    }

    return null;
  }
}
