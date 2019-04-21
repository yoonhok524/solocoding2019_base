import 'dart:convert';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:solocoding2019_base/data/model/weather.dart';
import 'package:solocoding2019_base/data/source/recentLocalDao.dart';
import 'package:solocoding2019_base/ui/home.dart';
import 'package:solocoding2019_base/ui/recentSearches.dart';
import 'package:solocoding2019_base/utils/secrets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



Future main() async {
  await AndroidAlarmManager.initialize();
  runApp(WeatherApp());
  await AndroidAlarmManager.periodic(const Duration(hours: 1), 0, _fetchWeather);
}

class WeatherApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'solocoding2019',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/recentSearches': (context) => RecentSearchesPage(),
      },
    );
  }
}

void _fetchWeather() async {
  print("[Weather][Alarm] _fetchWeather");
  final RecentLocalDao _recentSearchDao = RecentLocalDao();
  final recent = await _recentSearchDao.getLatest();
  if (recent != null) {
    final secret = await SecretLoader(secretPath: "secrets.json").load();
    final response = await http
        .get("$BASE_URL/weather?APPID=${secret.apiKey}&lat=${recent.lat}&lon=${recent.lon}");
    if (response.statusCode == 200) {
      final weather = WeatherResp.fromJson(json.decode(response.body));
      print("[Weather][Alarm] _fetchWeather - $weather");
      _showNoti(weather);
    } else {
      throw Exception('Failed to load post');
    }
  }
}

Future _showNoti(WeatherResp weather) async {
  if (DateTime.now().hour == 7) {
    if (weather.weather[0].main == "Rain") {
      var initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
      var initializationSettingsIOS = IOSInitializationSettings();
      var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      flutterLocalNotificationsPlugin.initialize(initializationSettings);

      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'weatherChannel', 'flutter_weather', 'this is for flutter weather app',
          importance: Importance.Max,
          priority: Priority.High);
      var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, IOSNotificationDetails());
      await flutterLocalNotificationsPlugin.show(
        0,
        'Rain!',
        "${weather.name}, It's rainig!",
        platformChannelSpecifics,
      );
    }
  }
}