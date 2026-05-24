import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tbmate_kmipn/auth/signup_page.dart';
import 'package:tbmate_kmipn/auth/login_page.dart';
import 'package:tbmate_kmipn/auth/auth_page.dart';
import 'package:tbmate_kmipn/pages/pasien/camera_ingestion_page.dart';
import 'package:tbmate_kmipn/pages/pasien/detail_riwayat.dart';
import 'package:tbmate_kmipn/pages/pasien/main_screen.dart';
import 'package:tbmate_kmipn/pages/screen1.dart'; // OnboardingScreen
import 'package:tbmate_kmipn/pages/splash_screen.dart';
import 'package:tbmate_kmipn/pages/pmo/pmo_main_screen.dart';
import 'package:tbmate_kmipn/pages/pasien/profile/akun_page.dart';
import 'package:tbmate_kmipn/main.dart';
import 'package:tbmate_kmipn/pages/pmo/tambah_pasien.dart';
import 'package:tbmate_kmipn/pages/pasien/profile/akunpagenew.dart';

// 🔹 IMPORT WIZARD BARU KITA
import 'package:tbmate_kmipn/pages/registration/registration_wizard.dart';

final GoRouter appRouter = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;

      // ✅ BIAR SPLASH NGGAK DI-GANGGU
      if (state.matchedLocation == '/') {
        return null;
      }

      final isAuthRoute = state.matchedLocation == '/auth' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (user == null && !isAuthRoute) {
        return '/auth';
      }

      if (user != null && isAuthRoute) {
        return '/main-screen';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
          path: '/auth',
          name: 'auth',
          builder: (context, state) => const AuthPage()),
      GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignUp()),
      GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const Loginpage()),
      GoRoute(
          path: '/screen1',
          name: 'screen1',
          builder: (context, state) => const OnboardingScreen()),

      // ==============================================================
      // 🔥 SATU RUTE UNTUK MENGGANTIKAN 6 RUTE PENDAFTARAN LAMA
      // ==============================================================
      GoRoute(
        path: '/registration-wizard',
        name: 'registration-wizard',
        builder: (context, state) => const RegistrationWizard(),
      ),

      GoRoute(
        path: '/main-screen',
        name: 'main-screen',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          return MainScreen(
            showPopup: extra?['showPopup'] ?? false,
            docId: extra?['docId'],
          );
        },
      ),
      GoRoute(
          path: '/pmo-main-screen',
          name: 'pmo-main-screen',
          builder: (context, state) {
            return const PmoMainScreen();
          }),
      GoRoute(
        path: '/akun',
        name: 'akun',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AkunPageRev(
            fullName: extra?['fullName'] ?? '',
            uniqueId: extra?['uniqueId'] ?? '',
            role: extra?['role'] ?? '',
            patientUid: extra?['patientUid'],
          );
        },
      ),
      GoRoute(
        path: '/detail-riwayat',
        name: 'detail-riwayat',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;

          return DetailRiwayat(
            namaObat: data['namaObat'],
            dosis: data['dosis'],
            fase: data['fase'],
            status: data['status'],
            waktu: data['waktu'],
            tanggal: data['tanggal'],
            verifikasiAi: data['verifikasiAi'],
            skorAi: data['skorAi']?.toDouble(),
            waktuVerifikasi: data['waktuVerifikasi'],
            riwayatTunda: data['riwayatTunda'] ?? [],
            // 👇 Ganti parameter buktiFoto lama dengan path ini
            jadwalDocPath: data['jadwalDocPath'],
          );
        },
      ),
      GoRoute(
        path: '/camera',
        name: 'camera',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return CameraIngestionPage(
            jadwalDocRef: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('jadwal_obat')
                .doc(data['docId']),
            namaObat: 'Obat', // bisa kamu ambil dari firestore nanti
          );
        },
      ),
      GoRoute(
        path: '/tambah-pasien-baru',
        builder: (context, state) => const CreatePatientAccountPage(),
      ),
    ]);
