import 'dart:io';
import 'dart:convert';
import 'package:bio/utils.dart' as utils;

// convert formats
void convert(String inputFile, String outputFile,
    {bool verbose = false, bool overwrite = false}) {
  final log = utils.logger('bio:Seq', verbose: verbose);

  final infile = File(inputFile);
  final outfile = File(outputFile);
  if (outfile.existsSync() && !overwrite) {
    log.warning('${outfile.path} has exist, your may try to overwrite!');
    exit(1);
  }

  // fastq to fasta
  var outwrite = outfile.openWrite();
  var lineCounter = 0;
  infile.openRead().transform(utf8.decoder).transform(LineSplitter()).listen(
      (String line) {
    lineCounter++;
    if (lineCounter % 4 == 1) {
      outwrite.write(line.replaceFirst('@', '>') + '\n');
    } else if (lineCounter % 4 == 2) {
      outwrite.write('${line}\n');
    }
  }, onDone: () {
    log.info('inFile is now closed.');
    outwrite.close();
    log.info('outFile is now closed.');
  }, onError: (e) {
    log.warning(e.toString());
  });
}
