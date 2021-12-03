class GeoPoint {
  String? id;
  String? unicode;
  double? lat;
  double? lng;
  String? geom;

  GeoPoint({
    this.id,
    this.unicode,
    this.lat,
    this.lng,
    this.geom,
  });

  GeoPoint.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    unicode = json['unicode'];
    lat = json['lat'];
    lng = json['lng'];
    geom = json['geom'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['unicode'] = unicode;
    data['lat'] = lat;
    data['lng'] = lng;
    data['geom'] = geom;
    return data;
  }
}
