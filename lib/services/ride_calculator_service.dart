import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RideCalculatorService {
  static const Map<String, double> _ratePerKm = {
    'motor': 2500, // Rp 2.500 per km
    'car': 3500, // Rp 3.500 per km
    'premium': 4500, // Rp 4.500 per km
  };

  static const Map<String, double> _baseFare = {
    'motor': 8000,
    'car': 15000,
    'premium': 25000,
  };

  // Biaya tambahan untuk waktu sibuk
  static const Map<String, double> _peakHourMultiplier = {
    'motor': 1.3,
    'car': 1.4,
    'premium': 1.2,
  };

  // Fungsi ambil rute OSRM dari koordinat LatLng
  static Future<Map<String, dynamic>> getOsrmRouteLatLng(
    LatLng from,
    LatLng to,
  ) async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/${from.longitude},${from.latitude};${to.longitude},${to.latitude}?overview=full&geometries=geojson';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        final distance = (route['distance'] ?? 0) / 1000.0; // meter to km
        final duration = (route['duration'] ?? 0) / 60.0; // seconds to minutes
        // Parse polyline geometry
        final List<dynamic> coords = route['geometry']['coordinates'];
        final List<LatLng> polylinePoints = coords
            .map<LatLng>((c) => LatLng(c[1] as double, c[0] as double))
            .toList();
        return {
          'distance': distance,
          'duration': duration,
          'geometry': polylinePoints,
        };
      }
      throw Exception('Rute OSRM tidak ditemukan');
    } else {
      throw Exception('Gagal mengambil data OSRM');
    }
  }

  // Hitung ongkos dari jarak (km)
  static int calculateCostByDistance(String rideType, double distanceKm) {
    double baseFare = _baseFare[rideType] ?? 8000;
    double ratePerKm = _ratePerKm[rideType] ?? 2500;
    bool isPeak = isPeakHour();
    double peakMultiplier = isPeak
        ? (_peakHourMultiplier[rideType] ?? 1.0)
        : 1.0;
    double cost = (baseFare + (distanceKm * ratePerKm)) * peakMultiplier;
    return ((cost / 1000).round() * 1000).toInt();
  }

  static bool isPeakHour() {
    final now = DateTime.now();
    final hour = now.hour;
    return hour >= 17 && hour <= 19;
  }

  // Estimasi waktu berdasarkan jarak dan tipe kendaraan
  static String estimateTime(String rideType, double distance) {
    double averageSpeed = rideType == 'motor' ? 40.0 : 35.0; // km/h
    double timeInMinutes = (distance / averageSpeed) * 60;

    // Add traffic factor
    double trafficFactor = isPeakHour() ? 1.4 : 1.0;
    timeInMinutes *= trafficFactor;

    int minTime = (timeInMinutes * 0.8).round(); // -20%
    int maxTime = (timeInMinutes * 1.2).round(); // +20%

    return '$minTime-${maxTime} menit';
  }
}
