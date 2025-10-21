// pages/kuy_ride_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/ride_model.dart';
import '../services/driver_service.dart';
import '../services/ride_calculator_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class KuyRidePage extends StatefulWidget {
  const KuyRidePage({Key? key}) : super(key: key);

  @override
  State<KuyRidePage> createState() => _KuyRidePageState();
}

class _KuyRidePageState extends State<KuyRidePage> {
  LatLng? _pickupLatLng;
  LatLng? _destinationLatLng;
  Polyline? _routePolyline;
  double? _routeDistanceKm;
  double? _routeDurationMin;

  String? _pickupAddressName;
  String? _destinationAddressName;

  // Kunci lokasi pickup di Kumpay
  final LatLng _fixedPickupLatLng = LatLng(-6.6355, 107.7607); // Kumpay
  final String _fixedPickupAddress = "Kumpay, Subang, Jawa Barat";

  // Method to select ride option and recalculate route/cost
  void _selectRideOption(RideOption option) {
    setState(() {
      _selectedRideOption = option;
    });
    if (_pickupLatLng != null && _destinationLatLng != null) {
      _getRouteAndCost();
    }
  }

  bool _isLoading = false;
  bool _isCalculating = false;
  int? _calculatedCost;
  String _estimatedTime = '';
  RideOption? _selectedRideOption;
  List<RideOption> _rideOptions = [];
  List<Driver> _drivers = [];
  Driver? _selectedDriver;

