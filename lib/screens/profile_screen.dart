import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_details.dart';
import '../terms_conditions.dart';
import '../privacy_policy.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedGotra;
  String? _selectedReligion;
  String? _selectedCaste;
  String? _selectedState;
  String? _selectedCity;
  String? _selectedChildren;
  String? _selectedChildrenResponsibility;

  bool _acceptedTerms = false;
  final _aboutController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _cityController = TextEditingController();
  final _gotraController = TextEditingController();
  final _otherStateController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _otherCityController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final _heightController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _birthTimeController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _otherChildrenResponsibilityController =
  TextEditingController();
  XFile? _selectedImage;

  // **********************************************
  // Religion List
  // **********************************************


  // **********************************************
  // मोबाइल से फोटो चुनना
  // **********************************************

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("फोटो चुनने में समस्या: $e"),
        ),
      );
    }
  }

  // **********************************************
  // Profile Save करना
  // **********************************************

  Future<void> _saveProfile() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'कृपया Terms & Conditions और Privacy Policy स्वीकार करें।',
          ),
        ),
      );
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("कृपया अपना नाम दर्ज करें।"),
        ),
      );
      return;
    }

    if (_selectedReligion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("कृपया अपना धर्म चुनें।"),
        ),
      );
      return;
    }

    if (_selectedCaste == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("कृपया अपनी जाति चुनें।"),
        ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      await _firestore
          .collection('profiles')
          .doc(user.uid)
          .set({
        'fullName': _nameController.text.trim(),
        'age': _ageController.text.trim(),
        'birthYear': _birthYearController.text.trim(),
        'city': _selectedCity == 'Other'
            ? _otherCityController.text.trim()
            : _selectedCity ?? '',
        'state': _selectedState == 'Other'
            ? _otherStateController.text.trim()
            : _selectedState ?? '',
        'gender': _selectedGender,
        'maritalStatus': _selectedMaritalStatus,
        'about': _aboutController.text.trim(),
        'privateDetails': {
          'mobile': _mobileController.text.trim(),
          'email': _emailController.text.trim(),
          'birthDate': _birthDateController.text.trim(),
          'birthTime': _birthTimeController.text.trim(),
          'birthPlace': _birthPlaceController.text.trim(),
        },
        'religion': _selectedReligion ?? '',
        'caste': _selectedCaste ?? '',
        'gotra': _selectedGotra ?? '',
        'children': _selectedChildren ?? '',
        'childrenResponsibility': _selectedChildren == 'हाँ'
            ? (_selectedChildrenResponsibility == 'अन्य'
            ? _otherChildrenResponsibilityController.text.trim()
            : _selectedChildrenResponsibility ?? '')
            : '',
        'createdAt': FieldValue.serverTimestamp(),
        'photoSelected': _selectedImage != null,
      });
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('प्रोफ़ाइल सेव हो गई है!'),
        ),
      );

      Navigator.pushReplacementNamed(context, '/id_verify');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("प्रोफ़ाइल सेव करने में समस्या: $e"),
        ),
      );
    }
  }

  // **********************************************
  // Memory साफ करना
  // **********************************************

  @override
  void dispose() {
    _aboutController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    _gotraController.dispose();
    _otherStateController.dispose();
    _otherCityController.dispose();
    _heightController.dispose();
    _birthYearController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _birthTimeController.dispose();
    _birthPlaceController.dispose();
    _otherChildrenResponsibilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('अपनी प्रोफ़ाइल बनाएं'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),

        child: Column(
          children: [
            const SizedBox(height: 20),

            // **********************************************
            // फोटो
            // **********************************************

            GestureDetector(
              onTap: _pickImage,

              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.deepPurple,

                backgroundImage: _selectedImage != null
                    ? NetworkImage(_selectedImage!.path)
                    : null,

                child: _selectedImage == null
                    ? const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                )
                    : null,
              ),
            ),

            const SizedBox(height: 10),

            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text("फोटो चुनें"),
            ),

            const Text(
              "स्पष्ट एवं वास्तविक फोटो लगाने से विश्वास बढ़ता है।",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 25),

            // **********************************************
            // नाम
            // **********************************************

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'पूरा नाम',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // **********************************************
            // Gender
            // **********************************************

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "लिंग (Gender)",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Male",
                  child: Text("पुरुष"),
                ),
                DropdownMenuItem(
                  value: "Female",
                  child: Text("महिला"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // **********************************************
            // उम्र
            // **********************************************

            TextField(
              controller: _birthYearController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'जन्म वर्ष (Birth Year)',
                hintText: 'जैसे 1985',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
// **********************************************
// Private Contact Details
// **********************************************

            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'मोबाइल नंबर 🔒',
                hintText: 'यह जानकारी सार्वजनिक नहीं होगी',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email 🔒 (वैकल्पिक)',
                hintText: 'यह जानकारी सार्वजनिक नहीं होगी',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // **********************************************
// Private Birth Details
// **********************************************

            TextField(
              controller: _birthDateController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'जन्म तिथि 🔒',
                hintText: 'DD/MM/YYYY',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _birthTimeController,
              decoration: const InputDecoration(
                labelText: 'जन्म समय 🔒',
                hintText: 'जैसे 10:30 AM',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _birthPlaceController,
              decoration: const InputDecoration(
                labelText: 'जन्म स्थान 🔒',
                hintText: 'जन्म स्थान लिखें',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'लंबाई (Height in cm)',
                hintText: 'जैसे 170',
                labelStyle: const TextStyle(
                  color: Colors.deepPurple,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Colors.deepPurple,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Colors.deepPurple,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            // **********************************************
            // शहर
            // **********************************************
            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(
                labelText: "City",
                border: OutlineInputBorder(),
              ),
              items: ProfileDetails.cities.map((city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCity = value;
                });
              },
            ),

            if (_selectedCity == 'Other') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _otherCityController,
                decoration: const InputDecoration(
                  labelText: 'अपना शहर लिखें',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
           // **********************************************
// State
// **********************************************

            DropdownButtonFormField<String>(
              value: _selectedState,
              decoration: const InputDecoration(
                labelText: "State",
                border: OutlineInputBorder(),
              ),
              items: ProfileDetails.states.map((state) {
                return DropdownMenuItem<String>(
                  value: state,
                  child: Text(state),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedState = value;
                });
              },
            ),

            if (_selectedState == 'Other') ...[
              const SizedBox(height: 16),

              TextField(
                controller: _otherStateController,
                decoration: const InputDecoration(
                  labelText: 'अपना State लिखें',
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 16),
            const SizedBox(height: 16),

            // **********************************************
            // Religion
            // **********************************************

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "धर्म (Religion)",
                border: OutlineInputBorder(),
              ),
              items: ProfileDetails.religions.map((religion) {
                return DropdownMenuItem(
                  value: religion,
                  child: Text(religion),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReligion = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // **********************************************
            // Caste
            // **********************************************

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "जाति (Caste)",
                border: OutlineInputBorder(),
              ),
              items: ProfileDetails.castes.map((caste) {
                return DropdownMenuItem(
                  value: caste,
                  child: Text(caste),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCaste = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // **********************************************
            // Gotra
            // **********************************************

            DropdownButtonFormField<String>(
              value: _selectedGotra,
              decoration: const InputDecoration(
                labelText: "गोत्र (Gotra)",
                border: OutlineInputBorder(),
              ),
              items: ProfileDetails.gotras.map((gotra) {
                return DropdownMenuItem<String>(
                  value: gotra,
                  child: Text(gotra),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGotra = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // **********************************************
// बच्चों की जानकारी
// **********************************************

            DropdownButtonFormField<String>(
              value: _selectedChildren,
              decoration: const InputDecoration(
                labelText: 'क्या आपके बच्चे हैं?',
                border: OutlineInputBorder(),
              ),
              items: ProfileDetails.childrenOptions.map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedChildren = value;

                  if (value == 'नहीं') {
                    _selectedChildrenResponsibility = null;
                    _otherChildrenResponsibilityController.clear();
                  }
                });
              },
            ),

            const SizedBox(height: 16),

            if (_selectedChildren == 'हाँ') ...[
              DropdownButtonFormField<String>(
                value: _selectedChildrenResponsibility,
                decoration: const InputDecoration(
                  labelText: 'बच्चों की जिम्मेदारी',
                  border: OutlineInputBorder(),
                ),
                items: ProfileDetails.childrenResponsibilityOptions.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedChildrenResponsibility = value;
                  });
                },
              ),

              if (_selectedChildrenResponsibility == 'अन्य') ...[
                const SizedBox(height: 16),

                TextField(
                  controller: _otherChildrenResponsibilityController,
                  decoration: const InputDecoration(
                    labelText: 'जिम्मेदारी के बारे में लिखें',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],

            const SizedBox(height: 16),

            // **********************************************
            // वैवाहिक स्थिति
            // **********************************************

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "वैवाहिक स्थिति (Marital Status)",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Divorce",
                  child: Text("तलाकशुदा"),
                ),
                DropdownMenuItem(
                  value: "Widow",
                  child: Text("विधवा"),
                ),
                DropdownMenuItem(
                  value: "Widower",
                  child: Text("विधुर"),
                ),
                DropdownMenuItem(
                  value: "Never Married",
                  child: Text("अविवाहित"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMaritalStatus = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // **********************************************
            // अपने बारे में
            // **********************************************

            TextField(
              controller: _aboutController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "अपने बारे में",
                hintText: "अपने बारे में कुछ लिखें (वैकल्पिक)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            CheckboxListTile(
              value: _acceptedTerms,
              onChanged: (value) {
                setState(() {
                  _acceptedTerms = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              title: Wrap(
                children: [
                  const Text('मैं '),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsConditionsPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  const Text(' और '),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  const Text(' स्वीकार करता/करती हूँ।'),
                ],
              ),
            ),
            // **********************************************
            // Save Button
            // **********************************************

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: _saveProfile,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),

                child: const Text(
                  'सेव करें और आगे बढ़ें',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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