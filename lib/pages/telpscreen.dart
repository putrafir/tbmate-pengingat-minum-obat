import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tbmate_kmipn/pages/verivikasitelp.dart'; // pastikan ini benar mengarah ke file verify.dart

class InputPhoneScreen extends StatefulWidget {
  const InputPhoneScreen({super.key});

  @override
  State<InputPhoneScreen> createState() => _InputPhoneScreenState();
}

class _InputPhoneScreenState extends State<InputPhoneScreen> {
  final TextEditingController phoneController = TextEditingController();
  String countryCode = '+62';
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    phoneController.addListener(_formatPhoneNumber);
  }

  void _formatPhoneNumber() {
    String digits = phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    String formatted = '';

    if (digits.length <= 3) {
      formatted = digits;
    } else if (digits.length <= 7) {
      formatted = '${digits.substring(0, 3)}-${digits.substring(3)}';
    } else if (digits.length <= 11) {
      formatted =
          '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    } else {
      formatted =
          '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7, 11)}';
    }

    if (formatted != phoneController.text) {
      phoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final List<Map<String, String>> countryCodes = [
          {'code': '+62', 'country': 'Indonesia'},
          {'code': '+1', 'country': 'USA'},
          {'code': '+44', 'country': 'UK'},
          {'code': '+81', 'country': 'Japan'},
          {'code': '+91', 'country': 'India'},
        ];

        return ListView(
          children: countryCodes.map((item) {
            return ListTile(
              title: Text('${item['country']} (${item['code']})'),
              onTap: () {
                setState(() => countryCode = item['code']!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showError(String message) {
    setState(() => errorMessage = message);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => errorMessage = null);
      }
    });
  }

  void _validateAndSubmit() {
    final phone = phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.isEmpty) {
      _showError("Masukkan telepon anda terlebih dahulu");
      return;
    } else if (phone.length < 10) {
      _showError("Nomor telepon tidak valid");
      return;
    }

    final fullNumber = '$countryCode ${phoneController.text}';
    print("Nomor telepon: $fullNumber");

    // Navigasi ke halaman VerifyCodeScreen dengan animasi ke kanan
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // dari kanan ke kiri
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      pageBuilder: (context, animation, secondaryAnimation) =>
          VerifyCodeScreen(phoneNumber: fullNumber),
    ));
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFF5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    border: Border.all(color: Colors.orange, width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.close, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Image.asset(
                'assets/images/telp.png',
                width: 400,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              const Text(
                "Masuk menggunakan\nnomor telepon Anda",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: primaryGreen,
                  height: 1,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: errorMessage != null ? Colors.red : Colors.grey,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: _showCountryPicker,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          countryCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const Text("|", style: TextStyle(color: Colors.grey, fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF80D8FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Masuk",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
