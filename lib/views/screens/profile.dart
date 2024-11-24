import 'package:flutter/material.dart';
import 'package:wallpaper_app/views/screens/update_profile.dart';
import 'package:wallpaper_app/views/widgets/profile_screen_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset('assets/car.png'),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.blue.withOpacity(0.5),
                      ),
                      child: IconButton(
                        tooltip: 'Edit Profile',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>  UpdateProfilePage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'John Doe',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('example@example.com'),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                width: 200,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.blue),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>  UpdateProfilePage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
              ProfileMenuWidget(
                title: 'Settings',
                icon: Icons.settings,
                onClick: () {},
              ),
              const SizedBox(height: 10),
              ProfileMenuWidget(
                title: 'Information',
                icon: Icons.info_sharp,
                onClick: () {},
              ),
              const SizedBox(height: 10),
              ProfileMenuWidget(
                title: 'Terms and Conditions',
                icon: Icons.policy,
                onClick: () {},
              ),
              const SizedBox(height: 10),
              ProfileMenuWidget(
                title: 'Log out',
                icon: Icons.logout,
                onClick: () {},
                textColor: Colors.red,
                endIcon: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
