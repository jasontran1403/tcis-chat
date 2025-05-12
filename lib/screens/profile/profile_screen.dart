import 'package:chat/constants.dart';
import 'package:chat/screens/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';

import 'components/info.dart';
import 'components/profile_pic.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          children: [
            const ProfilePic(image: "assets/images/user_2.png"),
            Text(
              "Annette Black",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(height: defaultPadding * 2),
            const Info(
              infoKey: "User ID",
              info: "@annette.me",
            ),
            const Info(
              infoKey: "Location",
              info: "New York, NYC",
            ),
            const Info(
              infoKey: "Phone",
              info: "(239) 555-0108",
            ),
            const Info(
              infoKey: "Email Address",
              info: "demo@mail.com",
            ),
            const SizedBox(height: defaultPadding),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 160,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  ),
                  child: const Text("Edit profile"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
