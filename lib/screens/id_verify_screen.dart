import 'package:flutter/material.dart';

class IdVerifyScreen extends StatefulWidget {
  const IdVerifyScreen({super.key});

  @override
  State<IdVerifyScreen> createState() => _IdVerifyScreenState();
}

class _IdVerifyScreenState extends State<IdVerifyScreen> {
  bool _isUploading = false;

  void _verifyAndProceed() {
    setState(() {
      _isUploading = true;
    });

    // आईडी वेरिफिकेशन सिमुलेशन
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        // वेरिफिकेशन के बाद मैच स्क्रीन पर भेजें
        Navigator.pushReplacementNamed(context, '/matches');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('पहचान का सत्यापन (ID Verification)'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.verified_user,
              size: 80,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 20),
            const Text(
              "सुरक्षा और विश्वास के लिए ID अपलोड करें",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "आधार कार्ड / वोटर आईडी का फोटो अपलोड करें ताकि आपकी प्रोफाइल सत्यापित हो सके।",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('आईडी डॉक्यूमेंट चुना गया!')),
                );
              },
              icon: const Icon(Icons.upload_file),
              label: const Text("आईडी अपलोड करें"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _verifyAndProceed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "सत्यापित करें और आगे बढ़ें",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}