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

  bool hasMotif(String motif) {
    return sequence.contains(motif);
  }

  void trimStart(int trimNum) {
    if (sequence != null) {
      sequence = sequence.substring(trimNum);
    }
    if (quality != null) {
      quality = quality.substring(trimNum);
    }
  }

  void trimEnd(int trimNum) {
    if (sequence != null) {
      sequence = sequence.substring(0, sequence.length - trimNum);
    }
    if (quality != null) {
      quality = quality.substring(0, sequence.length - trimNum);
    }
  }

  void reverseComplement() {
    if (sequence != null) {
      sequence = utils.reverseComplement(sequence);
    }
    if (quality != null) {
      quality = quality.split('').reversed.join();
    }
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

/// Read Fasta File as Stream
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

/// Count number of records in fasta file
int countFa(File file) {
  var count = 0;
  for (var line in file.readAsLinesSync()) {
    if (line.startsWith('>')) {
      count++;
    }
  }
  return count;
}

/// Read Fastq File as Stream
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

/// Count number of records in fasta file
int countFq(File file) {
  var count = 0;
  for (var _ in file.readAsLinesSync()) {
    count++;
  }
  return count ~/= 4;
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

/// read and write
/// filter sequence
/// manipulate sequence
void seqIO(String inputFile, String outputFile,
    {String inputFormat,
    String outputFormat,
    int fastaLineLength,
    int sample,
    int randomSeed,
    String filterNames,
    String filterMotif,
    int trimStart,
    int trimEnd,
    bool revCom = false,
    bool verbose = false,
    bool overwrite = false}) async {
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

  // var castStream = inputStream.asBroadcastStream();
  // castStream.length.then((value) => print("stream.length: $value"));

  // filter Stream<Seq>
  if (sample > 0) {
    // sampling is not compatable with filtering
    if (filterNames != null) {
      log.warning(
          'Random sampling can not be used along with `--filterNames/-n`');
      exit(1);
    }
    if (filterMotif != null) {
      log.warning(
          'Random sampling can not be used along with `--filterMotif/-m`');
      exit(1);
    }
    // random sampling
    var lineCount = countFq(infile);
    if (sample <= lineCount) {
      Random random;
      if (randomSeed == null) {
        random = Random();
      } else {
        random = Random(randomSeed);
      }
      var sampleIndex = <int>{};
      while (sampleIndex.length < sample) {
        sampleIndex.add(random.nextInt(lineCount));
      }
      print(sampleIndex);
      var elementIndex = 0;
      inputStream = inputStream.where((s) {
        var isSelected = sampleIndex.contains(elementIndex);
        elementIndex++;
        return isSelected;
      });
    }
  }
  if (filterNames != null) {
    var subsetNames = File(filterNames).readAsLinesSync();
    inputStream = inputStream.where((s) => subsetNames.contains(s.name));
  }
  if (filterMotif != null) {
    inputStream = inputStream.where((s) => s.hasMotif(filterMotif));
  }

  // edit record
  if (revCom) {
    inputStream = inputStream.map((s) => s..reverseComplement());
  }
  if (trimStart > 0) {
    inputStream = inputStream.map((s) => s..trimStart(trimStart));
  }
  if (trimEnd > 0) {
    inputStream = inputStream.map((s) => s..trimEnd(trimEnd));
  }

  // Wrtie Stream<Seq> into file
  stream2File(inputStream, outfile, outputFormat, lineLength: fastaLineLength);
}
