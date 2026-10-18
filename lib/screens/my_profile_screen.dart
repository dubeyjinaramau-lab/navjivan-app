import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
static const green = Color(0xFF81C784);
static const darkGreen = Color(0xFF388E3C);

final ImagePicker _picker = ImagePicker();
bool _photoBusy = false;

DocumentReference<Map<String, dynamic>>? get _profileRef {
final user = FirebaseAuth.instance.currentUser;
if (user == null) return null;

return FirebaseFirestore.instance
.collection('profiles')
.doc(user.uid);
}

List<String> _getPhotoUrls(Map<String, dynamic> data) {
final result = List<String>.filled(4, '');

final savedPhotos = data['profilePhotoUrls'];
if (savedPhotos is List) {
for (int i = 0; i < 4 && i < savedPhotos.length; i++) {
result[i] = savedPhotos[i]?.toString() ?? '';
}
}

if (result[0].isEmpty) {
result[0] = data['profilePhotoUrl']?.toString() ?? '';
}

return result;
}

String _photoFileName(int index) {
if (index == 0) return 'profile.jpg';
return 'photo_${index + 1}.jpg';
}

Future<void> _showPhotoOptions(
int index,
String currentUrl,
) async {
if (_photoBusy) return;

await showModalBottomSheet<void>(
context: context,
builder: (sheetContext) => SafeArea(
child: Wrap(
children: [
ListTile(
leading: const Icon(Icons.photo_library),
title: const Text('Gallery से फोटो चुनें'),
onTap: () {
Navigator.pop(sheetContext);
_pickAndUploadPhoto(index, ImageSource.gallery);
},
),
ListTile(
leading: const Icon(Icons.camera_alt),
title: const Text('Camera से फोटो लें'),
onTap: () {
Navigator.pop(sheetContext);
_pickAndUploadPhoto(index, ImageSource.camera);
},
),
if (currentUrl.isNotEmpty)
ListTile(
leading: const Icon(Icons.delete, color: Colors.red),
title: const Text(
'फोटो हटाएँ',
style: TextStyle(color: Colors.red),
),
onTap: () {
Navigator.pop(sheetContext);
_deletePhoto(index);
},
),
],
),
),
);
}

Future<void> _pickAndUploadPhoto(
int index,
ImageSource source,
) async {
final user = FirebaseAuth.instance.currentUser;
final profileRef = _profileRef;

if (user == null || profileRef == null || _photoBusy) return;

try {
final XFile? pickedFile = await _picker.pickImage(
source: source,
imageQuality: 80,
maxWidth: 1200,
);

if (pickedFile == null) return;

final file = File(pickedFile.path);

if (await file.length() > 5 * 1024 * 1024) {
if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('फोटो 5 MB से छोटी होनी चाहिए।'),
),
);
return;
}

setState(() => _photoBusy = true);

final fileName = _photoFileName(index);
final storageRef = FirebaseStorage.instance
.ref()
.child('profile_photos')
.child(user.uid)
.child(fileName);

await storageRef.putFile(
file,
SettableMetadata(contentType: 'image/jpeg'),
);

final downloadUrl = await storageRef.getDownloadURL();

final snapshot = await profileRef.get();
final data = snapshot.data() ?? <String, dynamic>{};
final urls = _getPhotoUrls(data);

urls[index] = downloadUrl;

await profileRef.set({
'profilePhotoUrls': urls,
'profilePhotoUrl': urls[0],
}, SetOptions(merge: true));

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('फोटो ${index + 1} अपलोड हो गई।')),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('फोटो अपलोड नहीं हुई: $e')),
);
} finally {
if (mounted) {
setState(() => _photoBusy = false);
}
}
}

Future<void> _deletePhoto(int index) async {
final user = FirebaseAuth.instance.currentUser;
final profileRef = _profileRef;

if (user == null || profileRef == null || _photoBusy) return;

final confirm = await showDialog<bool>(
context: context,
builder: (dialogContext) => AlertDialog(
title: const Text('फोटो हटाएँ?'),
content: Text('क्या आप फोटो ${index + 1} हटाना चाहते हैं?'),
actions: [
TextButton(
onPressed: () => Navigator.pop(dialogContext, false),
child: const Text('नहीं'),
),
FilledButton(
onPressed: () => Navigator.pop(dialogContext, true),
child: const Text('हाँ, हटाएँ'),
),
],
),
);

if (confirm != true) return;

try {
setState(() => _photoBusy = true);

final storageRef = FirebaseStorage.instance
.ref()
.child('profile_photos')
.child(user.uid)
.child(_photoFileName(index));

try {
await storageRef.delete();
} on FirebaseException catch (e) {
if (e.code != 'object-not-found') rethrow;
}

final snapshot = await profileRef.get();
final data = snapshot.data() ?? <String, dynamic>{};
final urls = _getPhotoUrls(data);

urls[index] = '';

await profileRef.set({
'profilePhotoUrls': urls,
'profilePhotoUrl': urls[0],
}, SetOptions(merge: true));

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('फोटो हटा दी गई।')),
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('फोटो नहीं हटी: $e')),
);
} finally {
if (mounted) {
setState(() => _photoBusy = false);
}
}
}
Future<void> _editProfile(
    BuildContext context,
    Map<String, dynamic> data,
    ) async {
  final name = TextEditingController(
    text: data['fullName']?.toString() ?? '',
  );
  final age = TextEditingController(
    text: data['age']?.toString() ?? '',
  );
  final city = TextEditingController(
    text: data['city']?.toString() ?? '',
  );
  final state = TextEditingController(
    text: data['state']?.toString() ?? '',
  );
  final about = TextEditingController(
    text: data['about']?.toString() ?? '',
  );

  try {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('प्रोफ़ाइल बदलें'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'पूरा नाम',
                ),
              ),
              TextField(
                controller: age,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'उम्र'),
              ),
              TextField(
                controller: city,
                decoration: const InputDecoration(labelText: 'शहर'),
              ),
              TextField(
                controller: state,
                decoration: const InputDecoration(labelText: 'राज्य'),
              ),
              TextField(
                controller: about,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'परिचय'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('रद्द करें'),
          ),
          FilledButton(
            onPressed: () async {
              final ref = _profileRef;
              if (ref == null) return;

              try {
                await ref.set({
                  'fullName': name.text.trim(),
                  'age': age.text.trim(),
                  'city': city.text.trim(),
                  'state': state.text.trim(),
                  'about': about.text.trim(),
                }, SetOptions(merge: true));

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('प्रोफ़ाइल अपडेट हो गई है।'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('अपडेट में समस्या: $e')),
                  );
                }
              }
            },
            child: const Text('सेव करें'),
          ),
        ],
      ),
    );
  } finally {
    name.dispose();
    age.dispose();
    city.dispose();
    state.dispose();
    about.dispose();
  }
}

