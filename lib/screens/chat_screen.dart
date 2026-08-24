import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. डेटाबेस लाइब्रेरी जोड़ी

class ChatScreen extends StatefulWidget {
  final String partnerName;

  // कोड यहाँ सुधारा गया है: कंस्ट्रक्टर का सिंटैक्स अब बिल्कुल सही है 🔐
  const ChatScreen({super.key, required this.partnerName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  // --- मैसेज को इंटरनेट डेटाबेस (Firebase) में हमेशा के लिए सेव करने का फंक्शन ---
  void _sendMessage() async {
    String messageText = _messageController.text.trim();

    if (messageText.isNotEmpty) {
      _messageController.clear(); // टाइपिंग बॉक्स को तुरंत साफ़ करें

      try {
        // फ़ायरबेस के 'chats' नाम के नए कलेक्शन में लाइव मैसेज डालना
        await FirebaseFirestore.instance.collection('chats').add({
          'text': messageText,
          'senderName': 'Me', // अभी के लिए भेजने वाले का नाम 'Me' रखा है
          'receiverName': widget.partnerName,
          'timestamp': FieldValue.serverTimestamp(), // संदेश भेजने का सटीक समय
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('मैसेज भेजने में एरर: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              child: Text(
                widget.partnerName.isNotEmpty ? widget.partnerName[0] : '?',
                style: const TextStyle(color: Colors.deepPurple),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.partnerName,
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                 Row(
                  children: const [
                    Icon(Icons.shield, color: Colors.green, size: 12),
                    SizedBox(width: 4),
                    Text("नंबर पूरी तरह गुप्त है", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // --- StreamBuilder: यह इंटरनेट से मैसेज की लिस्ट को लाइव और रियल-टाइम दिखाता है ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .orderBy('timestamp', descending: true) // नए मैसेज सबसे नीचे दिखेंगे
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("बातचीत शुरू करें। आपका नंबर सुरक्षित है।", style: TextStyle(color: Colors.black45)),
                  );
                }

                final chatDocs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // लिस्ट को नीचे से ऊपर की तरफ दिखाने के लिए
                  padding: const EdgeInsets.all(16.0),
                  itemCount: chatDocs.length,
                  itemBuilder: (context, index) {
                    final msgData = chatDocs[index].data() as Map<String, dynamic>;
                    String text = msgData['text'] ?? '';
                    bool isMe = msgData['senderName'] == 'Me';

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.deepPurple : Colors.grey.shade200,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                        ),
                        child: Text(
                          text,
                          style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // typing bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "मैसेज टाइप करें...",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
