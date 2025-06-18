// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:wallpaper_app/controller/profile_controller.dart';
// import 'package:wallpaper_app/model/user_model.dart';

// class UpdateProfilePage extends StatefulWidget {
//   const UpdateProfilePage({super.key});

//   @override
//   _UpdateProfilePageState createState() => _UpdateProfilePageState();
// }

// class _UpdateProfilePageState extends State<UpdateProfilePage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }

//   void _updateProfile() {
//     if (_formKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Profile updated successfully!'),
//           duration: Duration(seconds: 2),
//         ),
//       );

//       // You can add the logic to update the profile here
//       // Example:
//       // Save profile info to database or API call
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(ProfileController());
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Update Profile'),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.all(16.0),
//           child: FutureBuilder(
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.done) {
//                 if (snapshot.hasData) {
//                   //UserModel userModel = snapshot.data as UserModel;
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TextFormField(
//                         initialValue: userModel.fullName,
//                         controller: _nameController,
//                         decoration: const InputDecoration(
//                           labelText: 'Name',
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.person),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your name';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         initialValue: userModel.email,
//                         controller: _emailController,
//                         decoration: const InputDecoration(
//                           labelText: 'Email',
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.email),
//                         ),
//                         keyboardType: TextInputType.emailAddress,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your email';
//                           }
//                           if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
//                               .hasMatch(value)) {
//                             return 'Please enter a valid email';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         initialValue: userModel.phoneNo,
//                         controller: _phoneController,
//                         decoration: const InputDecoration(
//                           labelText: 'Phone Number',
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.phone),
//                         ),
//                         keyboardType: TextInputType.phone,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your phone number';
//                           }
//                           if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
//                             return 'Please enter a valid phone number';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 24),
//                       Center(
//                         child: ElevatedButton(
//                           onPressed: _updateProfile,
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 32,
//                               vertical: 12,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Text(
//                             'Update Profile',
//                             style: TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 } else {
//                   return Center(child: Text('No data found'));
//                 }
//               } else {
//                 return Center(child: CircularProgressIndicator());
//               }
//             },
//             future: controller.getAllUser(),
//           ),
//         ),
//       ),
//     );
//   }
// }
