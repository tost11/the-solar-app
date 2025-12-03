/// Mixin for adding authentication capabilities to device models.
///
/// Provides username, password, and authentication enabled flag,
/// along with helper methods for JSON serialization.
///
/// This mixin can be used by any device type that requires authentication
/// (e.g., Shelly, DeyeSun, or other brands in the future).
mixin DeviceAuthenticationMixin {
  /// Username for device authentication
  String? authUsername;

  /// Password for device authentication (stored in plain text)
  String? authPassword;

  /// Serializes authentication fields to JSON
  ///
  /// Returns a map containing username, password, and authEnabled fields.
  /// Null values for username and password are excluded from the map.
  Map<String, dynamic> authToJson() {
    return {
      if (authUsername != null) 'username': authUsername,
      if (authPassword != null) 'password': authPassword
    };
  }

  /// Deserializes authentication fields from JSON
  ///
  /// Restores username, password, and authEnabled from the provided map.
  /// If authEnabled is not present in JSON, defaults to false.
  void authFromJson(Map<String, dynamic> json) {
    authUsername = json['username'] as String?;
    authPassword = json['password'] as String?;
  }
}
