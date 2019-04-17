class Location {
  final int id;
  final String name;
  final double lon;
  final double lat;

  Location({this.id, this.name, this.lon, this.lat});

  factory Location.fromJson(Map<String, dynamic> json) => Location(
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
  String toString() => 'Location{id: $id, name: $name, lon: $lon, lat: $lat}';
}
