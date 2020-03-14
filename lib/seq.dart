import 'dart:io';
import 'dart:convert';
import 'dart:math';
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

  String toFaString({int lineLength}) {
    if (lineLength <= 0) {
      return '>${name}\n${sequence}\n';
    }
    var leftLenght = sequence.length;
    var leftSequence = sequence;
    var formatedSequence = '';
    while (leftLenght > 0) {
      var cutAt = min(leftLenght, lineLength);
      formatedSequence += leftSequence.substring(0, cutAt) + '\n';
      leftSequence = leftSequence.substring(cutAt);
      leftLenght -= lineLength;
    }
    return '>${name}\n${formatedSequence}';
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
      sequence = line.replaceAll(' ', '');
    } else if (lineCounter % 4 == 0) {
      quality = line;
      var s = Seq(name, sequence: sequence, quality: quality);
      yield s;
    }
  }
  log.info('finish reading fastq file~');
}

void stream2File(Stream<Seq> seqStream, File outfile, String outputFormat,
    {int lineLength = 0}) {
  var outwrite = outfile.openWrite();
  seqStream.listen((Seq s) {
    if (outputFormat == 'fa') {
      outwrite.write(s.toFaString(lineLength: lineLength));
    } else if (outputFormat == 'fq') {
      outwrite.write(s.toFqString());
    }
  }, onDone: () {
    outwrite.close();
    log.info('outFile is now closed.');
  });
}

/// convert formats
/// subset sequence
void seqIO(String inputFile, String outputFile,
    {String inputFormat,
    String outputFormat,
    int fastaLineLength,
    String subset,
    bool verbose = false,
    bool overwrite = false}) {
  final log = utils.logger('bio:Seq', verbose: verbose);

  // TODO: put file format checker into better place
  var supportedFormats = {
    'fa': 'fa',
    'fas': 'fa',
    'fasta': 'fa',
    'fastq': 'fq',
    'fq': 'fq'
  };
  inputFormat ??= inputFile.split('.').last;
  if (supportedFormats.containsKey(inputFormat)) {
    inputFormat = supportedFormats[inputFormat];
  } else {
    log.warning('${inputFormat} format is not supported!');
    exit(1);
  }
  outputFormat ??= outputFile.split('.').last;
  if (supportedFormats.containsKey(outputFormat)) {
    outputFormat = supportedFormats[outputFormat];
  } else {
    log.warning('${outputFormat} format is not supported!');
    exit(1);
  }

  final infile = File(inputFile);
  utils.fileIsExist(inputFile);
  final outfile = File(outputFile);
  if (outfile.existsSync() && !overwrite) {
    log.warning('${outfile.path} has exist, your may try to overwrite!');
    exit(1);
  }

  // Read file as Stream<Seq>
  Stream<Seq> inputStream;
  if (inputFormat == 'fa') {
    inputStream = readFa(infile);
  } else if (inputFormat == 'fq') {
    inputStream = readFq(infile);
  } else {
    log.warning('${inputFormat} format is not supported!');
    exit(1);
  }

  // filter Stream<Seq>
  if (subset != null) {
    var subsetNames = File(subset).readAsLinesSync();
    inputStream = inputStream.where((s) => subsetNames.contains(s.name));
  }

  // Wrtie Stream<Seq> into file
  stream2File(inputStream, outfile, outputFormat, lineLength: fastaLineLength);
}
