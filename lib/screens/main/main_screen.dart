import 'dart:convert';
import 'package:animations/animations.dart';
import 'package:chat/screens/calls/calls_hsitory_screen.dart';
import 'package:chat/screens/chats/chats_screen.dart';
import 'package:chat/screens/contacts/contacts_screen.dart';
import 'package:chat/screens/profile/profile_screen.dart';
import 'package:chat/service/websocket_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../splash/splash_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int pageIndex = 0;
  String? accessToken;
  String? username;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadInfo();
  }

  Future<void> loadInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");
    final usernameSaved = prefs.getString("username");

    if (token == null) {
      await prefs.remove('accessToken');
      await prefs.remove('username');
      Get.offAll(const SplashScreen());
      return;
    }

    setState(() {
      accessToken = token;
      username = usernameSaved;
      _isLoading = false;
    });

    if (username != null && accessToken != null) {
      connectWebSocket(username!, accessToken!);
    }
  }

  List<Widget> get pageList => [
    ChatsScreen(accessToken: accessToken, username: username),
    const ContactsScreen(),
    const CallsHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  void dispose() {
    disconnectWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (
            Widget child,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            ) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: pageList[pageIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: pageIndex,
        onTap: (value) {
          setState(() {
            pageIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.messenger), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Friends"),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: "Calls"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}