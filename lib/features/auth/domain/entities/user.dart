
import 'package:flutter/foundation.dart';

@immutable
class User {
  const User({
    required this.uid,
    required this.email,
    this.displayName,
  });

  final String uid;
  final String email;
  final String? displayName;
}
