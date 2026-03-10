import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tbmate_kmipn/color.dart';
import 'package:tbmate_kmipn/pages/akun_page.dart';
import 'package:tbmate_kmipn/pages/jadwal_page.dart';
import 'package:tbmate_kmipn/pages/riwayat_page.dart';
import 'package:tbmate_kmipn/pmo/pasien_list.dart';
import 'package:tbmate_kmipn/pmo/pmo_jadwal_page.dart';

class PmoMainScreen extends StatefulWidget {
  const PmoMainScreen({super.key});

  @override
  State<PmoMainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<PmoMainScreen> {
  int _selectedIndex = 0;
  String? nickName; // untuk menyimpan nama dari Firestore
  String? fullName; // untuk menyimpan nama dari Firestore
  String? uniqueId; // untuk menyimpan nama dari Firestore
  String? role; // untuk menyimpan nama dari Firestore
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // final List<Widget> _pages = [
  //   const JadwalPage(),
  //   const RiwayatPage(),
  //   const AkunPage(),
  // ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          nickName = data?['nickName'] ?? "Pengguna";
          fullName = data?['fullName'] ?? ""; // <-- Tambahkan ini
          role = data?['role'] ?? ""; // <-- Tambahkan ini
          uniqueId = data?['uniqueId']; // <-- Tambahkan ini
          isLoading = false;
        });
      } else {
        setState(() {
          nickName = "Pengguna";
          fullName = ""; // <-- Default kosong kalau belum ada
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        nickName = "Pengguna";
        fullName = "";
        isLoading = false;
      });
      debugPrint("Error load data user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 🔹 Di sini kita kirim nickName ke setiap halaman
    final pages = [
      PmoJadwalPage(nickName: nickName ?? "Pengguna"),
      // PasienList(),
      PasienList(),
      AkunPage(
        fullName: fullName ?? "Pengguna",
        uniqueId: uniqueId!,
        role: role!,
      ),
    ];
    return Scaffold(
      // Halaman ditampilkan bergantian tanpa kehilangan state
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/jadwal.svg',
              height: 24,
              color: _selectedIndex == 0 ? kPrimaryGreen : Colors.grey,
            ),
            label: "Jadwal",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/riwayat.svg',
              height: 24,
              color: _selectedIndex == 1 ? kPrimaryGreen : Colors.grey,
            ),
            label: "Pasien",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/akun.svg',
              height: 24,
              color: _selectedIndex == 2 ? kPrimaryGreen : Colors.grey,
            ),
            label: "Akun",
          ),
        ],
      ),
    );
  }
}
