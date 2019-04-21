import 'package:solocoding2019_base/data/model/recent.dart';
import 'package:solocoding2019_base/data/source/recentLocalDao.dart';
import 'package:rxdart/rxdart.dart';

class RecentSearchesBloc {
  final RecentLocalDao _recentSearchDao;

  final _getRecentSearchesSubject = PublishSubject<List<Recent>>();

  RecentSearchesBloc(this._recentSearchDao) {
    _getAll();

    _saveRecentSubject.listen(_save);
  }

  Stream<List<Recent>> get recentSearches => _getRecentSearchesSubject.stream;

  Sink<Recent> get save => _saveRecentSubject.sink;

  final _saveRecentSubject = PublishSubject<Recent>();

  Future<Null> _getAll() async {
    await _recentSearchDao.getAll().then((list) {
      print("[Weather] recentSearch - getAll: ${list.length}");
      _getRecentSearchesSubject.add(list.reversed.toList());
    });
  }

  void _save(Recent recent) {
    print("[Weather] _saveRecent: $recent");
    _recentSearchDao.save(recent);
  }
}