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
    print(weatherResp);
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
          SizedBox(height: 16,),
          Text("Current location (lat, lng): ${weatherResp.name}"),
          SizedBox(height: 8,),
          Text("${weatherResp.coord.lat}, ${weatherResp.coord.lon}")
        ],
      ),
    );
  }
}

Future<WeatherResp> fetchWeather() async {
  final position = await getCurrentLocation();
  final lat = position.latitude;
  final lon = position.longitude;

  final response = await http.get("http://api.openweathermap.org/data/2.5/weather?APPID=d32c3503faad347cb9de70223df148f6&lat=$lat&lon=$lon");
  if (response.statusCode == 200) {
    return WeatherResp.fromJson(json.decode(response.body));
  } else {
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
  var dt;
  final Sys sys;
  var id;
  final String name;
  var cod;

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

  @override
  String toString() => 'WeatherResp: {coord: $coord, weather: [$weather], base: $base, main: $main, wind: $wind, clouds: $clouds, dt: $dt, sys: $sys, id: $id, name: $name, cod: $cod}';


}

class Coord {
  var lon;
  var lat;

  Coord({this.lat, this.lon});

  factory Coord.fromJson(Map<String, dynamic> json) =>
      Coord(
        lon: json['lon'],
        lat: json['lat'],
      );

  @override
  String toString() => '{lon: $lon, lat: $lat}';
}

class Weather {
  var id;
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

  @override
  String toString() => '{id: $id, main: $main, description: $description, icon: $icon}';
}

class Main {
  var temp;
  var pressure;
  var humidity;
  var temp_min;
  var temp_max;

  Main({this.temp, this.pressure, this.humidity, this.temp_min, this.temp_max});

  factory Main.fromJson(Map<String, dynamic> json) =>
      Main(
        temp: json['temp'],
        pressure: json['pressure'],
        humidity: json['humidity'],
        temp_min: json['temp_min'],
        temp_max: json['temp_max'],
      );

  @override
  String toString() => '{temp: $temp, pressure: $pressure, humidity: $humidity, temp_min: $temp_min, temp_max: $temp_max}';
}

class Wind {
  var speed;
  var deg;

  Wind({this.speed, this.deg});

  factory Wind.fromJson(Map<String, dynamic> json) =>
      Wind(
        speed: json['speed'],
        deg: json['deg'],
      );

  @override
  String toString() => '{speed: $speed, deg: $deg}';
}

class Clouds {
  var all;

  Clouds({this.all});

  factory Clouds.fromJson(Map<String, dynamic> json) =>
      Clouds(
          all: json['all'],
      );

  @override
  String toString() => '{all: $all}';
}

class Sys {
  var type;
  var id;
  var message;
  String country;
  var sunrise;
  var sunset;

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

  @override
  String toString() => 'Sys: {type: $type, id: $id, message: $message, country: $country, sunrise: $sunrise, sunset: $sunset}';
}
