import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'orders_page.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF43EA7A), Color(0xFF1B7F3A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.10),
                            blurRadius: 16,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(Icons.search, color: Colors.grey[400], size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Cari layanan, makanan, tempat',
                                border: InputBorder.none,
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/Profile.jpg'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        children: [
          // GoPay Card Glassmorphism
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                colors: [
                  Colors.blue[800]!.withOpacity(0.92),
                  Colors.blue[400]!.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.13),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.13),
                width: 1.2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/Login.png', height: 30),
                        const SizedBox(width: 10),
                        Text(
                          'Movaka',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Rp. 1.000.000',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.3,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap for history',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    _gopayAction(context, Icons.payment, 'Pay', '/pay'),
                    _gopayAction(context, Icons.add_circle, 'Top up', '/topup'),
                    Stack(
                      children: [
                        _gopayAction(
                          context,
                          Icons.explore,
                          'Explore',
                          '/explore',
                        ),
                        Positioned(
                          right: 0,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.red,
                            child: const Text(
                              '5',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          // Service Icons
          Card(
            elevation: 0,
            color: Colors.white.withOpacity(0.98),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 20,
                crossAxisSpacing: 10,
                children: [
                  _serviceIcon(
                    '../assets/motor.png',
                    'Kuyride',
                    const Color(0xFFE8F8E4),
                    Colors.green,
                    onTap: () => Navigator.pushNamed(context, '/kuyride'),
                  ),
                  _serviceIcon(
                    '../assets/mobil.png',
                    'Kuycar',
                    const Color(0xFFE8F8E4),
                    Colors.green,
                    onTap: () => Navigator.pushNamed(context, '/kuycar'),
                  ),
                  _serviceIcon(
                    '../assets/garpu.png',
                    'KuyFood',
                    const Color(0xFFFDE7E7),
                    Colors.red,
                    onTap: () => Navigator.pushNamed(context, '/kuyfood'),
                  ),
                  // KuySend pakai icon Flutter
                  _serviceIconIcon(
                    Icons.send,
                    'KuySend',
                    const Color(0xFFE8F8E4),
                    Colors.green,
                  ),
                  // KuyMart pakai icon Flutter
                  _serviceIconIcon(
                    Icons.store,
                    'KuyMart',
                    const Color(0xFFFDE7E7),
                    Colors.red,
                  ),
                  // KuyPulsa pakai icon Flutter
                  _serviceIconIcon(
                    Icons.phone_android,
                    'KuyPulsa',
                    const Color(0xFFE7F4FD),
                    Colors.blue,
                  ),
                  _serviceIcon(
                    '../assets/club.png',
                    'KuyClub',
                    const Color(0xFFF3E7FD),
                    Colors.purple,
                  ),
                  // Lainnya pakai icon Flutter
                  _serviceIconIcon(
                    Icons.more_horiz,
                    'Lainnya',
                    const Color(0xFFF3F3F3),
                    Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          // Promo Banner pakai gambar ads.png
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.13),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                'assets/ads.png',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 26),
          // GoFood Section pakai gambar ads1.png
          Container(
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.13),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/ads1.png',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 18,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          selectedItemColor: Colors.green[700],
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.local_offer),
              label: 'Promos',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat),
              label: 'Chat',
            ),
          ],
          onTap: (index) {
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrdersPage()),
              );
            }
          },
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  Widget _gopayAction(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(13),
              child: Icon(icon, color: Colors.white, size: 23),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceIcon(
    String asset,
    String label,
    Color bgColor,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    Widget iconWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: bgColor.withOpacity(0.16),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
          ),
          child: Center(
            child: Image.asset(asset, width: 34, height: 34, color: iconColor),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 150),
          child: iconWidget,
        ),
      );
    }
    return iconWidget;
  }

  // Tambahkan widget baru untuk icon Flutter
  Widget _serviceIconIcon(
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    Widget iconWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: bgColor.withOpacity(0.16),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
          ),
          child: Center(child: Icon(icon, size: 34, color: iconColor)),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 150),
          child: iconWidget,
        ),
      );
    }
    return iconWidget;
  }
}
