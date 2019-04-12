import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:solocoding2019_base/data/forecast.dart';
import 'package:solocoding2019_base/data/weather.dart';

const _API_KEY = "d32c3503faad347cb9de70223df148f6";
const _BASE_URL = "http://api.openweathermap.org/data/2.5";

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomeState();
}

class HomeState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // set material design app

    return MaterialApp(
      title: 'solocoding2019', // application name
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Weather App'), // app bar title
        ),
        body: FutureBuilder<WeatherResp>(
          future: _fetchWeather(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _weatherData(snapshot.data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Widget _weatherData(WeatherResp weatherResp) {
    print(weatherResp);
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
          Text(weatherResp.weather[0].description),
          SizedBox(height: 16),
          Text("Current Temp: ${weatherResp.main.temp}"),
          SizedBox(height: 16),
          Text("Min Temp: ${weatherResp.main.temp_min}"),
          SizedBox(height: 16),
          Text("Max Temp: ${weatherResp.main.temp_max}"),
          SizedBox(height: 16),
          Text("Humidity: ${weatherResp.main.humidity}"),
          SizedBox(height: 16),
          Text("Pressure: ${weatherResp.main.pressure}"),
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
}

Future<WeatherResp> _fetchWeather() async {
  final position = await getCurrentLocation();
  final lat = position.latitude;
  final lon = position.longitude;

  final response =
      await http.get("$_BASE_URL/weather?APPID=$_API_KEY&lat=$lat&lon=$lon");
  if (response.statusCode == 200) {
    return WeatherResp.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}

Future<ForecastResp> _fetchForecast(double lon, double lat) async {
  final response = await http
      .get("$_BASE_URL/forecast/daily?APPID=$_API_KEY&lat=$lat&lon=$lon&cnt=4");
  if (response.statusCode == 200) {
    return ForecastResp.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}

Future<Position> getCurrentLocation() async {
  Position position = await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  return position;
}
