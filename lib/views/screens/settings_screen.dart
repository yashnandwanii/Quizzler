import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  _buildSettingsItem({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.lightBlue, Color.fromRGBO(3, 117, 211, 1)],
                  ),
                ),
              ),
              const Positioned(
                top: 50,
                left: 20,
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          _buildSettingsItem(label: 'Notifications', value: 'On'),
          _buildSettingsItem(label: 'Dark Mode', value: 'Off'),
          _buildSettingsItem(label: 'Language', value: 'English'),
          _buildSettingsItem(label: 'Country', value: 'Nigeria'),
          _buildSettingsItem(label: 'Version', value: '1.0.0'),
        ],
      ),
    );
  }
}
