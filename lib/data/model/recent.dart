class Recent {
  final String id;
  final String name;
  final double lon;
  final double lat;
  final int time;

  Recent({this.id, this.name, this.lon, this.lat, this.time});

  factory Recent.fromJson(Map<String, dynamic> json) => Recent(
        id: json['id'],
        name: json['name'],
        lon: json['lon'],
        lat: json['lat'],
        time: json['time'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'lon': lon,
        'lat': lat,
        'time': time,
      };

  @override
  String toString() => 'Recent{id: $id, name: $name, lon: $lon, lat: $lat, time: $time}';
}
