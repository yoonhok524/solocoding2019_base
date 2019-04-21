import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:solocoding2019_base/data/model/weather.dart';
import 'package:solocoding2019_base/ui/home.dart';
import 'package:solocoding2019_base/utils/secrets.dart';

Future<Null> getCurrentWeather() async {
  print("[Weather][Alarm] getCurrentWeather");
  var position = await getCurrentPosition();
  var weather = await _fetchWeather(position);
  print(
      "[Weather] Hello, world! ${weather.weather[0].main}");
}

Future<Position> getCurrentPosition() async {
  print("[Weather][Alarm] getCurrentPosition");
  final Position position = await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  return position;
}

Future<WeatherResp> _fetchWeather(Position position) async {
  print("[Weather][Alarm] _fetchWeather: $position");
  final lat = position.latitude;
  final lon = position.longitude;
  final secret = await SecretLoader(secretPath: "secrets.json").load();

  final response = await http
      .get("$BASE_URL/weather?APPID=${secret.apiKey}&lat=$lat&lon=$lon");
  if (response.statusCode == 200) {
    return WeatherResp.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}