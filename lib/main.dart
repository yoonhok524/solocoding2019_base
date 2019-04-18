import 'package:flutter/material.dart';
import 'package:solocoding2019_base/ui/home.dart';
import 'package:solocoding2019_base/ui/recentSearches.dart';

void main() => runApp(WeatherApp());

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      MaterialApp(
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