Future<void> _logout(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Logout करें?'),
      content: const Text('क्या आप अकाउंट से बाहर निकलना चाहते हैं?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('नहीं'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('हाँ, Logout'),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  await FirebaseAuth.instance.signOut();

  if (!context.mounted) return;

  Navigator.pushNamedAndRemoveUntil(
    context,
    '/',
        (route) => false,
  );
}

void _showInfo(
    BuildContext context,
    String title,
    String message,
    ) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('ठीक है'),
        ),
      ],
    ),
  );
}

Widget _detail(String label, dynamic value) {
  final text = value?.toString().trim() ?? '';

  if (text.isEmpty) {
    return const SizedBox.shrink();
  }

  return ListTile(
    dense: true,
    title: Text(
      label,
      style: const TextStyle(color: Colors.grey),
    ),
    subtitle: Text(
      text,
      style: const TextStyle(fontSize: 16),
    ),
  );
}

@override
Widget build(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return const Scaffold(
      body: Center(
        child: Text('कृपया पहले Login करें।'),
      ),
    );
  }

  final profileRef = FirebaseFirestore.instance
      .collection('profiles')
      .doc(user.uid);

  return Scaffold(
    appBar: AppBar(
      title: const Text('मेरी प्रोफ़ाइल'),
      backgroundColor: green,
      foregroundColor: Colors.white,
    ),
    body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: profileRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('प्रोफ़ाइल लोड नहीं हो सकी।'),
          );
        }

        final exists = snapshot.data?.exists ?? false;
        final data = snapshot.data?.data() ?? <String, dynamic>{};
        final photoUrls = _getPhotoUrls(data);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'प्रोफ़ाइल फोटो (अधिकतम 4)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final photoUrl = photoUrls[index];
                final hasPhoto = photoUrl.isNotEmpty;

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _photoBusy
                      ? null
                      : () => _showPhotoOptions(index, photoUrl),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: green),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hasPhoto)
                          Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.broken_image,
                                size: 42,
                              );
                            },
                          )
                        else
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo, size: 36),
                              const SizedBox(height: 8),
                              Text('फोटो ${index + 1} जोड़ें'),
                            ],
                          ),
                        if (hasPhoto)
                          Positioned(
                            right: 6,
                            bottom: 6,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: darkGreen,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                tooltip: 'फोटो बदलें या हटाएँ',
                                onPressed: _photoBusy
                                    ? null
                                    : () => _showPhotoOptions(
                                  index,
                                  photoUrl,
                                ),
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            if (_photoBusy)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                exists &&
                    data['fullName']?.toString().isNotEmpty == true
                    ? data['fullName'].toString()
                    : 'नवजीवन सदस्य',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (!exists) ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'आपकी प्रोफ़ाइल अभी नहीं बनी है। '
                        'आगे बढ़ने के लिए प्रोफ़ाइल बनाएँ।',
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/profile',
                ),
                icon: const Icon(Icons.person_add),
                label: const Text('प्रोफ़ाइल बनाएँ'),
              ),
            ] else ...[
              Card(
                child: Column(
                  children: [
                    _detail('पूरा नाम', data['fullName']),
                    _detail('उम्र', data['age']),
                    _detail('जन्म वर्ष', data['birthYear']),
                    _detail('लिंग', data['gender']),
                    _detail('वैवाहिक स्थिति', data['maritalStatus']),
                    _detail('शहर', data['city']),
                    _detail('राज्य', data['state']),
                    _detail('धर्म', data['religion']),
                    _detail('जाति', data['caste']),
                    _detail('गोत्र', data['gotra']),
                    _detail('बच्चे', data['children']),
                    _detail('परिचय', data['about']),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _editProfile(context, data),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
              ),
            ],

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.help_outline,
                  color: darkGreen,
                ),
                title: const Text('Help'),
                subtitle: const Text('ऐप इस्तेमाल करने में सहायता'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showInfo(
                  context,
                  'Help',
                  'ऐप की सहायता संबंधी जानकारी यहाँ दिखाई जाएगी।',
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.support_agent,
                  color: darkGreen,
                ),
                title: const Text('Customer Care'),
                subtitle: const Text('संपर्क सहायता'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showInfo(
                  context,
                  'Customer Care',
                  'Customer Care का नंबर मिलने पर यहाँ जोड़ देंगे।',
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: const Text('अपने अकाउंट से बाहर निकलें'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _logout(context),
              ),
            ),
          ],
        );
      },
    ),
  );
}
}