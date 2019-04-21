import 'package:solocoding2019_base/data/model/favorite.dart';
import 'package:solocoding2019_base/data/source/favoriteLocalDao.dart';
import 'package:rxdart/rxdart.dart';

class FavoriteBloc {
  final FavoriteLocalDao _favoriteDao;
  final String _favoriteId;

  final _getSubject = PublishSubject<Favorite>();

  FavoriteBloc(this._favoriteDao, this._favoriteId) {
    _get(_favoriteId);

    _saveFavoriteSubject.listen(_save);
    _deleteSubject.listen(_delete);
  }

  Stream<Favorite> get get => _getSubject.stream;

  Sink<Favorite> get save => _saveFavoriteSubject.sink;

  Sink<Favorite> get delete => _deleteSubject.sink;

  final _saveFavoriteSubject = PublishSubject<Favorite>();

  final _deleteSubject = PublishSubject<Favorite>();

  Future<Null> _get(String favoriteId) async {
    await _favoriteDao.get(favoriteId).then((favorite) => {
      _getSubject.add(favorite)
    });
  }

  void _save(Favorite favorite) {
    print("[Weather] _saveFavorite: $favorite");
    _favoriteDao.save(favorite);
  }

  void _delete(Favorite favorite) {
    print("[Weather] _deleteFavorite: $favorite");
    _favoriteDao.delete(favorite.id);
  }
}
