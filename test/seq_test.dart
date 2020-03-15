import 'package:bio/seq.dart' as seq;
import 'package:test/test.dart';

void main() {
  test('Test reverse complement method of Seq class', () {
    expect(test_reverseComplement(), true);
  });
}

bool test_reverseComplement() {
  var s = seq.Seq('name1', sequence: 'ATGC', quality: 'KKII');
  s.reverseComplement();
  return s.sequence == 'GCAT' && s.quality == 'IIKK';
}
