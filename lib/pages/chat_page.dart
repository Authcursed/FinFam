import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart'; // Pastikan jalur import benar
import '../widgets/global_drawer.dart';

class ChatPageWithDrawer extends StatefulWidget {
  const ChatPageWithDrawer({super.key});

  @override
  _ChatPageWithDrawerState createState() => _ChatPageWithDrawerState();
}

class _ChatPageWithDrawerState extends State<ChatPageWithDrawer> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _currentRoomId;
  String? _selectedUser;

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentRoomId == null)
      return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await _firestore
          .collection('chats')
          .doc(_currentRoomId)
          .collection('messages')
          .add({
        'text': _messageController.text.trim(),
        'sender': currentUser.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      _showError('Gagal mengirim pesan. Error: $e');
    }
  }

  Future<void> _selectUser(String userEmail) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final roomId = _generateRoomId(currentUser.email!, userEmail);
    setState(() {
      _currentRoomId = roomId;
      _selectedUser = userEmail;
    });
  }

  String _generateRoomId(String user1, String user2) {
    final users = [user1, user2]..sort();
    return users.join('_');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Column(
      children: [
        Expanded(
          child: _currentRoomId == null
              ? _buildUserList()
              : _buildChatMessages(currentUser),
        ),
        if (_currentRoomId != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _currentRoomId = null;
                      _selectedUser = null;
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration:
                        const InputDecoration(hintText: 'Tulis pesan...'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Text('Kirim'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada pengguna lain.'));
        }

        final users = snapshot.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index].data() as Map<String, dynamic>;
            final email = user['email'];
            final profileImage =
                user['profileImage'] ?? 'https://via.placeholder.com/150';
            final name = user['name'] ?? email;

            if (email == _auth.currentUser?.email) return SizedBox.shrink();

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(profileImage),
              ),
              title: Text(name),
              subtitle: Text(email),
              onTap: () => _selectUser(email),
            );
          },
        );
      },
    );
  }

  Widget _buildChatMessages(User? currentUser) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chats')
          .doc(_currentRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Belum ada pesan.'));
        }

        final messages = snapshot.data!.docs;
        return ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index].data() as Map<String, dynamic>;
            final isSender = message['sender'] == currentUser?.email;

            return Align(
              alignment:
                  isSender ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSender ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  message['text'] ?? '',
                  style:
                      TextStyle(color: isSender ? Colors.white : Colors.black),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
