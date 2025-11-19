import 'package:latlong2/latlong.dart' as latlong;

class CatatanModel {
  final String id;
  final latlong.LatLng position;
  final String note;
  final String address;
  final String type; 

  CatatanModel({
    required this.id,
    required this.position,
    required this.note,
    required this.address,
    required this.type,
  });

  factory CatatanModel.fromMap(Map<String, dynamic> map) {
    return CatatanModel(
      id: map['id'],
      position: latlong.LatLng(
        map['lat'],
        map['lng'],
      ),
      note: map['note'],
      address: map['address'],
      type: map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lat': position.latitude,
      'lng': position.longitude,
      'note': note,
      'address': address,
      'type': type,
    };
  }
}