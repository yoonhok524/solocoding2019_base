import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:solocoding2019_base/bloc/recentSearchesBloc.dart';
import 'package:solocoding2019_base/data/model/recent.dart';
import 'package:solocoding2019_base/data/model/weather.dart';
import 'package:solocoding2019_base/data/source/recentLocalDao.dart';
import 'package:solocoding2019_base/ui/widgets/weather.dart';
import 'package:solocoding2019_base/utils/secrets.dart';
import 'package:solocoding2019_base/ui/map.dart';

const BASE_URL = "http://api.openweathermap.org/data/2.5";

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<HomePage> {
  final RecentSearchesBloc bloc = RecentSearchesBloc(RecentLocalDataSource());

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
        ),
        IconButton(
          icon: Icon(Icons.history),
          onPressed: () async {
            final result = await Navigator.pushNamed(context, '/recentSearches');
            if (result is Recent) {
              setState(() {
                _isManual = true;
                _position = Position(latitude: result.lat, longitude: result.lon);
              });
            }
            print("[Weather] result: $result");
          },
        ),
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
    if (_isManual) {
      bloc.save.add(Recent(id: "${_position.longitude}_${_position.latitude}", name: weatherResp.name, time: DateTime.now().millisecondsSinceEpoch, lon: _position.longitude, lat: _position.latitude));
    }

    return PageView(
      controller: pageController,
      children: <Widget>[
        WeatherWidget(weatherResp),
        WeatherWidget(weatherResp),
        WeatherWidget(weatherResp),
      ],
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

}

Future<WeatherResp> _fetchWeather(Position position) async {
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
