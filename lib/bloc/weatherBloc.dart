import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:solocoding2019_base/data/model/recent.dart';
import 'package:solocoding2019_base/data/source/recentLocalDao.dart';
import 'package:solocoding2019_base/ui/home.dart';
import 'package:solocoding2019_base/utils/secrets.dart';
import 'package:solocoding2019_base/data/model/weather.dart';
import 'package:solocoding2019_base/data/source/favoriteLocalDao.dart';
import 'package:rxdart/rxdart.dart';

class WeatherBloc {
  final RecentLocalDao _recentSearchDao = RecentLocalDao();
  final Position position;

  WeatherBloc(this.position) {
    _get();
  }

  final _getSubject = PublishSubject<WeatherResp>();

  Stream<WeatherResp> get get => _getSubject.stream;

  Future<Null> _get() async {
    var weather = await _fetchWeather(position);
    print("[Weather] WeatherBloc - main: $weather");
    _getSubject.add(weather);
  }

  Future<WeatherResp> _fetchWeather(Position position) async {
    print("[Weather] _fetchWeather - $position");
    final lat = position.latitude;
    final lon = position.longitude;
    final secret = await SecretLoader(secretPath: "secrets.json").load();

    final response = await http
        .get("$BASE_URL/weather?APPID=${secret.apiKey}&lat=$lat&lon=$lon");
    if (response.statusCode == 200) {
      final weather = WeatherResp.fromJson(json.decode(response.body));
      _recentSearchDao.save(Recent(id: "${lon}_$lat", name: weather.name, time: DateTime.now().millisecondsSinceEpoch, lon: lon, lat: lat));
      return weather;
    } else {
      throw Exception('Failed to load post');
    }
  }
}
