import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // डेटाबेस लाइब्रेरी
import 'package:firebase_auth/firebase_auth.dart';
import 'otp_verify_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

String? _verificationId;

// नीचे Functions शुरू होंगे

  Future<void> _sendOtp() async {
    String phone = _phoneController.text.trim();

   
    setState(() {
      _isLoading = true;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: "+91$phone",

      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },

      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? "OTP भेजने में त्रुटि")),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {

        _verificationId = verificationId;

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP भेज दिया गया"),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerifyScreen(
              verificationId: verificationId,
            ),
          ),
        );

      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- इंटरनेट डेटाबेस में नंबर सेव करने का फंक्शन ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "नवजीवन",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              const Text(
                "जहाँ जिंदगी दोबारा मुस्कुराती है",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 48),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: "अपना Mobile Number डालें",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "ओटीपी प्राप्त करें / आगे बढ़ें",
                    style: TextStyle(color: Colors.white, fontSize: 16),
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