import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const _apiKey = "b086bfcc97275e8e400f228912ff8be8";
  static const _baseUrl = "https://api.openweathermap.org/data/2.5/weather";

  Future<WeatherData?> fetchWeather(String city) async {
    final response = await http.get(
      Uri.parse("$_baseUrl?q=$city&appid=$_apiKey&units=metric"),
    );
    return response.statusCode == 200
        ? WeatherData.fromJson(jsonDecode(response.body))
        : null;
  }
}
