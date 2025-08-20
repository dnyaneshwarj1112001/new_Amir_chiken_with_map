// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http; // For dummy API call

// class ChangeAddressAlertbox extends StatefulWidget {
//   const ChangeAddressAlertbox({super.key});

//   @override
//   State<ChangeAddressAlertbox> createState() => _ChangeAddressAlertboxState();
// }

// class _ChangeAddressAlertboxState extends State<ChangeAddressAlertbox> {
//   bool isDefault = true;
//   late TextEditingController _addressController;

//   @override
//   void initState() {
//     super.initState();
//     _addressController =
//         TextEditingController(text: "John Doe\n123, Street Name, City, 567890");
//   }

//   @override
//   void dispose() {
//     _addressController.dispose();
//     super.dispose();
//   }

//   Future<void> _submitAddress() async {
//     final address = _addressController.text;

//     // Dummy API endpoint
//     final url = Uri.parse('https://jsonplaceholder.typicode.com/posts');

//     try {
//       final response = await http.post(
//         url,
//         body: {'address': address, 'is_default': isDefault.toString()},
//       );

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Address updated successfully!")),
//         );
//         Navigator.pop(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to update address.")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       title: Text(
//         "Select Address",
//         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 390,
//               decoration: BoxDecoration(
//                 color: isDefault ? Colors.green.withOpacity(0.1) : Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(
//                     color: isDefault ? Colors.green : Colors.grey.shade300),
//               ),
//               padding: EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextFormField(
//                     controller: _addressController,
//                     maxLines: null,
//                     style: TextStyle(fontSize: 16),
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                     ),
//                   ),
//                   if (isDefault)
//                     Align(
//                       alignment: Alignment.topRight,
//                       child: Container(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.green,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           "Default",
//                           style: TextStyle(
//                               color: Colors.white, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ),
//                   SizedBox(height: 10),
//                   Row(
//                     children: [
//                       TextButton.icon(
//                         onPressed: () {
//                           setState(() {
//                             isDefault = !isDefault;
//                           });
//                         },
//                         icon: Icon(Icons.check_circle, color: Colors.green),
//                         label: Text("Set as Default"),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       TextButton.icon(
//                         onPressed: () => Navigator.pop(context),
//                         icon: Icon(Icons.delete, color: Colors.red),
//                         label:
//                             Text("Delete", style: TextStyle(color: Colors.red)),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: _submitAddress,
//           child: Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
//         ),
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text("Close", style: TextStyle(fontWeight: FontWeight.bold)),
//         ),
//       ],
//     );
//   }
// }
