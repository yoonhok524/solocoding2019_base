import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:solocoding2019_base/data/model/forecast.dart';
import 'package:solocoding2019_base/ui/home.dart';
import 'package:solocoding2019_base/utils/secrets.dart';

class ForecastWidget extends StatefulWidget {
  final double lon;
  final double lat;

  ForecastWidget(this.lon, this.lat);

  @override
  State<StatefulWidget> createState() => _ForecastState();
}

class _ForecastState extends State<ForecastWidget> {
  @override
  Widget build(BuildContext context) => FutureBuilder<ForecastResp>(
      future: _fetchForecast(widget.lon, widget.lat),
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

  Future<ForecastResp> _fetchForecast(double lon, double lat) async {
    final secret = await SecretLoader(secretPath: "secrets.json").load();
    final response = await http.get(
        "$BASE_URL/forecast/daily?APPID=${secret.apiKey}&lat=$lat&lon=$lon&cnt=4");
    if (response.statusCode == 200) {
      return ForecastResp.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load post');
    }
  }

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
            Text(forecast.weather.first.main,
                style: TextStyle(color: Colors.white)),
          ],
        ),
      );
}

String _getDate(int dateTime) {
  final dt = DateTime.fromMillisecondsSinceEpoch(dateTime * 1000);
  return "${dt.month}/${dt.day}";
}
