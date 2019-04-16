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
  PageController pageController;
  int currentPage = 0;

  @override
  initState() {
    super.initState();
    pageController = PageController(
      initialPage: currentPage,
      keepPage: false,
      viewportFraction: 0.8,
    );
  }

  @override
  dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: getCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              _position = snapshot.data;
              return Scaffold(
                appBar: AppBar(
                  title: Text("Flutter Weather App"),
                  actions: _optionMenus(),
                ),
                body: _body(),
              );
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
            return _weatherPages(snapshot.data);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _weatherPages(WeatherResp weatherResp) {
    return PageView(
      controller: pageController,
      children: <Widget>[
        _weatherPage(weatherResp),
        _weatherPage(weatherResp),
        _weatherPage(weatherResp),
      ],
    );
  }

  Widget _weatherPage(WeatherResp weatherResp) {
    print("[Weather] $weatherResp");
    return Center(
      child: SizedBox(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
              color: Colors.lightBlue, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    weatherResp.name,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              Image.network(
                  "http://openweathermap.org/img/w/${weatherResp.weather[0].icon}.png"),
              Text(
                "${weatherResp.weather[0].main}",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "${weatherResp.main.temp}℃",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text("Min Temp", style: TextStyle(color: Colors.white70)),
                      Text("${weatherResp.main.temp_min}℃",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text("Max Temp", style: TextStyle(color: Colors.white70)),
                      Text("${weatherResp.main.temp_max}℃",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Forecast",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _forecast(weatherResp.coord.lon, weatherResp.coord.lat),
              )
            ],
          ),
        ),
      ),
    );
  }

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
        children:
            forecastResp.list.skip(1).map((i) => _buildForecast(i)).toList(),
      );

  Widget _buildForecast(Forecast forecast) => Expanded(
        child: Column(
          children: <Widget>[
            Text(_getDate(forecast.dt), style: TextStyle(color: Colors.white)),
            Image.network(
                "http://openweathermap.org/img/w/${forecast.weather.first.icon}.png"),
            Text(forecast.weather.first.main, style: TextStyle(color: Colors.white)),
          ],
        ),
      );
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

String _getDate(int dateTime) {
  final dt = DateTime.fromMillisecondsSinceEpoch(dateTime * 1000);
  return "${dt.month}/${dt.day}";
}
