class Favorite {
  final int id;
  final String name;
  final double lon;
  final double lat;

  Favorite({this.id, this.name, this.lon, this.lat});

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
        id: json['id'],
        name: json['name'],
        lon: json['lon'],
        lat: json['lat'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'lon': lon,
        'lat': lat,
      };

  @override
  String toString() => 'Favorite{id: $id, name: $name, lon: $lon, lat: $lat}';
}
