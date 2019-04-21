import 'package:flutter/material.dart';
import 'package:solocoding2019_base/bloc/favoriteBloc.dart';
import 'package:solocoding2019_base/data/model/favorite.dart';
import 'package:solocoding2019_base/data/model/weather.dart';
import 'package:solocoding2019_base/data/source/favoriteLocalDao.dart';
import 'package:solocoding2019_base/ui/widgets/forecast.dart';

class WeatherWidget extends StatefulWidget {
  final WeatherResp weatherResp;

  WeatherWidget(this.weatherResp);

  @override
  State<StatefulWidget> createState() => _WeatherState();
}

class _WeatherState extends State<WeatherWidget> {
  FavoriteBloc bloc;
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final favoriteId = "${widget.weatherResp.coord.lat}-${widget.weatherResp.coord.lon}";
    bloc = FavoriteBloc(FavoriteLocalDataSource(), favoriteId);
    return Center(
      child: StreamBuilder<Favorite>(
        stream: bloc.get,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            case ConnectionState.active:
            case ConnectionState.done:
              return _weatherWidget(snapshot.data);
          }
        },
      ),
    );
  }

  Widget _weatherWidget(Favorite favorite) {
    isFavorite = (favorite == null) ? false : true;
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
                    widget.weatherResp.name,
                    style: TextStyle(color: Colors.white70),
                  ),
                  InkWell(
                    child: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? Colors.yellow : Colors.white,
                    ),
                    onTap: () {
                      setState(() {
                        if (isFavorite) {
                          bloc.delete.add(favorite);
                        } else {
                          bloc.save.add(Favorite(id: "${widget.weatherResp.coord.lat}-${widget.weatherResp.coord.lon}", lat: widget.weatherResp.coord.lat, lon: widget.weatherResp.coord.lon, name: widget.weatherResp.name));
                        }
                        isFavorite = !isFavorite;
                      });
                    },
                  )
                ],
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
    );
  }

}
