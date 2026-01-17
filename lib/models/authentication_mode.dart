/// Defines authentication field behavior in manual device addition UI
enum AuthenticationMode {
  /// No authentication field shown (device doesn't support auth)
  none,

  /// Authentication field shown but can be left empty (device supports but doesn't require auth)
  optional,

  /// Authentication field shown and must be filled (device requires auth)
  required,
}
