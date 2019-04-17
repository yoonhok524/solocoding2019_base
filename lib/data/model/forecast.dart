import 'package:solocoding2019_base/data/model/weather.dart';

class ForecastResp {
  final City city;
  final String cod;
  var message;
  var cnt;
  final List<Forecast> list;

  ForecastResp({this.cod, this.message, this.cnt, this.city, this.list});

  factory ForecastResp.fromJson(Map<String, dynamic> json) {
    final list = json['list'] as List;
    final forecastList = list.map((i) => Forecast.fromJson(i)).toList();

    return ForecastResp(
      cod: json['cod'],
      message: json['message'],
      cnt: json['cnt'],
      city: City.fromJson(json['city']),
      list: forecastList,
    );
  }

  @override
  String toString() =>
      '{cod: $cod, message: $message, cnt: $cnt, city: $city, list: $list}';
}

class City {
  var id;
  final String name;
  final Coord coord;
  final String country;
  final int population;

  City({this.id, this.name, this.coord, this.country, this.population});

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json['id'],
        name: json['name'],
        coord: Coord.fromJson(json['coord']),
        country: json['country'],
        population: json['population'],
      );

  @override
  String toString() =>
      '{id: $id, name: $name, coord: $coord, country: $country}';
}

class Forecast {
  final int dt;
  var pressure;
  var humidity;
  var speed;
  var deg;
  var clouds;
  final Temp temp;
  final List<Weather> weather;

  Forecast(
      {this.dt,
      this.pressure,
      this.humidity,
      this.speed,
      this.deg,
      this.clouds,
      this.temp,
      this.weather});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    final list = json['weather'] as List;
    final weatherList = list.map((i) => Weather.fromJson(i)).toList();

    return Forecast(
      dt: json['dt'],
      pressure: json['pressure'],
      humidity: json['humidity'],
      speed: json['speed'],
      deg: json['deg'],
      clouds: json['clouds'],
      temp: Temp.fromJson(json['temp']),
      weather: weatherList,
    );
  }

  @override
  String toString() =>
      '{dt: $dt, pressure: $pressure, humidity: $humidity, speed: $speed, deg: $deg, clouds: $clouds, temp: $temp, weather: $weather}';
}

class Temp {
  var day;
  var min;
  var max;
  var night;
  var eve;
  var morn;

  Temp({this.day, this.min, this.max, this.night, this.eve, this.morn});

  factory Temp.fromJson(Map<String, dynamic> json) => Temp(
        day: json['day'],
        min: json['min'],
        max: json['max'],
        night: json['night'],
        eve: json['eve'],
        morn: json['morn'],
      );

  @override
  String toString() =>
      '{day: $day, min: $min, max: $max, night: $night, eve: $eve, morn: $morn}';
}

class Main {
  var temp;
  var temp_min;
  var temp_max;
  var pressure;
  var sea_level;
  var grnd_level;
  var humidity;
  var temp_kf;

  Main(
      {this.temp,
      this.temp_min,
      this.temp_max,
      this.pressure,
      this.sea_level,
      this.grnd_level,
      this.humidity,
      this.temp_kf});

  factory Main.fromJson(Map<String, dynamic> json) => Main(
        temp: json['temp'],
        temp_min: json['temp_min'],
        temp_max: json['temp_max'],
        pressure: json['pressure'],
        sea_level: json['sea_level'],
        grnd_level: json['grnd_level'],
        humidity: json['humidity'],
        temp_kf: json['temp_kf'],
      );

  @override
  String toString() =>
      '{temp: $temp, temp_min: $temp_min, temp_max: $temp_max, pressure: $pressure, sea_level: $sea_level, grnd_level: $grnd_level, humidity: $humidity, temp_kf: $temp_kf';
}

//{
//    "sys": {
//        "pod": "n"
//    },
//},
