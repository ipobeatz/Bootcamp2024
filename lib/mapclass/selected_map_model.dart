import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class SelectedPlace {
  String name;
  LatLng location;
  String info1;
  String info2;

  SelectedPlace({required this.name, required this.location, this.info1 = '', this.info2 = ''});

  factory SelectedPlace.fromJson(Map<String, dynamic> json) {
    return SelectedPlace(
      name: json['name'],
      location: LatLng(json['latitude'], json['longitude']),
      info1: json['info1'] ?? '',
      info2: json['info2'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'info1': info1,
      'info2': info2,
    };
  }
}


