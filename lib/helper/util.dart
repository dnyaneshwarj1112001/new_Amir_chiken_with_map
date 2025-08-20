import 'dart:convert';
import 'dart:developer';

class Util {
  static void pretty(dynamic data) {
    var encoder = const JsonEncoder.withIndent('  ');
    String prettyJson = encoder.convert(data);
    log(prettyJson);
  }
}
