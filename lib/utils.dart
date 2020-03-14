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

//var baseReverserLower =
//    baseReverserUpper.map((k, v) => MapEntry(k.toLowerCase(), v.toLowerCase()));

const baseReverser = {
  'A': 'T',
  'B': 'V',
  'C': 'G',
  'D': 'H',
  'G': 'C',
  'H': 'D',
  'K': 'M',
  'M': 'K',
  'N': 'N',
  'R': 'Y',
  'S': 'S',
  'T': 'A',
  'U': 'A',
  'V': 'B',
  'Y': 'R',
  'W': 'W',
  'a': 't',
  'b': 'v',
  'c': 'g',
  'd': 'h',
  'g': 'c',
  'h': 'd',
  'k': 'm',
  'm': 'k',
  'n': 'n',
  'r': 'y',
  's': 's',
  't': 'a',
  'u': 'a',
  'v': 'b',
  'y': 'r',
  'w': 'w'
};

String reverseComplement(String sequence) {
  return sequence.split('').reversed.map((i) => baseReverser[i]).join('');
}
