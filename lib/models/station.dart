import 'package:hive/hive.dart';

part 'station.g.dart';  

@HiveType(typeId: 0)
class CachedStation {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final double lat;

  @HiveField(4)
  final double lng;

  @HiveField(5)
  final String? status;

  @HiveField(6)
  final String? price;

  @HiveField(7)
  final String? phone;

  @HiveField(8)
  final String? whatsapp;

  @HiveField(9)
  final List<String> photos;

  @HiveField(10)
  final bool verified;

  @HiveField(11)
  final Map<String, dynamic>? petrolData;

  @HiveField(12)
  final Map<String, dynamic>? dieselData;

  @HiveField(13)
  final List<dynamic>? lpgType;

  @HiveField(14)
  final List<dynamic>? chargingPoints;

  @HiveField(15)
  final bool hasBackupGenerator;

  @HiveField(16)
  final bool deliveryAvailable;

  CachedStation({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
    this.status,
    this.price,
    this.phone,
    this.whatsapp,
    this.photos = const [],
    this.verified = false,
    this.petrolData,
    this.dieselData,
    this.lpgType,
    this.chargingPoints,
    this.hasBackupGenerator = false,
    this.deliveryAvailable = false,
  });

  factory CachedStation.fromJson(Map<String, dynamic> json) {
    return CachedStation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      status: json['status'],
      price: json['price'],
      phone: json['phone'],
      whatsapp: json['whatsapp'],
      photos: (json['photos'] as List?)?.cast<String>() ?? [],
      verified: json['verified'] ?? false,
      petrolData: json['petrol'] ?? json['petrol_data'],
      dieselData: json['diesel'] ?? json['diesel_data'],
      lpgType: json['lpg_type'],
      chargingPoints: json['charging_points'],
      hasBackupGenerator: json['has_backup_generator'] ?? false,
      deliveryAvailable: json['delivery_available'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'lat': lat,
    'lng': lng,
    'status': status,
    'price': price,
    'phone': phone,
    'whatsapp': whatsapp,
    'photos': photos,
    'verified': verified,
    'petrol': petrolData,
    'petrol_data': petrolData,
    'diesel': dieselData,
    'diesel_data': dieselData,
    'lpg_type': lpgType,
    'charging_points': chargingPoints,
    'has_backup_generator': hasBackupGenerator,
    'delivery_available': deliveryAvailable,
  };
}