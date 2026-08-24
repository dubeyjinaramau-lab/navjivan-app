import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class OtpVerifyScreen extends StatefulWidget {
  final String verificationId;

  const OtpVerifyScreen({
    super.key,
    required this.verificationId,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
  Future<void> verifyOtp() async {

    try {

      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP Verified Successfully"),
        ),
      );

      Navigator.pushReplacementNamed(context, '/profile');

    } on FirebaseAuthException catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? "OTP Verification Failed",
          ),
        ),
      );

    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OTP Verification"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.verified_user,
              size: 80,
              color: Colors.green,
            ),

            const SizedBox(height: 25),

            const Text(
              "Enter OTP",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "OTP आपके मोबाइल नंबर पर भेजा गया है",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter 6 Digit OTP",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: verifyOtp,

                child: const Text(
                  "Verify OTP",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),

            ),
          ],
        ),
      ),
    );
  }
}