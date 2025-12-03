import 'dart:math';

class Utils {
  static String generateRandomToken(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure(); // cryptographically secure RNG
    return List.generate(
      length,
          (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }
}