import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/macs/hmac.dart';

/// Service that hashes passwords using PBKDF2‑HMAC‑SHA256.
///
/// The generated hash and salt are stored as Base64 strings. The service
/// provides methods to hash a raw password and to verify a password against a
/// stored hash/salt pair.
class PasswordService {
  static const int _saltLength = 16; // 16 bytes = 128 bits

  /// Public so tests can assert the constant value directly.
  static const int iterations = 100000;

  static const int _derivedKeyLength = 32; // 256‑bit hash

  final SecureRandom _secureRandom = _initSecureRandom();

  /// Generates a new random salt.
  Uint8List generateSalt() => _secureRandom.nextBytes(_saltLength);

  /// Hashes the [password] with the given [salt] using PBKDF2‑HMAC‑SHA256.
  /// Returns the derived key as a Base64‑encoded string.
  String hashPassword(String password, Uint8List salt) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, iterations, _derivedKeyLength));
    final passwordBytes = utf8.encode(password);
    final key = derivator.process(Uint8List.fromList(passwordBytes));
    return base64Encode(key);
  }

  /// Generates a salt and returns a map containing both the Base64‑encoded
  /// hash and salt.
  Map<String, String> generateHashAndSalt(String password) {
    final salt = generateSalt();
    final hash = hashPassword(password, salt);
    return {
      'hash': hash,
      'salt': base64Encode(salt),
    };
  }

  /// Verifies a raw [password] against the stored Base64‑encoded [hash] and
  /// [salt] values. Returns `true` if they match.
  ///
  /// Uses a fixed-length XOR loop that examines every byte without early exit,
  /// avoiding short-circuit timing leaks.
  bool verifyPassword(String password, String storedHash, String storedSalt) {
    final saltBytes = base64Decode(storedSalt);
    final computedBytes = base64Decode(hashPassword(password, saltBytes));
    final storedBytes = base64Decode(storedHash);

    // Different lengths → corrupt or mismatched hash.
    if (computedBytes.length != storedBytes.length) return false;

    // XOR every byte; accumulate into difference without any early exit.
    int difference = 0;
    for (int i = 0; i < computedBytes.length; i++) {
      difference |= computedBytes[i] ^ storedBytes[i];
    }
    return difference == 0;
  }

  /// Helper to initialise a cryptographically secure random generator.
  static SecureRandom _initSecureRandom() {
    final secureRandom = SecureRandom('Fortuna');
    final seedSource = Random.secure();
    final seed = Uint8List.fromList(
      List<int>.generate(32, (_) => seedSource.nextInt(256)),
    );
    secureRandom.seed(KeyParameter(seed));
    return secureRandom;
  }
}
