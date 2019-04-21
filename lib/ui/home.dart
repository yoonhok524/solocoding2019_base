import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:solocoding2019_base/bloc/recentSearchesBloc.dart';
import 'package:solocoding2019_base/bloc/homeBloc.dart';
import 'package:solocoding2019_base/data/model/recent.dart';
import 'package:solocoding2019_base/data/source/favoriteLocalDao.dart';
import 'package:solocoding2019_base/data/source/recentLocalDao.dart';
import 'package:solocoding2019_base/ui/widgets/mainWeather.dart';
import 'package:solocoding2019_base/ui/widgets/favoriteWeather.dart';
import 'package:solocoding2019_base/ui/map.dart';

const BASE_URL = "http://api.openweathermap.org/data/2.5";

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<HomePage> {
  final RecentSearchesBloc recentBloc = RecentSearchesBloc(RecentLocalDao());
  final HomeBloc homeBloc = HomeBloc(FavoriteLocalDao());

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
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text("Flutter Weather App"),
        actions: _optionMenus(),
      ),
      body: _body(),
    );

  List<Widget> _optionMenus() => <Widget>[
        IconButton(
          icon: Icon(Icons.map),
          onPressed: () async {
            final result = await _showMapDialog(context, homeBloc.position);
            if (result != null) {
              setState(() {
                print("[Weather] _showMapDialog - result: $result");
                homeBloc.isManual = true;
                homeBloc.updatePosition.add(result);
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
                homeBloc.isManual = true;
                homeBloc.updatePosition.add(Position(latitude: result.lat, longitude: result.lon));
              });
            }
            print("[Weather] recentSearch - result: $result");
          },
        ),
      ];

  Widget _body() {
    print("[Weather] home - body");
    return Center(
      child: StreamBuilder<List<Position>>(
        stream: homeBloc.get,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            case ConnectionState.active:
            case ConnectionState.done:
              return _weatherPages(snapshot.data);
          }
        },
      ),
    );
  }

  Widget _weatherPages(List<Position> positionList) {
    print("[Weather] _weatherPages - positionList.size: ${positionList.length}");
    List<Widget> weatherList = List();
    weatherList.add(MainWeatherWidget(positionList[0]));
    weatherList.addAll(positionList.skip(1).map((p) => FavoriteWeatherWidget(p)).toList());

    print("[Weather] _weatherPages - size: ${weatherList.length}");
    return PageView(
      controller: pageController,
      children: weatherList,
    );
  }

  Future<Position> _showMapDialog(BuildContext context, position) =>
      showDialog<Position>(
        context: context,
        barrierDismissible: false, // user must tap button for close dialog!
        builder: (BuildContext context) {
          MapWidget mapWidget = MapWidget(position);
          return AlertDialog(
            title: Text('Select Location'),
            content: mapWidget,
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
                  Navigator.of(context).pop(mapWidget.position);
                },
              )
            ],
          );
        },
      );
}
