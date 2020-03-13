import 'dart:io';
import 'dart:convert';
import 'package:bio/utils.dart' as utils;

class Seq {
  String name;
  String description;
  String sequence;
  String quality;

  Seq(String name, {String sequence, String quality}) {
    this.name = name;
    this.sequence = sequence;
    this.quality = quality;
  }

  //String toString() {}

  String toFaString() {
    return '>${name}\n${sequence}\n';
  }

  String toFqString() {
    return '@${name}\n${sequence}\n+\n${quality}\n';
  }
}

final log = utils.logger('bio:Seq');

/// Read Fasta File
Stream<Seq> readFa(File file) async* {
  final lines =
      file.openRead().transform(utf8.decoder).transform(LineSplitter());
  var recordCounter = 0;
  Seq s;
  String name;
  String sequence;
  await for (var line in lines) {
    if (line.startsWith('>')) {
      if (recordCounter >= 1) {
        yield s;
      }
      recordCounter++;
      name = line.replaceFirst('>', '');
      sequence = '';
    } else {
      sequence += line;
      // update Seq object
      s = Seq(name, sequence: sequence);
    }
  }
  yield s;
  log.info('finish reading fasta file~');
}

/// Read Fastq File
Stream<Seq> readFq(File file) async* {
  final lines =
      file.openRead().transform(utf8.decoder).transform(LineSplitter());
  var lineCounter = 0;
  String name;
  String sequence;
  String quality;
  await for (var line in lines) {
    lineCounter++;
    if (lineCounter % 4 == 1) {
      name = line.replaceFirst('@', '');
    } else if (lineCounter % 4 == 2) {
      sequence = line;
    } else if (lineCounter % 4 == 0) {
      quality = line;
      var s = Seq(name, sequence: sequence, quality: quality);
      yield s;
    }
  }
  log.info('finish reading fastq file~');
}

// convert formats
void convert(String inputFile, String outputFile,
    {String inputFormat,
    String outputFormat,
    bool verbose = false,
    bool overwrite = false}) {
  final log = utils.logger('bio:Seq', verbose: verbose);

  // TODO: put file format checker into better place
  inputFormat ??= inputFile.split('.').last;
  outputFormat ??= outputFile.split('.').last;

  final infile = File(inputFile);
  final outfile = File(outputFile);
  if (outfile.existsSync() && !overwrite) {
    log.warning('${outfile.path} has exist, your may try to overwrite!');
    exit(1);
  }

  var outwrite = outfile.openWrite();

  Stream<Seq> inputStream;
  if (inputFormat == 'fa') {
    inputStream = readFa(infile);
  } else if (inputFormat == 'fq') {
    inputStream = readFq(infile);
  } else {
    log.warning('${inputFormat} format is not supported!');
    exit(1);
  }
  inputStream.listen((Seq s) {
    if (outputFormat == 'fa') {
      outwrite.write(s.toFaString());
    } else if (outputFormat == 'fq') {
      outwrite.write(s.toFqString());
    } else {
      log.warning('${outputFormat} format is not supported!');
      exit(1);
    }
  }, onDone: () {
    outwrite.close();
    log.info('outFile is now closed.');
  }, onError: (e) {
    log.warning(e.toString());
  });
}
