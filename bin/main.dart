import 'package:bio/bio.dart' as bio;
import 'package:bio/seq.dart' as seq;
import 'package:bio/phylo.dart' as phylo;
import 'package:args/command_runner.dart';

void main(List<String> arguments) {
  var runner = CommandRunner('git', 'Distributed version control.')
    ..addCommand(HelloCommand())
    ..addCommand(SeqCommand())
    ..addCommand(PhyloCommand());

  runner.run(arguments);
}

class HelloCommand extends Command {
  @override
  final name = 'hello';
  @override
  final description = 'Just say hello';
  @override
  void run() {
    print(argResults.arguments);
    print('Hello world: ${bio.calculate()}!');
  }

  HelloCommand() {
    argParser.addFlag('hello', abbr: 'i');
  }
}

class SeqCommand extends Command {
  @override
  final name = 'seq';
  @override
  final description = 'Deal with sequence file in various formats.';
  @override
  void run() {
    seq.seqIO(
        inputFile: argResults['input'],
        outputFile: argResults['output'],
        inputFormat: argResults['input-format'],
        outputFormat: argResults['output-format'],
        inputCompressed: argResults['input-compressed'],
        outputCompressed: argResults['output-compressed'],
        fastaLineLength: int.parse(argResults['fasta-line-length']),
        sample: int.parse(argResults['sample']),
        randomSeed: int.tryParse(argResults['sample-seed']),
        filterNames: argResults['filter-names'],
        filterMotif: argResults['filter-motif'],
        trimStart: int.parse(argResults['trim-start']),
        trimEnd: int.parse(argResults['trim-end']),
        revCom: argResults['reverse-complement'],
        verbose: argResults['verbose'],
        overwrite: argResults['overwrite']);
  }

  SeqCommand() {
    argParser
      ..addOption('input',
          abbr: 'i', defaultsTo: '-', valueHelp: 'Path of input file')
      ..addOption('output',
          abbr: 'o', defaultsTo: '-', valueHelp: 'Path of output file')
      ..addOption('input-format',
          abbr: 's', help: 'Format of input file', valueHelp: 'auto')
      ..addOption('input-compressed',
          help: 'Whether input file is in .gz format', valueHelp: 'auto')
      ..addOption('output-format',
          abbr: 't', help: 'Format of output file', valueHelp: 'auto')
      ..addOption('output-compressed',
          help: 'Whether output file is in .gz format', valueHelp: 'auto')
      ..addOption('fasta-line-length',
          abbr: 'l', defaultsTo: '0', help: 'Number of charaters in each line')
      ..addOption('sample',
          abbr: 'r',
          defaultsTo: '0',
          help: 'Random subsample records by number')
      ..addOption('sample-seed',
          defaultsTo: 'null', help: 'Random seed used for subsampling')
      ..addOption('filter-names',
          abbr: 'n', help: 'Extract sequences with names in file `name.list`')
      ..addOption('filter-motif',
          abbr: 'm', help: 'Extract sequences that match a motif')
      ..addOption('trim-start',
          abbr: '5',
          defaultsTo: '0',
          help: 'Trim n bases at the 5\' end.\n'
              'Also discard sequence that shorter than thresfold.')
      ..addOption('trim-end',
          abbr: '3',
          defaultsTo: '0',
          help: 'Trim n bases at the 3\' end.\n'
              'Also discard sequence that shorter than thresfold.')
      ..addFlag('reverse-complement',
          help: 'Reverse complement the sequence of each record')
      ..addFlag('verbose', abbr: 'v')
      ..addFlag('overwrite', abbr: 'f');
  }
}

class PhyloCommand extends Command {
  @override
  final name = 'phylo';
  @override
  final description = 'Deal with phylogentics data.';
  @override
  void run() {
    phylo.phyloIO();
  }

  PhyloCommand() {
    argParser
      ..addOption('input', abbr: 'i', help: 'Path of input file')
      ..addOption('output', abbr: 'o', help: 'Path of output file');
  }
}
