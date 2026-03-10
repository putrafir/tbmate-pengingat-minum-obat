import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tbmate_kmipn/color.dart';
import 'package:go_router/go_router.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String phoneNumber;

  const VerifyCodeScreen({super.key, required this.phoneNumber});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String? verificationId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _verifyPhone();
  }

  Future<void> _verifyPhone() async {
    setState(() => isLoading = true);

    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber.replaceAll(' ', ''),
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // ✅ Auto-verifikasi langsung login
        await _auth.signInWithCredential(credential);
        context.go('/input-name');
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal verifikasi: ${e.message}')),
        );
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          isLoading = false;
        });
        print("✅ Verification ID dikirim: $verId");
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
        setState(() => isLoading = false);
      },
    );
  }

  void _onInputChanged(String value, int index, BuildContext context) {
    if (value.isNotEmpty && index < _controllers.length - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  Future<void> _verifyCode() async {
    if (verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode verifikasi belum dikirim')),
      );
      return;
    }

    final otpCode = _controllers.map((c) => c.text).join();

    if (otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode OTP harus 6 digit')),
      );
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otpCode,
      );
      await _auth.signInWithCredential(credential);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil verifikasi!')),
      );

      context.go('/input-name');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode OTP salah atau kadaluarsa')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/icon1.png',
                width: 300,
              ),
              const SizedBox(height: 30),
              const Text(
                "Masukkan Kode Unik Yang Kami Kirim",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kPrimaryGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Silahkan periksa SMS kamu dan masukkan kode yang kami kirim ke ${widget.phoneNumber}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kSubtitleColor,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 30),

              // OTP Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    width: 45,
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: kInputBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: kInputShadow.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      autofocus: index == 0,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryGreen,
                      ),
                      decoration: const InputDecoration(
                        counterText: "",
                        border: InputBorder.none,
                      ),
                      onChanged: (value) =>
                          _onInputChanged(value, index, context),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: isLoading ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLoading ? Colors.grey : kPrimaryGreen,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Verifikasi",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Tidak menerima SMS? ",
                    style: TextStyle(color: kSubtitleColor, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: _verifyPhone,
                    child: const Text(
                      "Kirim ulang",
                      style: TextStyle(
                        color: kLinkBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
