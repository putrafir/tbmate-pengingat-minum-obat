import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;
  bool isNext = true;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/images/Group 162.png',
      'title': 'Hai, Aku TiBi yang akan\nmenemani kamu sampai sembuh',
      'subtitle':
          'Ayo sembuh bersama TBMATE! Teman digital Anda untuk membantu pengobatan TBC lebih mudah teratur, dan menyenangkan',
    },
    {
      'image': 'assets/images/Group 163.png',
      'title': 'Jangan khawatir lupa minum obat,\nkami selalu mengingatkan',
      'subtitle':
          'Notifikasi otomatis untuk memastikan Anda tidak pernah melewatkan obat',
    },
    {
      'image': 'assets/images/Group 167.png',
      'title': 'Dapatkan dukungan langsung dari dokter dengan Halodoc',
      'subtitle':
          'Terhubung langsung dengan Halodoc untuk mendapatkan jawaban cepat dari tenaga medis',
    },
    {
      'image': 'assets/images/Group 170.png',
      'title': 'AI memastikan Anda tetap disiplin, tanpa repot',
      'subtitle':
          'Teknologi cerdas memastikan kepatuhan minum obat tanpa repot',
    },
  ];

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color backgroundColor = Color(0xFFF8FFF5);

  // void nextPage() {
  //   if (currentIndex < onboardingData.length - 1) {
  //     setState(() {
  //       isNext = true;
  //       currentIndex++;
  //     });
  //   } else {
  //     // TODO: arahkan ke halaman utama / login
  //     print("Navigasi ke halaman utama");
  //   }
  // }

  void nextPage(BuildContext context) {
    if (currentIndex < onboardingData.length - 1) {
      setState(() {
        isNext = true;
        currentIndex++;
      });
    } else {
      context.go('/input-name');
    }
  }

  void prevPage() {
    if (currentIndex > 0) {
      setState(() {
        isNext = false;
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = onboardingData[currentIndex];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: currentIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: prevPage,
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                flex: 5,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: Offset(isNext ? 1.0 : -1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ));
                    return SlideTransition(
                        position: offsetAnimation, child: child);
                  },
                  child: Image.asset(
                    data['image']!,
                    key: ValueKey<String>(data['image']!),
                    width: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingData.length,
                  (index) => _Dot(
                    isActive: index == currentIndex,
                    color: primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  final offsetAnimation = Tween<Offset>(
                    begin: Offset(isNext ? 1.0 : -1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  ));
                  return SlideTransition(
                      position: offsetAnimation, child: child);
                },
                child: Column(
                  key: ValueKey<String>(data['title']!),
                  children: [
                    Text(
                      data['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: primaryGreen,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data['subtitle']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => nextPage(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    currentIndex == onboardingData.length - 1
                        ? "Mulai"
                        : "Lanjut",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isActive;
  final Color color;

  const _Dot({required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6.0,
      width: isActive ? 24.0 : 6.0,
      decoration: BoxDecoration(
        color: isActive ? color : color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
