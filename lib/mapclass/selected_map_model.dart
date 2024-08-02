import 'package:latlong2/latlong.dart';

class SelectedPlace {
  String userId;
  String name;
  LatLng location;
  String info1;
  String info2;
  String docID;


  SelectedPlace(
      {required this.userId,
      required this.name,
      required this.location,
      this.info1 = '',
      this.info2 = '',
      this.docID = ""});

  factory SelectedPlace.fromJson(Map<String, dynamic> json) {
    return SelectedPlace(
        userId: json['userID'],
        name: json['name'],
        location: LatLng(json['latitude'], json['longitude']),
        info1: json['info1'] ?? '',
        info2: json['info2'] ?? '',
        docID: json['docID'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userId,
      'name': name,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'info1': info1,
      'info2': info2,
      'docID': docID
    };
  }
}
