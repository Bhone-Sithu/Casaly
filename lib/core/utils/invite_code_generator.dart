import 'dart:math';

class InviteCodeGenerator {
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static const int _codeLength = 6;
  static final Random _random = Random();

  static String generate() {
    return String.fromCharCodes(
      Iterable.generate(
        _codeLength,
        (_) => _chars.codeUnitAt(_random.nextInt(_chars.length)),
      ),
    );
  }

  static bool isValid(String code) {
    if (code.length != _codeLength) return false;
    return RegExp(r'^[A-Z0-9]+$').hasMatch(code);
  }
}