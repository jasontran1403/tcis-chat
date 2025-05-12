import 'dart:convert';
import 'package:http/http.dart' as http;
import '../controller/appController.dart';
import 'package:get/get.dart' as getX;

class ApiService {
  final appController = getX.Get.find<AppController>();

  // static final base_url = "http://192.168.1.205:9393/api/v1";
  static final base_url = "https://mutt-discrete-gently.ngrok-free.app/api/v1";

  static Future<bool> checkUserExists(String username, String accessToken) async {
    final url = Uri.parse('$base_url/management/find-user/$username');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print(response.body);
      if (response.statusCode == 200) {
        // API trả về true/false
        return response.body.toLowerCase() == 'true';
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Failed to check user existence: $e');
    }
  }

  static Future<dynamic> fetchAccountInfo(String username, String accessToken) async {
    final url = Uri.parse('$base_url/management/account-info/$username');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken', // Nếu API yêu cầu token
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print('Failed to load account info. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching account info: $e');
      return null;
    }
  }

  static Future<dynamic> login(String username, String password) async {
    var headers = {
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('${base_url}/auth/login'));
    request.body = json.encode({
      "username": username,
      "password": password
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    return await response.stream.bytesToString();
  }

  static Future<dynamic> register(String username, String password, String email, String phone, String fullname) async {
    var headers = {'Content-Type': 'application/json'};

    var request = http.Request('POST', Uri.parse('${base_url}/auth/register'));
    request.body = json.encode({
      "username": username,
      "password": password,
      "email": email,
      "phone": phone,
      "fullname": fullname
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    String responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw Exception('Register account failed.\n$responseBody');
    }
  }

  static Future<dynamic> fetchMessages(String username, String usernameReceive, String accessToken) async {
    final url = Uri.parse('$base_url/management/messages/$username/$usernameReceive');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken', // Nếu API yêu cầu token
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print('Failed to load message history. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching message history: $e');
      return null;
    }
  }

  static Future<dynamic> addMember(String username, String usernameReceive, String username2, String accessToken) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    var request = http.Request('POST', Uri.parse('${base_url}/management/add-member'));
    request.body = json.encode({
      "groupName": usernameReceive,
      "creatorUsername": username,
      "username": username2
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    String responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return "User: $username2 is added to the group chat successful.";
    } else {
      try {
        var responseJson = json.decode(responseBody);
        return responseJson['error'];
      } catch (_) {
        throw Exception('Add member failed.\n$responseBody');
      }
    }
  }

  static Future<dynamic> createGroup(String groupName, String username, String? accessToken) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    var request = http.Request('POST', Uri.parse('${base_url}/management/create'));
    request.body = json.encode({
      "groupName": groupName,
      "creatorUsername": username,
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    String responseBody = await response.stream.bytesToString();
    print(responseBody);

    if (response.statusCode == 200) {
      return "${groupName} is create successful.";
    } else {
      try {
        var responseJson = json.decode(responseBody);
        return responseJson['error'];
      } catch (_) {
        throw Exception('Create new group failed.\n$responseBody');
      }
    }
  }
}
