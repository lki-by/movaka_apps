// models/ride_model.dart - Tambahkan field kecamatan
import 'package:flutter/material.dart';

/// models/ride_model.dart
class KomerceAddress {
  final String provinceId;
  final String provinceName;
  final String cityId;
  final String cityName;
  final String districtId;
  final String districtName;
  final String subdistrictId;
  final String subdistrictName;

  KomerceAddress({
    required this.provinceId,
    required this.provinceName,
    required this.cityId,
    required this.cityName,
    required this.districtId,
    required this.districtName,
    required this.subdistrictId,
    required this.subdistrictName,
  });

  String get fullAddress {
    List<String> parts = [];
    if (subdistrictName.isNotEmpty) parts.add(subdistrictName);
    if (districtName.isNotEmpty) parts.add(districtName);
    if (cityName.isNotEmpty) parts.add(cityName);
    if (provinceName.isNotEmpty) parts.add(provinceName);
    return parts.join(', ');
  }

  String get shortAddress {
    if (subdistrictName.isNotEmpty) return subdistrictName;
    if (districtName.isNotEmpty) return districtName;
    if (cityName.isNotEmpty) return cityName;
    return provinceName;
  }
}

class RideOption {
  final String type;
  final String name;
  final IconData icon;
  final Color color;
  final double rating;
  final String eta;
  final String price;
  final List<String> features;

  RideOption({
    required this.type,
    required this.name,
    required this.icon,
    required this.color,
    required this.rating,
    required this.eta,
    required this.price,
    required this.features,
  });
}

class Driver {
  final String name;
  final String vehicleType;
  final String vehicleColor;
  final double rating;
  final int eta;
  final String plateNumber;
  final String imageUrl;
  final int completedRides;

  Driver({
    required this.name,
    required this.vehicleType,
    required this.vehicleColor,
    required this.rating,
    required this.eta,
    required this.plateNumber,
    required this.imageUrl,
    required this.completedRides,
  });
}
