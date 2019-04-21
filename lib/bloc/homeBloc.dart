import 'dart:convert';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:solocoding2019_base/ui/home.dart';
import 'package:solocoding2019_base/utils/fetchWeather.dart';
import 'package:solocoding2019_base/utils/secrets.dart';
import 'package:solocoding2019_base/data/model/weather.dart';
import 'package:solocoding2019_base/data/source/favoriteLocalDao.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc {
  final FavoriteLocalDao _favoriteDao;
  final _getSubject = PublishSubject<List<Position>>();
  final _updatePositionSubject = PublishSubject<Position>();

  bool isManual = false;
  Position position;

  HomeBloc(this._favoriteDao) {
    _get();
    _updatePositionSubject.listen(_updatePosition);
  }

  Stream<List<Position>> get get => _getSubject.stream;

  Sink<Position> get updatePosition => _updatePositionSubject.sink;

  Future<Null> _get() async {
    print("[Weather] WeatherBloc - get()");
    List<Position> positionList = List();

    var pos = await getCurrentLocation();
    positionList.add(pos);

    var favoriteList = await _favoriteDao.getAll();
    if (favoriteList != null && favoriteList.isNotEmpty) {
      print("[Weather] favoriteList size: ${favoriteList.length}");

      favoriteList.forEach((f) =>
          {positionList.add(Position(longitude: f.lon, latitude: f.lat))});
    }

    _getSubject.add(positionList);
  }

  void _updatePosition(Position position) {
    print("[Weather] _updatePosition: $position");
    this.position = position;
    _get();
  }

  Future<Position> getCurrentLocation() async {
    if (isManual) {
      if (position != null) {
        return position;
      } else {
        position = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        return position;
      }
    } else {
      position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return position;
    }
  }
}
