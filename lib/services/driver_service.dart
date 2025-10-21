import 'package:flutter/material.dart';
import '../models/ride_model.dart';

class DriverService {
  static List<RideOption> getRideOptions() {
    return [
      RideOption(
        type: 'motor',
        name: 'Kuy Ride',
        icon: Icons.directions_bike,
        color: Colors.green,
        rating: 4.8,
        eta: '2-5 min',
        price: 'Rp 5.000 - Rp 15.000',
        features: ['Hemat', 'Cepat', 'Ramah Lingkungan'],
      ),
      RideOption(
        type: 'car',
        name: 'Kuy Car',
        icon: Icons.directions_car,
        color: Colors.blue,
        rating: 4.9,
        eta: '3-8 min',
        price: 'Rp 15.000 - Rp 50.000',
        features: ['Nyaman', 'Aman', 'AC'],
      ),
    ];
  }

  static Future<List<Driver>> getNearbyDrivers(String rideType) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock data based on rideType
    switch (rideType) {
      case 'motor':
        return [
          Driver(
            name: 'Ahmad',
            vehicleType: 'Honda Beat',
            vehicleColor: 'Merah',
            rating: 4.8,
            eta: 3,
            plateNumber: 'B 1234 AB',
            imageUrl: 'assets/Profile.jpg',
            completedRides: 150,
          ),
          Driver(
            name: 'Budi',
            vehicleType: 'Yamaha Mio',
            vehicleColor: 'Biru',
            rating: 4.9,
            eta: 5,
            plateNumber: 'B 5678 CD',
            imageUrl: 'assets/Profile.jpg',
            completedRides: 200,
          ),
          Driver(
            name: 'Cici',
            vehicleType: 'Honda Scoopy',
            vehicleColor: 'Hitam',
            rating: 4.7,
            eta: 7,
            plateNumber: 'B 9012 EF',
            imageUrl: 'assets/Profile.jpg',
            completedRides: 120,
          ),
        ];
      case 'car':
        return [
          Driver(
            name: 'Dedi',
            vehicleType: 'Toyota Avanza',
            vehicleColor: 'Putih',
            rating: 4.9,
            eta: 4,
            plateNumber: 'B 3456 GH',
            imageUrl: 'assets/Profile.jpg',
            completedRides: 180,
          ),
          Driver(
            name: 'Eka',
            vehicleType: 'Honda Jazz',
            vehicleColor: 'Silver',
            rating: 4.8,
            eta: 6,
            plateNumber: 'B 7890 IJ',
            imageUrl: 'assets/Profile.jpg',
            completedRides: 160,
          ),
        ];
      default:
        return [];
    }
  }
}
