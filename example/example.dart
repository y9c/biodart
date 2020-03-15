//
// example.dart
// Copyright (C) 2020 Ye Chang <yech1990@gmail.com>
//
// Distributed under terms of the MIT license.
//

import 'package:bio/seq.dart' as seq;

void main() {
  seq.seqIO(
    inputFile: 'data/seq.fq',
    outputFile: 'data/seq.test',
    inputFormat: 'fq',
    outputFormat: 'fa',
    fastaLineLength: 20,
    filterNames: 'data/name.list',
    filterMotif: 'AAA',
    trimStart: 6,
    // sample: 2,
    //randomSeed: 123,
    trimEnd: 3,
    verbose: true,
    overwrite: true,
  );
}
