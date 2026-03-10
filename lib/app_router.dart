import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:tbmate_kmipn/auth/signup_page.dart';
import 'package:tbmate_kmipn/auth/login_page.dart';
import 'package:tbmate_kmipn/pages/beratbadan.dart';
import 'package:tbmate_kmipn/pages/input_role.dart';
import 'package:tbmate_kmipn/pages/inputname.dart';
import 'package:tbmate_kmipn/pages/inputusia.dart';
import 'package:tbmate_kmipn/pages/jadwal_page.dart';
import 'package:tbmate_kmipn/pages/main_screen.dart';
import 'package:tbmate_kmipn/pages/screen1.dart';
import 'package:tbmate_kmipn/pages/settime.dart';
import 'package:tbmate_kmipn/pages/splash_screen.dart';
import 'package:tbmate_kmipn/pages/telpscreen.dart';
import 'package:tbmate_kmipn/auth/auth_page.dart';
import 'package:tbmate_kmipn/pages/welcome_page.dart';
import 'package:tbmate_kmipn/pmo/pmo_main_screen.dart';
import 'package:tbmate_kmipn/pages/akun_page.dart';

final GoRouter appRouter = GoRouter(initialLocation: '/', routes: [
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
  GoRoute(
    path: '/input-phone',
    name: 'input-phone',
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: const InputPhoneScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // dari kanan
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    ),
  ),
  GoRoute(
    path: '/input-name',
    name: 'input-name',
    builder: (context, state) => const NameInputScreen(),
  ),
  GoRoute(
    path: '/input-role',
    name: 'input-role',
    builder: (context, state) => const RoleGroupSelectionScreen(),
  ),
  GoRoute(
    path: '/welcome',
    name: 'welcome',
    builder: (context, state) {
      final data = state.extra as Map<String, String>;
      final nickName = data['nickName'] ?? '';
      return WelcomePage(nickName: nickName);
    },
  ),
  GoRoute(
      path: '/input-usia',
      name: 'input-usia',
      builder: (context, state) {
        return const AgeGroupSelectionScreen();
      }),
  GoRoute(
      path: '/input-weight',
      name: 'input-weight',
      builder: (context, state) {
        return const WeightSelectionScreen();
      }),
  GoRoute(
      path: '/main-screen',
      name: 'main-screen',
      builder: (context, state) {
        return const MainScreen();
      }),
  GoRoute(
      path: '/pmo-main-screen',
      name: 'pmo-main-screen',
      builder: (context, state) {
        return const PmoMainScreen();
      }),
  GoRoute(
      path: '/set-time',
      name: 'set-time',
      builder: (context, state) {
        return const SetWaktu();
      }),
  GoRoute(
    path: '/akun',
    name: 'akun',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return AkunPage(
        fullName: extra?['fullName']?? '',
        uniqueId: extra?['uniqueId']?? '',
        role: extra?['role']?? '',
      );
    },
  )
]);