  final TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Ambil lokasi real user saat init
    _loadInitialData();
  }

  // Ambil lokasi real-time user
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Izin lokasi ditolak');
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showError('Izin lokasi ditolak permanen. Aktifkan di pengaturan.');
        setState(() {
          _isLoading = false;
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);
      final addressName = await _getAddressName(latLng);
      setState(() {
        _pickupLatLng = latLng;
        _pickupAddressName = addressName;
      });
    } catch (e) {
      _showError('Gagal mengambil lokasi: $e');
      setState(() {
        _pickupLatLng = _fixedPickupLatLng;
        _pickupAddressName = _fixedPickupAddress;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchDestination() async {
    final query = _destinationController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final url =
          'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query + ", Subang")}&limit=1';
      final response = await http.get(Uri.parse(url));
      final results = json.decode(response.body);
      if (results.isNotEmpty) {
        // Pastikan parsing lat/lon ke double
        final lat = double.parse(results[0]['lat'].toString());
        final lon = double.parse(results[0]['lon'].toString());
        final displayName = results[0]['display_name'];
        // Validasi Subang
        if (!displayName.toLowerCase().contains('subang')) {
          _showError('Tujuan harus di Subang!');
          setState(() {
            _isLoading = false;
          });
          return;
        }
        // Ambil nama alamat hasil reverse geocoding (lebih akurat)
        final addressName = await _getAddressName(LatLng(lat, lon));
        setState(() {
          _destinationLatLng = LatLng(lat, lon);
          _destinationAddressName = addressName;
        });
        _getRouteAndCost();
      } else {
        _showError('Tujuan tidak ditemukan!');
      }
    } catch (e) {
      _showError('Gagal mencari tujuan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      print('🔄 Loading initial data...');

      _rideOptions = DriverService.getRideOptions();
      _selectedRideOption = _rideOptions.isNotEmpty ? _rideOptions.first : null;
      _drivers = await DriverService.getNearbyDrivers('motor');

      print('✅ Initial data loaded successfully');
    } catch (e) {
      print('❌ Error loading initial data: $e');

      // Tampilkan error yang lebih user-friendly
      String errorMessage = 'Gagal memuat data wilayah. ';

      if (e.toString().contains('ClientException') ||
          e.toString().contains('Failed to fetch') ||
          e.toString().contains('koneksi internet')) {
        errorMessage +=
            'Periksa koneksi internet Anda dan pastikan dapat mengakses https://emsifa.github.io';
      } else if (e.toString().contains('HTTP')) {
        errorMessage +=
            'Server sedang mengalami masalah. Silakan coba lagi nanti.';
      } else {
        errorMessage += 'Terjadi kesalahan: $e';
      }

      _showError(errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Kalkulasi ongkos dan waktu menggunakan OSRM
  // (Method _calculateRideCost dihapus karena tidak digunakan)

  // Kalkulasi rute dan ongkos berdasarkan titik latitude dan longitude
  Future<void> _getRouteAndCost() async {
    if (_pickupLatLng == null || _destinationLatLng == null) return;
    setState(() {
      _isCalculating = true;
      _routePolyline = null;
      _routeDistanceKm = null;
      _routeDurationMin = null;
      _calculatedCost = null;
      _estimatedTime = '';
    });
    try {
      final route = await RideCalculatorService.getOsrmRouteLatLng(
        _pickupLatLng!,
        _destinationLatLng!,
      );
      setState(() {
        _routeDistanceKm = route['distance'];
        _routeDurationMin = route['duration'];
        _routePolyline = Polyline(
          points: route['geometry'],
          strokeWidth: 5,
          color: Colors.green.shade700,
        );
        // Hitung ongkos
        final rideType = _selectedRideOption?.type ?? 'motor';
        final cost = RideCalculatorService.calculateCostByDistance(
          rideType,
          _routeDistanceKm!,
        );
        _calculatedCost = cost;
        _estimatedTime = '${_routeDurationMin!.round()} menit';
      });
    } catch (e) {
      _showError('Gagal mengambil rute: $e');
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  // Fungsi reverse geocoding (Nominatim)
  Future<String> _getAddressName(LatLng latLng) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${latLng.latitude}&lon=${latLng.longitude}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? 'Tidak ditemukan';
      }
    } catch (_) {}
    return 'Tidak ditemukan';
  }

  // Filter driver sesuai tipe ride
  Future<void> _loadDriversForType(String rideType) async {
    setState(() {
      _isLoading = true;
      _drivers = [];
      _selectedDriver = null;
    });
    try {
      _drivers = await DriverService.getNearbyDrivers(rideType);
    } catch (e) {
      _showError('Gagal memuat driver: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Scroll ke pembayaran setelah driver dipilih
  final _scrollController = ScrollController();

  void _selectDriverAndScroll(Driver driver) {
    setState(() {
      _selectedDriver = driver;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final canOrder =
        _pickupLatLng != null &&
        _destinationLatLng != null &&
        _calculatedCost != null &&
        _selectedDriver != null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF43EA7A), Color(0xFF1B7F3A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  // Floating back button
                  Material(
                    color: Colors.white.withOpacity(0.18),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Logo and title
                  Image.asset('assets/Login.png', height: 32),
                  const SizedBox(width: 10),
                  const Text(
                    'Kuy Ride',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Refresh button
                  Material(
                    color: Colors.white.withOpacity(0.18),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () async {
                        await _getCurrentLocation();
                        await _loadInitialData();
                        setState(() {
                          _destinationController.clear();
                          _destinationLatLng = null;
                          _destinationAddressName = null;
                          _routePolyline = null;
                          _routeDistanceKm = null;
                          _routeDurationMin = null;
                          _calculatedCost = null;
                          _estimatedTime = '';
                          _selectedDriver = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Halaman telah di-refresh!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      splashRadius: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Map di atas
          SizedBox(height: 220, child: _buildMap()),
          // Card input di atas map
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.my_location,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _pickupAddressName ?? "Lokasi Anda",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 22),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.orange[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _destinationController,
                            decoration: const InputDecoration(
                              hintText: "Mau ke mana?",
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            onSubmitted: (_) => _searchDestination(),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _searchDestination,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.search, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Stepper dan konten utama
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _stepCircle(
                          1,
                          "Pilih Tujuan",
                          _destinationLatLng != null,
                        ),
                        _stepLine(),
                        _stepCircle(
                          2,
                          "Pilih Tipe",
                          _selectedRideOption != null,
                        ),
                        _stepLine(),
                        _stepCircle(3, "Pilih Driver", _selectedDriver != null),
                        _stepLine(),
                        _stepCircle(
                          4,
                          "Pembayaran",
                          _calculatedCost != null && _selectedDriver != null,
                        ),
                      ],
                    ),
                  ),
                  // Info perjalanan
                  if (_routeDistanceKm != null && _routeDurationMin != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.route, color: Colors.green[700]),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_routeDistanceKm!.toStringAsFixed(1)} km',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.timer, color: Colors.orange[700]),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_routeDurationMin!.round()} menit',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _calculatedCost != null
                                        ? 'Rp${_calculatedCost!.toStringAsFixed(0)}'
                                        : '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Pilihan tipe ride
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Card Tipe Driver",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _rideOptions.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, idx) {
                              final option = _rideOptions[idx];
                              return AspectRatio(
                                aspectRatio: 1.7,
                                child: _buildRideOptionCard(option),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Daftar driver
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pilih Driver",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._drivers.map(
                              (driver) => Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  splashColor: Colors.green.withOpacity(0.15),
                                  onTap: () => _selectDriverAndScroll(driver),
                                  child: _buildDriverItemModern(driver),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Order & pembayaran
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.payments, color: Colors.green[700]),
                                const SizedBox(width: 8),
                                const Text(
                                  "Cash",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.card_giftcard,
                                  color: Colors.orange[700],
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Voucher",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            if (canOrder)
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.emoji_events,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Dapat 4 XP",
                                          style: TextStyle(
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.motorcycle, size: 22),
                                label: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 38.0,
                                      ),
                                      child: Text(
                                        canOrder
                                            ? 'Order GoRide   Rp${_calculatedCost?.toStringAsFixed(0) ?? "0"}'
                                            : 'Pilih Tujuan & Driver',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (canOrder)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF43EA7A),
                                                Color(0xFF1B7F3A),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.yellow[700],
                                                size: 16,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                "+4 XP",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                onPressed: canOrder
                                    ? () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Order berhasil! Driver ${_selectedDriver!.name} menuju ke Anda. Biaya: Rp ${_calculatedCost!.toStringAsFixed(0)}\nEstimasi sampai: ${_routeDurationMin!.round()} menit',
                                            ),
                                            backgroundColor: Colors.green,
                                            behavior: SnackBarBehavior.floating,
                                            duration: const Duration(
                                              seconds: 3,
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 4,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step indicator widget
  Widget _stepCircle(int step, String label, bool active) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? Colors.green.shade700 : Colors.grey.shade300,
            shape: BoxShape.circle,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.18),
                      blurRadius: 8,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: active ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: active ? Colors.green.shade700 : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _stepLine() {
    return Container(width: 24, height: 2, color: Colors.grey.shade300);
  }

  // Pilihan tipe ride
  Widget _buildRideOptionCard(RideOption option) {
    final isSelected = _selectedRideOption?.type == option.type;
    final isPeakHour = RideCalculatorService.isPeakHour();

    return GestureDetector(
      onTap: () {
        _selectRideOption(option);
        _loadDriversForType(option.type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? option.color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? option.color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: option.color.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: option.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.motorcycle,
                      color: option.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      option.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: option.color,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.star, color: Colors.amber, size: 15),
                  const SizedBox(width: 2),
                  Text(
                    option.rating.toString(),
                    style: const TextStyle(fontSize: 11),
                  ),
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: option.color,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey[600], size: 13),
                  const SizedBox(width: 3),
                  Text(
                    option.eta,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    option.price,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: option.color,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (isPeakHour) ...[
                const SizedBox(height: 2),
                Text(
                  '🕔 Termasuk tarif waktu sibuk',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 5),
              Flexible(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 3,
                    children: option.features
                        .map(
                          (feature) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: option.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              feature,
                              style: TextStyle(
                                color: option.color,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modern driver card
  Widget _buildDriverItemModern(Driver driver) {
    final isSelected = _selectedDriver == driver;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? Colors.green.shade700 : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: Colors.green.shade700.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: AnimatedScale(
          scale: isSelected ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                child: driver.imageUrl.startsWith('http')
                    ? ClipOval(
                        child: Image.network(
                          driver.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  driver.name[0],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            driver.name[0],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ),
              if (isSelected)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
        title: Text(
          driver.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${driver.vehicleType} • ${driver.vehicleColor}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  driver.rating.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Icon(Icons.directions_car, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text('${driver.completedRides} trip'),
                const SizedBox(width: 12),
                Icon(Icons.access_time, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Text('${driver.eta} min'),
              ],
            ),
          ],
        ),
        trailing: AnimatedOpacity(
          opacity: isSelected ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: isSelected
              ? Text(
                  'Dipilih',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                )
              : null,
        ),
        onTap: () => _selectDriverAndScroll(driver),
      ),
    );
  }

  Widget _buildMap() {
    List<Marker> markers = [];
    if (_pickupLatLng != null) {
      markers.add(
        Marker(
          point: _pickupLatLng!,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, color: Colors.green, size: 36),
        ),
      );
    }
    if (_destinationLatLng != null) {
      markers.add(
        Marker(
          point: _destinationLatLng!,
          width: 40,
          height: 40,
          child: const Icon(Icons.flag, color: Colors.red, size: 36),
        ),
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: _fixedPickupLatLng,
        initialZoom: 13.5,
        minZoom: 11,
        maxZoom: 16,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
        // Tidak bisa tap map untuk ubah pickup
        cameraConstraint: CameraConstraint.contain(
          bounds: LatLngBounds(
            const LatLng(-6.3, 107.5),
            const LatLng(-6.8, 108.0),
          ),
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.movaka_apps',
        ),
        if (markers.isNotEmpty) MarkerLayer(markers: markers),
        if (_routePolyline != null) PolylineLayer(polylines: [_routePolyline!]),
      ],
    );
  }
}
