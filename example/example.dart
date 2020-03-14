//
// example.dart
// Copyright (C) 2020 Ye Chang <yech1990@gmail.com>
//
// Distributed under terms of the MIT license.
//

import 'package:bio/seq.dart' as seq;

void main() {
  seq.seqIO(
    'data/seq.fq',
    'data/seq.test',
    inputFormat: 'fq',
    outputFormat: 'fa',
    fastaLineLength: 20,
    subset: 'data/name.list',
    sample: 1,
    randomSeed: 123,
    verbose: true,
    overwrite: true,
  );
}
