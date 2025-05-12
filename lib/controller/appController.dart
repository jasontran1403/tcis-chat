import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';

class AppController extends GetxController {
  var isDark=false.obs;
  RxInt selectedBOttomTabIndex=RxInt(0);
  var selectedLanguage = "English".obs;
  var locale = Locale('en', 'US').obs;
}