import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherService {

  // =========================================================
  // API KEY
  // =========================================================

  static const String apiKey =
      '087b7bfe5b05954ae658bc277265411a';

  // =========================================================
  // BASE URL
  // =========================================================

  static const String baseUrl =
      'https://api.openweathermap.org/data/2.5/forecast';

  // =========================================================
  // GET WEATHER
  // =========================================================

  Future<Map<String, dynamic>> getWeather(
    String city,
  ) async {

    final Uri url = Uri.parse(
      '$baseUrl?q=$city&appid=$apiKey&units=metric&lang=ua',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {

      return jsonDecode(response.body);

    } else {

      throw Exception(
        'Failed to load weather data',
      );
    }
  }
}