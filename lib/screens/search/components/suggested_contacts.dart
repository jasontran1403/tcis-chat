import 'package:chat/constants.dart';
import 'package:chat/screens/messages/message_screen.dart';
import 'package:flutter/material.dart';

class SuggestedContacts extends StatelessWidget {
  const SuggestedContacts({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Text(
            "Suggested",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .color!
                      .withOpacity(0.32),
                ),
          ),
        ),
        const SizedBox(height: defaultPadding),
        // ...List.generate(
        //   demoContactsImage.length,
        //   (index) => ListTile(
        //     contentPadding: const EdgeInsets.symmetric(
        //         horizontal: defaultPadding, vertical: defaultPadding / 2),
        //     leading: CircleAvatar(
        //       radius: 24,
        //       backgroundImage: AssetImage(demoContactsImage[index]),
        //     ),
        //     title: const Text("Jenny Wilson"),
        //     onTap: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (_) => const MessagesScreen(),
        //         ),
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}

final List<String> demoContactsImage =
    List.generate(5, (index) => "assets/images/user_${index + 1}.png");
