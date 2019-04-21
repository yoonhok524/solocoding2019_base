import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:solocoding2019_base/data/model/forecast.dart';
import 'package:solocoding2019_base/data/model/weather.dart';
import 'package:solocoding2019_base/ui/home.dart';
import 'package:solocoding2019_base/utils/secrets.dart';

class WeatherWidget extends StatefulWidget {

  final WeatherResp weatherResp;

  WeatherWidget(this.weatherResp);

  @override
  State<StatefulWidget> createState() => _WeatherState();

}

class _WeatherState extends State<WeatherWidget> {
  @override
  Widget build(BuildContext context) => Center(
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
                    widget.weatherResp.name,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              Image.network(
                  "http://openweathermap.org/img/w/${widget.weatherResp.weather[0].icon}.png"),
              Text(
                "${widget.weatherResp.weather[0].main}",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "${widget.weatherResp.main.temp}℃",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text("Min Temp", style: TextStyle(color: Colors.white70)),
                      Text("${widget.weatherResp.main.temp_min}℃",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text("Max Temp", style: TextStyle(color: Colors.white70)),
                      Text("${widget.weatherResp.main.temp_max}℃",
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
                child: _forecast(widget.weatherResp.coord.lon, widget.weatherResp.coord.lat),
              )
            ],
          ),
        ),
      ),
    );

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
