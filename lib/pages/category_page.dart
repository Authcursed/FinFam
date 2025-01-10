// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class CategoryPage extends StatefulWidget {
//   const CategoryPage({Key? key}) : super(key: key);

//   @override
//   State<CategoryPage> createState() => _CategoryPageState();
// }

// class _CategoryPageState extends State<CategoryPage> {
//   bool? isExpense;
//   int? type;
//   final CollectionReference categories =
//       FirebaseFirestore.instance.collection('categories');
//   TextEditingController categoryNameController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     isExpense = true;
//     type = isExpense! ? 2 : 1;
//   }

//   Future<List<Map<String, dynamic>>> getAllCategory(int type) async {
//     QuerySnapshot snapshot =
//         await categories.where('type', isEqualTo: type).get();
//     return snapshot.docs.map((doc) {
//       return {
//         ...doc.data() as Map<String, dynamic>,
//         'id': doc.id,
//       };
//     }).toList();
//   }

//   Future<void> insert(String name, int type) async {
//     DateTime now = DateTime.now();
//     await categories.add({
//       'name': name,
//       'type': type,
//       'createdAt': now.toIso8601String(),
//       'updatedAt': now.toIso8601String(),
//       'deletedAt': null,
//     });
//   }

//   Future<void> update(String categoryId, String newName) async {
//     await categories.doc(categoryId).update({
//       'name': newName,
//       'updatedAt': DateTime.now().toIso8601String(),
//     });
//   }

//   Future<void> _confirmDeleteCategory(String categoryId) async {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Konfirmasi Hapus Kategori"),
//           content: Text("Apakah Anda yakin ingin menghapus kategori ini?"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text("Batal"),
//             ),
//             TextButton(
//               onPressed: () async {
//                 await categories.doc(categoryId).update({
//                   'deletedAt': DateTime.now().toIso8601String(),
//                 });
//                 setState(() {});
//                 Navigator.of(context).pop();
//               },
//               child: Text("Hapus"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void openDialog(Map<String, dynamic>? category) {
//     categoryNameController.clear();

//     if (category != null) {
//       categoryNameController.text = category['name'];
//     }

//     showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             content: SingleChildScrollView(
//                 child: Center(
//                     child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   ((category != null) ? 'Edit ' : 'Kategori ') +
//                       ((isExpense!) ? "Pengeluaran" : "Pendapatan"),
//                   style: GoogleFonts.montserrat(
//                       fontSize: 18,
//                       color: (isExpense!) ? Colors.red : Colors.blue),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 TextFormField(
//                   controller: categoryNameController,
//                   decoration: InputDecoration(
//                       border: OutlineInputBorder(), hintText: "Kategori"),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Nama kategori tidak boleh kosong';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 ElevatedButton(
//                     onPressed: () {
//                       if (categoryNameController.text.isNotEmpty) {
//                         if (category == null) {
//                           insert(
//                               categoryNameController.text, isExpense! ? 2 : 1);
//                         } else {
//                           update(category['id'], categoryNameController.text);
//                         }
//                         setState(() {});
//                         Navigator.of(context, rootNavigator: true)
//                             .pop('dialog');
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content:
//                                   Text('Nama kategori tidak boleh kosong')),
//                         );
//                       }
//                     },
//                     child: Text("Simpan"))
//               ],
//             ))),
//           );
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Kategori"),
//         backgroundColor: Colors.blue,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Switch(
//                         value: isExpense!,
//                         inactiveTrackColor: Colors.blue[200],
//                         inactiveThumbColor: Colors.blue,
//                         activeColor: Colors.red,
//                         onChanged: (bool value) {
//                           setState(() {
//                             isExpense = value;
//                             type = (value) ? 2 : 1;
//                           });
//                         },
//                       ),
//                       Text(
//                         isExpense! ? "Pengeluaran" : "Pendapatan",
//                         style: GoogleFonts.montserrat(fontSize: 14),
//                       )
//                     ],
//                   ),
//                   IconButton(
//                       onPressed: () {
//                         openDialog(null);
//                       },
//                       icon: Icon(Icons.add))
//                 ],
//               ),
//             ),
//             FutureBuilder<List<Map<String, dynamic>>>(
//               future: getAllCategory(type!),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 } else if (snapshot.hasError) {
//                   return Center(
//                     child: Text("Terjadi kesalahan: ${snapshot.error}"),
//                   );
//                 } else {
//                   if (snapshot.hasData && snapshot.data!.isNotEmpty) {
//                     return ListView.builder(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       itemCount: snapshot.data?.length,
//                       itemBuilder: (context, index) {
//                         final category = snapshot.data![index];
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child: Card(
//                             elevation: 10,
//                             child: ListTile(
//                               trailing: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   IconButton(
//                                     icon: Icon(Icons.delete),
//                                     onPressed: () {
//                                       _confirmDeleteCategory(category['id']);
//                                     },
//                                   ),
//                                   SizedBox(width: 10),
//                                   IconButton(
//                                     icon: Icon(Icons.edit),
//                                     onPressed: () {
//                                       openDialog(category);
//                                     },
//                                   )
//                                 ],
//                               ),
//                               leading: Container(
//                                 padding: EdgeInsets.all(3),
//                                 decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(8)),
//                                 child: (isExpense!)
//                                     ? Icon(Icons.upload,
//                                         color: Colors.redAccent[400])
//                                     : Icon(Icons.download,
//                                         color: Colors.blueAccent[400]),
//                               ),
//                               title: Text(category['name']),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   } else {
//                     return Center(child: Text("Tidak ada kategori"));
//                   }
//                 }
//               },
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
// }
