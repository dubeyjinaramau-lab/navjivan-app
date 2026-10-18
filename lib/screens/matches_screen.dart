
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  String selectedReligion = 'All (सभी)';
  String selectedCaste = 'All (सभी)';

  final List<String> religions = [
    'All (सभी)',
    'Hindu (सनातन / हिंदू)',
    'Sikh',
    'Jain',
    'Buddhist',
  ];

  final List<String> castes = [
    'All (सभी)',
    'Brahman',
    'Rajput',
    'Baniya',
    'Yadav',
    'Maurya',
    'Jat',
    'Caste No Bar (जाति बंधन नहीं)',
  ];

  // Current user's gender
  String? _currentUserGender;
  bool _loadingGender = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserGender();
  }

  // ============================================================
  // CURRENT USER का GENDER FIRESTORE से पढ़ना
  // ============================================================

  Future<void> _loadCurrentUserGender() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _loadingGender = false;
        });

        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data();

        setState(() {
          _currentUserGender = data?['gender']?.toString();
          _loadingGender = false;
        });
      } else {
        setState(() {
          _currentUserGender = null;
          _loadingGender = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingGender = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Profile information पढ़ने में समस्या: $e",
          ),
        ),
      );
    }
  }

  // ============================================================
  // OPPOSITE GENDER
  // ============================================================

  String? get _oppositeGender {
    if (_currentUserGender == 'Male') {
      return 'Female';
    }

    if (_currentUserGender == 'Female') {
      return 'Male';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Gender अभी load हो रहा है
    if (_loadingGender) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.deepPurple,
          ),
        ),
      );
    }

    // Gender नहीं मिला
    if (_oppositeGender == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Navjivan Matches',
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "कृपया पहले अपनी प्रोफ़ाइल में Gender चुनें।",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      );
    }

    // ==========================================================
    // PROFILE QUERY
    // ==========================================================

    Query query = FirebaseFirestore.instance
        .collection('profiles')
        .where(
      'gender',
      isEqualTo: _oppositeGender,
    );

    if (selectedReligion != 'All (सभी)') {
      query = query.where(
        'religion',
        isEqualTo: selectedReligion,
      );
    }

    if (selectedCaste != 'All (सभी)') {
      query = query.where(
        'caste',
        isEqualTo: selectedCaste,
      );
    }

    query = query.orderBy(
      'createdAt',
      descending: true,
    );

    // ==========================================================
    // SCREEN
    // ==========================================================

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Navjivan Matches',
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ====================================================
          // FILTERS
          // ====================================================

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            color: Colors.deepPurple.shade50,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedReligion,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: "धर्म चुनें",
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  items: religions.map((val) {
                    return DropdownMenuItem(
                      value: val,
                      child: Text(
                        val,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedReligion = val ?? 'All (सभी)';
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCaste,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: "जाति चुनें",
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  items: castes.map((val) {
                    return DropdownMenuItem(
                      value: val,
                      child: Text(
                        val,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedCaste = val ?? 'All (सभी)';
                    });
                  },
                ),
              ],
            ),
          ),

          // ====================================================
          // MATCHES
          // ====================================================

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Profiles load करने में समस्या हुई।\n\n"
                            "${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "इस कैटेगरी में अभी कोई profile नहीं है।\n"
                          "कृपया दूसरा फ़िल्टर चुनकर देखें!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data()
                    as Map<String, dynamic>;

                    final String name =
                        data['fullName'] ?? 'User';

                    final String status =
                        data['maritalStatus'] ?? '';

                    final String caste =
                        data['caste'] ?? '';

                    final String gotra =
                        data['gotra'] ?? '';

                    // पहली प्रोफ़ाइल फोटो का URL
                    final String photoUrl =
                    (data['profilePhotoUrl'] ?? '')
                        .toString()
                        .trim();

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // ==================================
                            // PROFILE HEADER
                            // ==================================

                            Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: photoUrl.isNotEmpty
                                        ? Image.network(
                                      photoUrl,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                          ) {
                                        return const Icon(
                                          Icons.person,
                                          color: Colors.deepPurple,
                                          size: 40,
                                        );
                                      },
                                    )
                                        : const Icon(
                                      Icons.person,
                                      color: Colors.deepPurple,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "$status | $caste",
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (gotra.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          "गोत्र: $gotra",
                                          style: const TextStyle(
                                            color: Colors.deepPurple,
                                            fontSize: 13,
                                            fontWeight:
                                            FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ==================================
                            // ACTION BUTTONS
                            // ==================================

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(
                                    Icons.favorite_border,
                                    size: 18,
                                  ),
                                  label: const Text("पसंद करें"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                    Colors.deepPurple,
                                    side: const BorderSide(
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'रुचि (Interest) '
                                              'सफलतापूर्वक भेजी गई!',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.chat_bubble_outline,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Chat करें",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    Colors.deepPurple,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChatScreen(
                                              partnerName: name,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
