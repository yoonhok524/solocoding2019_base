import 'package:dson/dson.dart';

class WeatherResp {
  final Coord coord;
  final List<Weather> weather;
  final String base;
  final Main main;
  final Wind wind;
  final Clouds clouds;
  var dt;
  final Sys sys;
  var id;
  final String name;
  var cod;

  WeatherResp({this.coord,
    this.weather,
    this.base,
    this.main,
    this.wind,
    this.clouds,
    this.dt,
    this.sys,
    this.id,
    this.name,
    this.cod});

  factory WeatherResp.fromJson(Map<String, dynamic> json) {
    var list = json['weather'] as List;
    final weatherList = list.map((i) => Weather.fromJson(i)).toList();

    return WeatherResp(
        coord: Coord.fromJson(json['coord']),
        weather: weatherList,
        base: json['base'],
        main: Main.fromJson(json['main']),
        wind: Wind.fromJson(json['wind']),
        clouds: Clouds.fromJson(json['clouds']),
        dt: json['dt'],
        sys: Sys.fromJson(json['sys']),
        id: json['id'],
        name: json['name'],
        cod: json['cod']);
  }

  @override
  String toString() => 'WeatherResp: {coord: $coord, weather: [$weather], base: $base, main: $main, wind: $wind, clouds: $clouds, dt: $dt, sys: $sys, id: $id, name: $name, cod: $cod}';


}

class Coord {
  final double lon;
  final double lat;

  Coord({this.lat, this.lon});

  factory Coord.fromJson(Map<String, dynamic> json) =>
      Coord(
        lon: json['lon'],
        lat: json['lat'],
      );

  @override
  String toString() => '{lon: $lon, lat: $lat}';
}

class Weather {
  var id;
  String main;
  String description;
  String icon;

  Weather({this.id, this.main, this.description, this.icon});

  factory Weather.fromJson(Map<String, dynamic> json) =>
      Weather(
        id: json['id'],
        main: json['main'],
        description: json['description'],
        icon: json['icon'],
      );

  @override
  String toString() => '{id: $id, main: $main, description: $description, icon: $icon}';
}

class Main {
  var temp;
  var pressure;
  var humidity;
  var temp_min;
  var temp_max;

  Main({this.temp, this.pressure, this.humidity, this.temp_min, this.temp_max});

  factory Main.fromJson(Map<String, dynamic> json) =>
      Main(
        temp: (json['temp'] - 273.15).toStringAsFixed(1),
        pressure: json['pressure'],
        humidity: json['humidity'],
        temp_min: json['temp_min'] - 273.15,
        temp_max: json['temp_max'] - 273.15,
      );

  @override
  String toString() => '{temp: $temp, pressure: $pressure, humidity: $humidity, temp_min: $temp_min, temp_max: $temp_max}';
}

class Wind {
  var speed;
  var deg;

  Wind({this.speed, this.deg});

  factory Wind.fromJson(Map<String, dynamic> json) =>
      Wind(
        speed: json['speed'],
        deg: json['deg'],
      );

  @override
  String toString() => '{speed: $speed, deg: $deg}';
}

class Clouds {
  var all;

  Clouds({this.all});

  factory Clouds.fromJson(Map<String, dynamic> json) =>
      Clouds(
        all: json['all'],
      );

  @override
  String toString() => '{all: $all}';
}

class Rain {
  @SerializedName("3h")
  final double hour3;

  Rain({this.hour3});

  factory Rain.fromJson(Map<String, dynamic> json) =>
      Rain(
        hour3: json['hour3'],
      );

  @override
  String toString() => '{3h: $hour3}';
}

class Sys {
  var type;
  var id;
  var message;
  String country;
  var sunrise;
  var sunset;

  Sys({this.type,
    this.id,
    this.message,
    this.country,
    this.sunrise,
    this.sunset});

  factory Sys.fromJson(Map<String, dynamic> json) =>
      Sys(
        type: json['type'],
        id: json['id'],
        message: json['message'],
        country: json['country'],
        sunrise: json['sunrise'],
        sunset: json['sunset'],
      );

  @override
  String toString() => 'Sys: {type: $type, id: $id, message: $message, country: $country, sunrise: $sunrise, sunset: $sunset}';
}
