import 'package:bio/bio.dart' as bio;
import 'package:bio/seq.dart' as seq;
import 'package:bio/utils.dart' as utils;
import 'package:args/command_runner.dart';

void main(List<String> arguments) {
  var runner = CommandRunner('git', 'Distributed version control.')
    ..addCommand(HelloCommand())
    ..addCommand(SeqCommand());

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
    seq.convert(argResults['input'], argResults['output'],
        inputFormat: argResults['input-format'],
        outputFormat: argResults['output-format'],
        fastaLineLength: int.parse(argResults['fasta-line-length']),
        verbose: argResults['verbose'],
        overwrite: argResults['overwrite']);
  }

  SeqCommand() {
    argParser
      ..addOption('input', abbr: 'i', help: 'Path of input file')
      ..addOption('output', abbr: 'o', help: 'Path of output file')
      ..addOption('input-format',
          abbr: 's', help: 'Format of input file', valueHelp: 'auto')
      ..addOption('output-format',
          abbr: 't', help: 'Format of output file', valueHelp: 'auto')
      ..addOption('fasta-line-length',
          abbr: 'l', defaultsTo: '0', help: 'Number of charaters in each line')
      ..addFlag('verbose', abbr: 'v')
      ..addFlag('overwrite', abbr: 'f');
  }
}
