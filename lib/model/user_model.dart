

// class UserModel {
//   final String? id;
//   final String fullName;
//   final String email;
//   final String phoneNo;
//   final String password;

//   const UserModel({
//     this.id,
//     required this.fullName,
//     required this.email,
//     required this.phoneNo,
//     required this.password,
//   });

//   toJson(){
//     return {
//       'fullName': fullName,
//       'email': email,
//       'phoneNo': phoneNo,
//       'password': password,
//     };
//   }

//   factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
//     final data = document.data()!;
//     return UserModel(
//       id: document.id,
//       fullName: data['fullName'],
//       email: data['email'],
//       phoneNo: data['phoneNo'],
//       password: data['password'],
//     );
//   }

// }