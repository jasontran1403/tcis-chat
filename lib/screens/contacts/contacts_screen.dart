import 'package:chat/screens/contacts/contact_srarch_screen.dart';
import 'package:chat/screens/messages/message_screen.dart';
import 'package:chat/screens/search/components/suggested_contacts.dart';
import 'package:flutter/material.dart';

import 'components/contact_card.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("People"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ContactSearchScreen(),
              ),
            ),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: demoContactsImage.length,
        itemBuilder: (context, index) => ContactCard(
          name: "123123",
          number: "(239) 555-0108",
          image: demoContactsImage[index],
          isActive: index.isEven, // for demo
          press: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MessagesScreen(username: "ABC", usernameReceive: "DEF", accessToken: "123"),
              ),
            );
          },
        ),
      ),
    );
  }
}
