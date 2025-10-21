import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String email = '';
  String role = '';
  String phone = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email = user.email ?? '';
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        name = data['name'] ?? '';
        role = data['role'] ?? '';
        phone = data['phone'] ?? '';
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _editPhone() async {
    final user = FirebaseAuth.instance.currentUser;
    TextEditingController phoneController = TextEditingController(text: phone);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Nomor HP',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Nomor HP',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Batal', style: GoogleFonts.poppins()),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Simpan', style: GoogleFonts.poppins()),
            onPressed: () async {
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .update({'phone': phoneController.text});
                setState(() {
                  phone = phoneController.text;
                });
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          },
        ),
        title: Text(
          'Profil Saya',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF43EA7A), Color(0xFF1B7F3A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF43EA7A), Color(0xFF1B7F3A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.18),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 54,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 48,
                              backgroundImage: AssetImage('assets/Profile.jpg'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                        ),
                        Text(
                          email,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            role.isNotEmpty
                                ? role[0].toUpperCase() + role.substring(1)
                                : '',
                            style: GoogleFonts.poppins(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone, color: Colors.white70, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              phone,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white70,
                                size: 20,
                              ),
                              onPressed: _editPhone,
                              tooltip: 'Edit Nomor HP',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white.withOpacity(0.95),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.account_circle,
                            color: Colors.green[700],
                          ),
                          title: Text(
                            'Edit Profil',
                            style: GoogleFonts.poppins(),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: () {},
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.lock, color: Colors.green[700]),
                          title: Text(
                            'Ubah Password',
                            style: GoogleFonts.poppins(),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: () {},
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.phone, color: Colors.green[700]),
                          title: Text('Nomor HP', style: GoogleFonts.poppins()),
                          trailing: Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: _editPhone,
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.logout, color: Colors.red[400]),
                          title: Text(
                            'Keluar',
                            style: GoogleFonts.poppins(color: Colors.red[400]),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      '© 2024 Movaka Apps',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
