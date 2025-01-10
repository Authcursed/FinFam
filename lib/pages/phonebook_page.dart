import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PhonebookPage extends StatefulWidget {
  const PhonebookPage({Key? key}) : super(key: key);

  @override
  _PhonebookPageState createState() => _PhonebookPageState();
}

class _PhonebookPageState extends State<PhonebookPage> {
  late Database _database;
  List<Map<String, dynamic>> friends = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Inisialisasi database
  Future<void> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'friends.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE friends (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL
          )
        ''');
      },
    );

    _loadFriends();
  }

  // Memuat data dari database
  Future<void> _loadFriends() async {
    final data = await _database.query('friends');
    setState(() {
      friends = data;
    });
  }

  // Menambah kontak ke database
  Future<void> _addFriend(String name, String phone) async {
    if (name.isEmpty || phone.isEmpty) return;

    await _database.insert('friends', {'name': name, 'phone': phone});
    _loadFriends();
    _nameController.clear();
    _phoneController.clear();
    _showMessage("Berhasil Menyimpan Kontak");
  }

  // Memperbarui kontak di database
  Future<void> _updateFriend(int id, String name, String phone) async {
    if (name.isEmpty || phone.isEmpty) return;

    await _database.update(
      'friends',
      {'name': name, 'phone': phone},
      where: 'id = ?',
      whereArgs: [id],
    );
    _loadFriends();
    _showMessage("Kontak Berhasil Diperbarui");
  }

  // Menampilkan pesan menggunakan ScaffoldMessenger
  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(navigatorKey.currentContext!);
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Menghapus kontak dari database
  Future<void> _deleteFriend(int id) async {
    await _database.delete('friends', where: 'id = ?', whereArgs: [id]);
    _loadFriends();
    _showMessage("Kontak Berhasil Dihapus");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghapus tulisan "Debug"
      navigatorKey: navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Buku Telepon',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue,
          iconTheme:
              const IconThemeData(color: Colors.white), // Icons set to white
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Navigate back to the previous page
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactListPage(
                      friends: friends,
                      deleteFriend: _deleteFriend,
                      updateFriend: _updateFriend,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _addFriend(
                  _nameController.text,
                  _phoneController.text,
                ),
                child: const Text('Tambah Teman'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _database.close();
    super.dispose();
  }
}

// Halaman untuk menampilkan daftar kontak
class ContactListPage extends StatelessWidget {
  final List<Map<String, dynamic>> friends;
  final Function(int) deleteFriend;
  final Function(int, String, String) updateFriend;

  const ContactListPage({
    required this.friends,
    required this.deleteFriend,
    required this.updateFriend,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kontak'),
      ),
      body: friends.isEmpty
          ? const Center(
              child: Text('Belum ada kontak yang disimpan.'),
            )
          : ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return ListTile(
                  title: Text(friend['name']),
                  subtitle: Text(friend['phone']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showUpdateDialog(
                          context,
                          friend['id'],
                          friend['name'],
                          friend['phone'],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Pindah ke halaman sebelumnya sebelum menghapus kontak
                          Navigator.pop(context);
                          // Tunggu halaman pop-up selesai sebelum menghapus
                          Future.delayed(const Duration(milliseconds: 500), () {
                            deleteFriend(friend['id']);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showUpdateDialog(
      BuildContext context, int id, String currentName, String currentPhone) {
    final TextEditingController nameController =
        TextEditingController(text: currentName);
    final TextEditingController phoneController =
        TextEditingController(text: currentPhone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Perbarui Kontak'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              updateFriend(id, nameController.text, phoneController.text);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
