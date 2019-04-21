import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:solocoding2019_base/bloc/favoriteBloc.dart';
import 'package:solocoding2019_base/bloc/weatherBloc.dart';
import 'package:solocoding2019_base/data/model/favorite.dart';
import 'package:solocoding2019_base/data/model/weather.dart';
import 'package:solocoding2019_base/data/source/favoriteLocalDao.dart';
import 'package:solocoding2019_base/ui/widgets/forecast.dart';

class MainWeatherWidget extends StatelessWidget {

  final Position position;

  FavoriteBloc favoriteBloc;
  WeatherBloc weatherBloc;

  MainWeatherWidget(this.position);

  @override
  Widget build(BuildContext context) {
    favoriteBloc = FavoriteBloc(FavoriteLocalDao(), "");
    weatherBloc = WeatherBloc(position);
    return Center(
      child: StreamBuilder<WeatherResp>(
        stream: weatherBloc.get,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            case ConnectionState.active:
            case ConnectionState.done:
              return _weatherWidget(context, snapshot.data);
          }
        },
      ),
    );
  }

  Widget _weatherWidget(BuildContext context, WeatherResp weatherResp) {
    return SizedBox(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    weatherResp.name,
                    style: TextStyle(color: Colors.white70),
                  ),
                  InkWell(
                    child: Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                    ),
                    onTap: () {
                      favoriteBloc.save.add(Favorite(id: "${weatherResp.coord.lat}-${weatherResp.coord.lon}", lat: weatherResp.coord.lat, lon: weatherResp.coord.lon, name: weatherResp.name));
                    },
                  )
                ],
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
                    Text("Min Temp",
                        style: TextStyle(color: Colors.white70)),
                    Text("${weatherResp.main.temp_min}℃",
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text("Max Temp",
                        style: TextStyle(color: Colors.white70)),
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
              child: ForecastWidget(weatherResp.coord.lon,
                  weatherResp.coord.lat),
            )
          ],
        ),
      ),
    );
  }
}
