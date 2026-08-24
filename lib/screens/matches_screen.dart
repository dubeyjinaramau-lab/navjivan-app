import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  String selectedReligion = 'All (सभी)';
  String selectedCaste = 'All (सभी)';

  final List<String> religions = ['All (सभी)', 'Hindu (सनातन / हिंदू)', 'Sikh', 'Jain', 'Buddhist'];
  final List<String> castes = ['All (सभी)', 'Brahman', 'Rajput', 'Baniya', 'Yadav', 'Maurya', 'Jat', 'Caste No Bar (जाति बंधन नहीं)'];

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection('profiles');

    if (selectedReligion != 'All (सभी)') {
      query = query.where('religion', isEqualTo: selectedReligion);
    }
    if (selectedCaste != 'All (सभी)') {
      query = query.where('caste', isEqualTo: selectedCaste);
    }

    query = query.orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navjivan Matches', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: Colors.deepPurple.shade50,
            child:
            Column(
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "इस कैटेगरी में अभी कोई प्रोफाइल नहीं है।\nकृपया दूसरा फ़िल्टर चुनकर देखें!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    String name = data['fullName'] ?? 'User';
                    String status = data['maritalStatus'] ?? '';
                    String caste = data['caste'] ?? '';

                    String gotra = data['gotra'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(color: Colors.deepPurple.shade50, shape: BoxShape.circle),
                                  child: const ClipOval(
                                    child: Icon(Icons.person, color: Colors.deepPurple, size: 40),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                                      const SizedBox(height: 4),
                                      Text("$status | $caste", style: const TextStyle(color: Colors.black54, fontSize: 14)),
                                      if (gotra.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text("गोत्र: $gotra", style: const TextStyle(color: Colors.deepPurple, fontSize: 13, fontWeight: FontWeight.w500)),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.favorite_border, size: 18),
                                  label: const Text("पसंद करें"),
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.deepPurple, side: const BorderSide(color: Colors.deepPurple)),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('रुचि (Interest) सफलतापूर्वक भेजी गई!')),
                                    );
                                  },
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
                                  label: const Text("Chat करें", style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(partnerName: name),
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
