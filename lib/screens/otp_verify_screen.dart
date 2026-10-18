import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final TextEditingController _otpController =
  TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  // ============================================================
  // OTP VERIFY
  // ============================================================

  Future<void> verifyOtp() async {
    if (_loading) return;

    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("कृपया 6 digit OTP दर्ज करें।"),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final credential =
      PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      // Firebase login
      await FirebaseAuth.instance
          .signInWithCredential(credential);

      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception(
          "Firebase user नहीं मिला।",
        );
      }

      // ========================================================
      // EXISTING PROFILE CHECK
      // ========================================================

      final profileDoc =
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .get();

      print("LOGIN UID = ${user.uid}");
      print("PROFILE EXISTS = ${profileDoc.exists}");
      if (!mounted) return;

      // ========================================================
      // PROFILE ALREADY EXISTS
      // ========================================================

      if (profileDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Welcome back! आपकी profile पहले से मौजूद है।",
            ),
          ),
        );

        // Existing user को Profile दोबारा नहीं भरना है।
        Navigator.pushReplacementNamed(
          context,
          '/matches',
        );

        return;
      }

      // ========================================================
      // NEW USER
      // ========================================================

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "OTP Verified Successfully",
          ),
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        '/profile',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ??
                "OTP Verification Failed",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "कुछ समस्या हुई: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "OTP Verification",
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

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
              keyboardType:
              TextInputType.number,
              maxLength: 6,

              decoration:
              const InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                "Enter 6 Digit OTP",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed:
                _loading ? null : verifyOtp,

                child: _loading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
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