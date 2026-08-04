
import 'debug_log.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() {
    return 'ApiException: $statusCode - $message';
  }

  void printError() {
    DebugLog.system(toString(), level: LogLevel.error);
  }
}
