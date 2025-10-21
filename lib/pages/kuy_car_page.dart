import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kos Putin AI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const RideBookingScreen(),
    );
  }
}

class RideBookingScreen extends StatefulWidget {
  const RideBookingScreen({super.key});

  @override
  State<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> {
  late GoogleMapController mapController;
  LatLng? currentLocation;
  String pickupAddress = "Mencari lokasi...";
  final String destinationAddress = "Kos Putin AI\nFakultas Paisologi UOM\nYogyakarta";
  
  // State untuk pilihan layanan
  String selectedService = "GoRide";
  int estimatedTime = 7;
  int xpEarned = 4;
  
  // Harga dasar per km
  final double pricePerKm = 5000;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Fungsi untuk mendapatkan lokasi saat ini
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );
      
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks.first;
          pickupAddress = "${placemark.street}, ${placemark.subLocality}, ${placemark.locality}";
        }
      });
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        pickupAddress = "Tidak dapat menemukan lokasi";
      });
    }
  }

  // Fungsi untuk menghitung harga berdasarkan jarak (simulasi)
  int calculatePrice(String service) {
    // Simulasi perhitungan jarak (dalam km)
    double distance = Random().nextDouble() * 5 + 2; // Random 2-7 km
    
    switch (service) {
      case "GoRide":
        return (distance * pricePerKm).round();
      case "GoCar":
        return (distance * pricePerKm * 1.5).round();
      case "GoCar (L)":
        return (distance * pricePerKm * 1.75).round();
      default:
        return 12000;
    }
  }

  // Fungsi untuk estimasi waktu (simulasi)
  int calculateTime(String service) {
    switch (service) {
      case "GoRide":
        return Random().nextInt(4) + 7; // 7-10 menit
      case "GoCar":
        return Random().nextInt(4) + 9; // 9-12 menit
      case "GoCar (L)":
        return 10; // Fixed 10 menit
      default:
        return 7;
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentPrice = calculatePrice(selectedService);
    int currentTime = calculateTime(selectedService);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kos Putin AI'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: currentLocation == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: currentLocation!,
                      zoom: 15.0,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('currentLocation'),
                        position: currentLocation!,
                        infoWindow: const InfoWindow(title: 'Lokasi Anda'),
                      ),
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
          ),
          
          // Booking Section
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Pickup and Destination
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pickup Location
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pickup',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    pickupAddress,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Destination
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Destination',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    destinationAddress,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // Service Options
                  Expanded(
                    child: ListView(
                      children: [
                        // GoRide Option
                        _buildServiceOption(
                          "GoRide",
                          "7-10 mins",
                          "1",
                          currentPrice,
                          isSelected: selectedService == "GoRide",
                          xpEarned: 4,
                        ),
                        
                        const Divider(height: 1),
                        
                        // GoCar Option
                        _buildServiceOption(
                          "GoCar",
                          "9-12 mins",
                          "4",
                          calculatePrice("GoCar"),
                          isSelected: selectedService == "GoCar",
                        ),
                        
                        const Divider(height: 1),
                        
                        // GoCar (L) Option
                        _buildServiceOption(
                          "GoCar (L)",
                          "10 mins",
                          "",
                          calculatePrice("GoCar (L)"),
                          isSelected: selectedService == "GoCar (L)",
                        ),
                      ],
                    ),
                  ),
                  
                  // Payment and Order Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.payment, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Cash >',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Rp${currentPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Up to 10k in voucher if your pickup is delayed',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // XP Earned (hanya untuk GoRide)
                        if (selectedService == "GoRide") ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.emoji_events, size: 16, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                'You\'ll earn $xpEarned XP',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        
                        // Order Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _showOrderConfirmation(currentPrice);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Order $selectedService',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceOption(
    String serviceName,
    String timeRange,
    String passengers,
    int price, {
    bool isSelected = false,
    int xpEarned = 0,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          serviceName.contains("Ride") ? Icons.motorcycle : Icons.directions_car,
          color: isSelected ? Colors.white : Colors.grey.shade700,
        ),
      ),
      title: Text(
        serviceName,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.blue : Colors.black,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(timeRange),
          if (passengers.isNotEmpty) Text('$passengers penumpang'),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Rp${price.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
          if (xpEarned > 0) ...[
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, size: 12, color: Colors.orange),
                const SizedBox(width: 2),
                Text(
                  '$xpEarned XP',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      onTap: () {
        setState(() {
          selectedService = serviceName;
        });
      },
    );
  }

  void _showOrderConfirmation(int price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Layanan: $selectedService'),
            Text('Estimasi waktu: ${calculateTime(selectedService)} menit'),
            Text('Harga: Rp${price.toStringAsFixed(0)}'),
            if (selectedService == "GoRide") 
              const Text('XP yang didapat: 4 XP'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pesanan $selectedService berhasil dibuat!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Pesan Sekarang'),
          ),
        ],
      ),
    );
  }
}