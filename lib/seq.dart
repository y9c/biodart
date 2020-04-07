import 'dart:io' show File, exit, gzip;
import 'dart:convert' show LineSplitter, utf8;
import 'dart:math' show Random, min;
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

/// Stream<String> in Fasta(.fa) format into Stream<Seq>
Stream<Seq> _faStringStream2SeqStream(Stream<String> lines) async* {
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

/// Stream<String> in Fastq(.fq) format into Stream<Seq>
Stream<Seq> _fqStringStream2SeqStream(Stream<String> lines) async* {
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

/// Read file as Stream<Seq>
Stream<Seq> file2Stream(File file, String format, {bool isGzip = false}) {
  // Read file as Stream<String>
  Stream<String> lines;
  if (isGzip) {
    lines = file
        .openRead()
        .transform(gzip.decoder)
        .transform(utf8.decoder)
        .transform(LineSplitter());
  } else {
    lines = file.openRead().transform(utf8.decoder).transform(LineSplitter());
  }
  // parse Stream<String> into Stream<Seq>
  Stream<Seq> s;
  if (format == 'fa') {
    s = _faStringStream2SeqStream(lines);
  } else if (format == 'fq') {
    s = _fqStringStream2SeqStream(lines);
  } else {
    log.warning('${format} format is not supported!');
    exit(1);
  }
  return s;
}

/// Write Stream<Seq> as file
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

/// Count number of records in fasta file.
///
/// The number of records is counted as number of lines that starts with a
/// `>` symbol.
int countFa(File file) {
  var count = 0;
  for (var line in file.readAsLinesSync()) {
    if (line.startsWith('>')) {
      count++;
    }
  }
  return count;
}

/// Count number of records in fasta file
///
/// The number of records is counted as number of lines that starts with a
/// `@` symbol.
/// Note: multiple lines fastq file is not supported.
int countFq(File file) {
  var count = 0;
  for (var _ in file.readAsLinesSync()) {
    count++;
  }
  return count ~/= 4;
}

/// # Read and write sequences file.
///
/// ## Features
///
/// - format fille
///   - parse gz format
///   - max number of charaters per line
///
/// - filter sequence
///   - random subsample
///   - filter records by list of names
///   - filter records by sequence motif
///
/// - manipulate sequence
///   - trime 5' end of the squence
///   - trime 3' end of the squence
///   - Reverse complement the sequence of each record
///
void seqIO(
    {String inputFile,
    String outputFile,
    bool inputCompressed,
    String inputFormat,
    String outputFormat,
    bool outputCompressed,
    int fastaLineLength,
    int sample = 0,
    int randomSeed,
    String filterNames,
    String filterMotif,
    int trimStart,
    int trimEnd,
    bool revCom = false,
    bool verbose = false,
    bool overwrite = false}) async {
  final log = utils.logger('bio:Seq', verbose: verbose);

  // precheck argument compatable
  if (inputFile == '-') {
    inputFile = '/dev/stdin';
  }
  if (outputFile == '-') {
    outputFile = '/dev/stdout';
    overwrite = true;
  }
  final infile = File(inputFile);
  if (!infile.existsSync()) {
    log.warning('${infile.path} does not exist');
    exit(1);
  }
  final outfile = File(outputFile);
  if (outfile.existsSync() && !overwrite) {
    log.warning('${outfile.path} has exist, your may try to overwrite!');
    exit(1);
  }
  // TODO: put file format checker into better place
  var supportedFormats = {
    'fa': 'fa',
    'fas': 'fa',
    'fasta': 'fa',
    'fastq': 'fq',
    'fq': 'fq'
  };

  bool isGzip;
  if (inputFile.split('.').last == 'gz') {
    isGzip = true;
    var nameSplited = inputFile.split('.');
    inputFormat ??= nameSplited[nameSplited.length - 2];
  } else {
    isGzip = false;
    inputFormat ??= inputFile.split('.').last;
  }
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

  // Read file as Stream<Seq>
  var inputStream = file2Stream(infile, inputFormat, isGzip: isGzip);

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

void alignIO() {
  log.info('running alignIO...');
}
