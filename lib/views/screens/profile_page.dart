import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  set isDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                decoration: const BoxDecoration(
                  //color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 50, left: 20),
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(42, 43, 48, 1),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5.0,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Profile',
                                style: GoogleFonts.rockSalt(
                                  fontSize: 80,
                                  color: const Color.fromARGB(255, 4, 91, 163),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 140),
                      alignment: Alignment.center,
                      child: const CircleAvatar(
                        radius: 90,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                              'https://imgs.search.brave.com/Mpac-KOW2uEx8_Ot8ajvzF8kaqCCZRVozZ-SkZnfujQ/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly90NC5m/dGNkbi5uZXQvanBn/LzA2Lzc1Lzc4Lzk5/LzM2MF9GXzY3NTc4/OTk0M18yMDR3dFh2/YlMxa0JUd2JDNGhO/N2tVSGNtRGN0OVIw/di5qcGc'),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'Rahul Kumar',
            style: GoogleFonts.arvo(
              color: Colors.black,
              fontSize: 24,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            elevation: 5,
            child: ListTile(
              title: Text(
                'Email',
                style: GoogleFonts.arvo(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(
                'xyz@gmail.com',
                style: GoogleFonts.arvo(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 5,
            child: ListTile(
              title: Text(
                'Phone',
                style: GoogleFonts.arvo(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(
                '1234567890',
                style: GoogleFonts.arvo(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            elevation: 5,
            child: ListTile(
              title: Text(
                'Address',
                style: GoogleFonts.arvo(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(
                'Delhi, India',
                style: GoogleFonts.arvo(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 5,
            child: ListTile(
              title: Text(
                'Date of Birth',
                style: GoogleFonts.arvo(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(
                '01-01-2000',
                style: GoogleFonts.arvo(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => EditProfile(),
              //   ),
              // );
            },
            child: const Text('Edit Profile',
                style: TextStyle(fontSize: 20, color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
