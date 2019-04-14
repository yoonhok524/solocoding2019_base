import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:solocoding2019_base/data/forecast.dart';
import 'package:solocoding2019_base/data/weather.dart';
import 'package:solocoding2019_base/utils/secrets.dart';
import 'package:solocoding2019_base/ui/map.dart';

const _BASE_URL = "http://api.openweathermap.org/data/2.5";

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<HomePage> {
  Position _position;
  bool _isManual = false;

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: getCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              _position = snapshot.data;
              return Scaffold(body: _body());
            } else {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }
          } else {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
        },
      );

  List<Widget> _optionMenus() => <Widget>[
        IconButton(
          icon: Icon(Icons.map),
          onPressed: () async {
            final result = await _showMapDialog(context, _position);
            if (result != null) {
              setState(() {
                print("[Weather] result: $result");
                _isManual = true;
                _position = result;
              });
            }
          },
        )
      ];

  Widget _body() {
    return FutureBuilder<WeatherResp>(
      future: _fetchWeather(_position),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return _weatherData(context, snapshot.data);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _weatherData(BuildContext context, WeatherResp weatherResp) {
    print("[Weather] $weatherResp");
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text(weatherResp.name),
          actions: _optionMenus(),
          expandedHeight: 200.0,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Image.network(
                "http://openweathermap.org/img/w/${weatherResp.weather[0].icon}.png"),
            centerTitle: true,
            title: Text(
                "${weatherResp.weather[0].main}, ${weatherResp.main.temp}℃"),
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate(buildWeather(weatherResp))),
      ],
    );
  }

  Widget _forecast(double lon, double lat) => FutureBuilder<ForecastResp>(
        future: _fetchForecast(lon, lat),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return _forecastData(snapshot.data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );

  Widget _forecastData(ForecastResp forecastResp) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            forecastResp.list.skip(1).map((i) => _buildForecast(i)).toList(),
      );

  Widget _buildForecast(Forecast forecast) => Expanded(
        child: Column(
          children: <Widget>[
            Image.network(
                "http://openweathermap.org/img/w/${forecast.weather.first.icon}.png"),
            Text(forecast.weather.first.main),
            Text(_getDate(forecast.dt))
          ],
        ),
      );

  Future<Position> _showMapDialog(BuildContext context, position) =>
      showDialog<Position>(
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

  Future<Position> getCurrentLocation() async {
    if (_isManual) {
      return _position;
    } else {
      return await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    }
  }

  List<Widget> buildWeather(WeatherResp weatherResp) {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(weatherResp.weather.first.description),
      ),
      SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Min Temp: ${weatherResp.main.temp_min}℃"),
      ),
      SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Max Temp: ${weatherResp.main.temp_max}℃"),
      ),
      SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Humidity: ${weatherResp.main.humidity}%"),
      ),
      SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Pressure: ${weatherResp.main.pressure}hPa"),
      ),
      SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Wind Speed: ${weatherResp.wind.speed}m/s"),
      ),
      SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Cloudiness: ${weatherResp.clouds.all}%"),
      ),
      SizedBox(height: 32),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Forecast", style: Theme.of(context).textTheme.headline),
      ),
      SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 320),
        child: _forecast(weatherResp.coord.lon, weatherResp.coord.lat),
      )
    ];
  }
}

String _getDate(int dateTime) {
  final dt = DateTime.fromMillisecondsSinceEpoch(dateTime * 1000);
  return "${dt.month}/${dt.day}";
}

Future<WeatherResp> _fetchWeather(Position position) async {
  final lat = position.latitude;
  final lon = position.longitude;
  final secret = await SecretLoader(secretPath: "secrets.json").load();

  final response = await http
      .get("$_BASE_URL/weather?APPID=${secret.apiKey}&lat=$lat&lon=$lon");
  if (response.statusCode == 200) {
    return WeatherResp.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}

Future<ForecastResp> _fetchForecast(double lon, double lat) async {
  final secret = await SecretLoader(secretPath: "secrets.json").load();
  final response = await http.get(
      "$_BASE_URL/forecast/daily?APPID=${secret.apiKey}&lat=$lat&lon=$lon&cnt=4");
  if (response.statusCode == 200) {
    return ForecastResp.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}
