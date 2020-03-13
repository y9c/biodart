import 'dart:io';
import 'package:logging/logging.dart';

final log = Logger('bio::Utils');

Logger logger(String name, {bool verbose = false}) {
  final log = Logger(name);
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.loggerName}: ${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  if (verbose) {
    Logger.root.level = Level.ALL;
  } else {
    Logger.root.level = Level.WARNING;
  }
  return log;
}

void fileIsExist(String filename) {
  final file = File(filename);
  if (!file.existsSync()) {
    log.warning('${file.path} is not exist!');
    exit(1);
  }
}

void fileIsNotExist(String filename) {
  final file = File(filename);
  if (file.existsSync()) {
    print('${file.path} is exist!');
    exit(1);
  }
}
