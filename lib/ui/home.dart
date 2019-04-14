import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:solocoding2019_base/data/forecast.dart';
import 'package:solocoding2019_base/data/weather.dart';
import 'package:solocoding2019_base/secrets.dart';
import 'package:solocoding2019_base/ui/map.dart';

const _BASE_URL = "http://api.openweathermap.org/data/2.5";

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<HomePage> {
  Position position;
  bool isManual = false;

  @override
  Widget build(BuildContext context) {
    print("[Weather] build");
    return FutureBuilder(
      future: getCurrentLocation(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          position = snapshot.data;

          return Scaffold(
            appBar: AppBar(
              title: Text('Flutter Weather App'), // app bar title
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.map),
                  onPressed: () async {
                    final result = await _showMapDialog(context, snapshot.data);
                    if (result != null) {
                      setState(() {
                        print("[Weather] result: $result");
                        isManual = true;
                        position = result;
                      });
                    }
                  },
                )
              ],
            ),
            body: FutureBuilder<WeatherResp>(
              future: _fetchWeather(position),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print("[Weather] weather data build");
                  return _weatherData(context, snapshot.data);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return CircularProgressIndicator();
              },
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _weatherData(BuildContext context, WeatherResp weatherResp) {
    print("[Weather] $weatherResp");
    return Center(
      child: Column(
        children: <Widget>[
          SizedBox(height: 32),
          Image.network(
              "http://openweathermap.org/img/w/${weatherResp.weather[0].icon}.png"),
          SizedBox(height: 32),
          Text(
            weatherResp.weather[0].main,
            style: Theme.of(context).textTheme.headline,
          ),
          SizedBox(height: 32),
          Text("Current Temp: ${weatherResp.main.temp}℃"),
          SizedBox(height: 16),
          Text("Min Temp: ${weatherResp.main.temp_min}℃"),
          SizedBox(height: 16),
          Text("Max Temp: ${weatherResp.main.temp_max}℃"),
          SizedBox(height: 16),
          Text("Humidity: ${weatherResp.main.humidity}%"),
          SizedBox(height: 16),
          Text("Pressure: ${weatherResp.main.pressure}hPa"),
          SizedBox(height: 16),
          Text("Current location (lat, lng): ${weatherResp.name}"),
          SizedBox(height: 8),
          Text("${weatherResp.coord.lat}, ${weatherResp.coord.lon}"),
          SizedBox(height: 16),
          _forecast(weatherResp.coord.lon, weatherResp.coord.lat),
        ],
      ),
    );
  }

  _forecast(double lon, double lat) {
    return FutureBuilder<ForecastResp>(
      future: _fetchForecast(lon, lat),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _forecastData(snapshot.data);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        return CircularProgressIndicator();
      },
    );
  }

  _forecastData(ForecastResp forecastResp) {
    print("[Weather] _forecastData");
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          forecastResp.list.skip(1).map((i) => _buildForecast(i)).toList(),
    );
  }

  Widget _buildForecast(Forecast forecast) {
    final dt = DateTime.fromMillisecondsSinceEpoch(forecast.dt * 1000);
    final date = "${dt.month}/${dt.day}";
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        children: <Widget>[
          Image.network(
              "http://openweathermap.org/img/w/${forecast.weather.first.icon}.png"),
          Text(forecast.weather.first.main),
          Text(date)
        ],
      ),
    );
  }

  Future<Position> _showMapDialog(BuildContext context, position) {
    return showDialog<Position>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        MapView mapView = MapView(position);
        return AlertDialog(
          title: Text('Select Location'),
          content: mapView,
          actions: <Widget>[
            FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            RaisedButton(
              child: const Text(
                'SELECT',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop(mapView.position);
              },
            )
          ],
        );
      },
    );
  }

  Future<Position> getCurrentLocation() async {
    if (isManual) {
      return position;
    } else {
      return await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    }
  }
}

Future<WeatherResp> _fetchWeather(Position position) async {
  final lat = position.latitude;
  final lon = position.longitude;
  final secret = await SecretLoader(secretPath: "secrets.json").load();


  final response =
      await http.get("$_BASE_URL/weather?APPID=${secret.apiKey}&lat=$lat&lon=$lon");
  if (response.statusCode == 200) {
    return WeatherResp.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}

Future<ForecastResp> _fetchForecast(double lon, double lat) async {
  final secret = await SecretLoader(secretPath: "secrets.json").load();
  final response = await http
      .get("$_BASE_URL/forecast/daily?APPID=${secret.apiKey}&lat=$lat&lon=$lon&cnt=4");
  if (response.statusCode == 200) {
    return ForecastResp.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}