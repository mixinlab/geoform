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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['unicode'] = this.unicode;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['geom'] = this.geom;
    return data;
  }
}
