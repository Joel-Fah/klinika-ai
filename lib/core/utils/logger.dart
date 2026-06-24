import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';
import 'package:logging/logging.dart';

void setupLogging() {
  final genuiLogger = configureLogging(level: Level.ALL);
  genuiLogger.onRecord.listen((record) {
    debugPrint('[genui][${record.loggerName}]: ${record.message}');
  });
}
