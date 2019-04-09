import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

// This widget is the root of your application.
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MyAppState();
}

const API_KEY = "d32c3503faad347cb9de70223df148f6";
const BASE_URL = "http://api.openweathermap.org/data/2.5/weather?APPID=d32c3503faad347cb9de70223df148f6&lat=35&lon=139";

class MyAppState extends State<MyApp> {
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
          future: fetchWeather(),
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
    return Center(
      child: Column(
        children: <Widget>[
          SizedBox(height: 32,),
          Text(weatherResp.weather[0].main, style: Theme
              .of(context)
              .textTheme
              .headline,),
          SizedBox(height: 32,),
          Text(weatherResp.weather[0].description),
          SizedBox(height: 16,),
          Text("Current Temp: ${weatherResp.main.temp}"),
          SizedBox(height: 16,),
          Text("Min Temp: ${weatherResp.main.temp_min}"),
          SizedBox(height: 16,),
          Text("Max Temp: ${weatherResp.main.temp_max}"),
          SizedBox(height: 16,),
          Text("Humidity: ${weatherResp.main.humidity}"),
          SizedBox(height: 16,),
          Text("Pressure: ${weatherResp.main.pressure}"),
        ],
      ),
    );
  }
}

Future<WeatherResp> fetchWeather() async {
  final position = await getCurrentLocation();
  final lat = position.latitude;
  final lon = position.longitude;

  print("lat: $lat");
  print("lon: $lon");
  final response = await http.get("http://api.openweathermap.org/data/2.5/weather?APPID=d32c3503faad347cb9de70223df148f6&lat=$lat&lon=$lon");

  if (response.statusCode == 200) {
    // 만약 서버로의 요청이 성공하면, JSON을 파싱합니다.
    return WeatherResp.fromJson(json.decode(response.body));
  } else {
    // 만약 요청이 실패하면, 에러를 던집니다.
    throw Exception('Failed to load post');
  }
}

Future<Position> getCurrentLocation() async {
  Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  return position;
}

class WeatherResp {
  final Coord coord;
  final List<Weather> weather;
  final String base;
  final Main main;
  final Wind wind;
  final Clouds clouds;
  final int dt;
  final Sys sys;
  final int id;
  final String name;
  final int cod;

  WeatherResp({this.coord,
    this.weather,
    this.base,
    this.main,
    this.wind,
    this.clouds,
    this.dt,
    this.sys,
    this.id,
    this.name,
    this.cod});

  factory WeatherResp.fromJson(Map<String, dynamic> json) {
    var list = json['weather'] as List;
    final weatherList = list.map((i) => Weather.fromJson(i)).toList();

    return WeatherResp(
        coord: Coord.fromJson(json['coord']),
        weather: weatherList,
        base: json['base'],
        main: Main.fromJson(json['main']),
        wind: Wind.fromJson(json['wind']),
        clouds: Clouds.fromJson(json['clouds']),
        dt: json['dt'],
        sys: Sys.fromJson(json['sys']),
        id: json['id'],
        name: json['name'],
        cod: json['cod']);
  }
}

class Coord {
  int lon;
  int lat;

  Coord({this.lat, this.lon});

  factory Coord.fromJson(Map<String, dynamic> json) =>
      Coord(
        lon: json['lon'],
        lat: json['lat'],
      );
}

class Weather {
  int id;
  String main;
  String description;
  String icon;

  Weather({this.id, this.main, this.description, this.icon});

  factory Weather.fromJson(Map<String, dynamic> json) =>
      Weather(
        id: json['id'],
        main: json['main'],
        description: json['description'],
        icon: json['icon'],
      );
}

class Main {
  double temp;
  int pressure;
  int humidity;
  double temp_min;
  double temp_max;

  Main({this.temp, this.pressure, this.humidity, this.temp_min, this.temp_max});

  factory Main.fromJson(Map<String, dynamic> json) =>
      Main(
        temp: json['temp'],
        pressure: json['pressure'],
        humidity: json['humidity'],
        temp_min: json['temp_min'],
        temp_max: json['temp_max'],
      );
}

class Wind {
  double speed;
  double deg;

  Wind({this.speed, this.deg});

  factory Wind.fromJson(Map<String, dynamic> json) =>
      Wind(
        speed: json['speed'],
        deg: json['deg'],
      );
}

class Clouds {
  int all;

  Clouds({this.all});

  factory Clouds.fromJson(Map<String, dynamic> json) =>
      Clouds(
          all: json['all'];
      );
}

class Sys {
  int type;
  int id;
  double message;
  String country;
  int sunrise;
  int sunset;

  Sys({this.type,
    this.id,
    this.message,
    this.country,
    this.sunrise,
    this.sunset});

  factory Sys.fromJson(Map<String, dynamic> json) =>
      Sys(
        type: json['type'],
        id: json['id'],
        message: json['message'],
        country: json['country'],
        sunrise: json['sunrise'],
        sunset: json['sunset'],
      );
}
