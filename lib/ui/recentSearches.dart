import 'package:flutter/material.dart';
import 'package:solocoding2019_base/bloc/recentSearchesBloc.dart';
import 'package:solocoding2019_base/data/model/recent.dart';
import 'package:solocoding2019_base/data/source/recentLocalDao.dart';

class RecentSearchesPage extends StatelessWidget {
  final RecentSearchesBloc bloc = RecentSearchesBloc(RecentLocalDataSource());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recent Searches"),
      ),
      body: _recentSearchList(),
    );
  }

  _recentSearchList() {
    return Center(
      child: StreamBuilder<List<Recent>>(
        stream: bloc.recentSearches,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            case ConnectionState.active:
            case ConnectionState.done:
              return ListView.separated(
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.black),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) =>
                    _buildItem(context, snapshot.data[index]),
              );
          }
        },
      ),
    );
  }

  Widget _buildItem(BuildContext context, Recent recent) {
    final dt = DateTime.fromMillisecondsSinceEpoch(recent.time);
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                recent.name,
                style: Theme.of(context).textTheme.headline,
              ),
            ),
            Text(
                "${dt.year}-${dt.month}-${dt.day} ${dt.hour}:${dt.minute}:${dt.second}"),
          ],
        ),
      ),
      onTap: () {
        print("[Weather] RecentSearch - onTap: $recent");
        Navigator.pop(context, recent);
      },
    );
  }
}
