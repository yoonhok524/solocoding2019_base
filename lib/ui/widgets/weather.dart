import 'package:flutter/material.dart';
import 'package:solocoding2019_base/data/model/weather.dart';
import 'package:solocoding2019_base/ui/widgets/forecast.dart';

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
                color: Colors.lightBlue,
                borderRadius: BorderRadius.circular(24)),
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
                        Text("Min Temp",
                            style: TextStyle(color: Colors.white70)),
                        Text("${widget.weatherResp.main.temp_min}℃",
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text("Max Temp",
                            style: TextStyle(color: Colors.white70)),
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
                  child: ForecastWidget(widget.weatherResp.coord.lon,
                      widget.weatherResp.coord.lat),
                )
              ],
            ),
          ),
        ),
      );
}
