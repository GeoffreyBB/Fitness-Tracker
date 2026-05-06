import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _usernameKey = 'username';

final usernameProvider = StateProvider<String>((ref) => '');

Future<String> loadUsername() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_usernameKey) ?? '';
}

Future<void> saveUsername(String name) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_usernameKey, name);
}

Future<void> clearUsername() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_usernameKey);
}
