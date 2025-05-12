import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../constants.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../constants.dart';

class MessageAttachment extends StatefulWidget {
  final Function(File) onImageSelected;

  const MessageAttachment({
    Key? key,
    required this.onImageSelected,
  }) : super(key: key);

  @override
  _MessageAttachmentState createState() => _MessageAttachmentState();
}

class _MessageAttachmentState extends State<MessageAttachment> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permissions based on source
      if (source == ImageSource.camera) {
        var status = await Permission.camera.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Camera permission denied")),
          );
          return;
        }
      } else if (source == ImageSource.gallery) {
        var status = await Permission.photos.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gallery permission denied")),
          );
          return;
        }
      }

      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        File image = File(pickedFile.path);
        widget.onImageSelected(image);
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MessageAttachmentCard(
            iconData: Icons.camera_enhance,
            title: "Camera",
            press: () => _pickImage(ImageSource.camera),
          ),
          MessageAttachmentCard(
            iconData: Icons.photo,
            title: "Gallery",
            press: () => _pickImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}

class MessageAttachmentCard extends StatelessWidget {
  final VoidCallback press;
  final IconData iconData;
  final String title;

  const MessageAttachmentCard({
    Key? key,
    required this.press,
    required this.iconData,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding / 2),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(defaultPadding * 0.75),
              decoration: const BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                size: 20,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            )
          ],
        ),
      ),
    );
  }
}
