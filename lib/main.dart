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
          Image.network("http://openweathermap.org/img/w/${weatherResp.weather[0].icon}.png"),
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
