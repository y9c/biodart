import 'dart:math';

/// test
int popGen() {
  print('popGen command');
  return 0;
}

/// calculate heterozygosity.
/// n is the number of sequences, m the number of alleles at this locus, and i x the observed frequency of th i allele
double calHeterozygosity(int n, List<double> l) {
  double h;
  // check input (not very concreate)
  var sum = l.reduce((c, n) => c + n);
  if (l.length > 2 && sum > 0.9 && sum < 1.1) {
    var s2 = l.map((x) => pow(x, 2)).reduce((c, n) => c + n);
    h = (n / (n - 1)) * (1 - s2);
  }
  return h;
}

/// calculate heterozygosity var.
double calHeterozygosityVar(int n, List<double> l) {
  double h;
  // check input (not very concreate)
  var sum = l.reduce((c, n) => c + n);
  if (l.length > 2 && sum > 0.9 && sum < 1.1) {
    var s2 = l.map((x) => pow(x, 2)).reduce((c, n) => c + n);
    var s3 = l.map((x) => pow(x, 3)).reduce((c, n) => c + n);
    var part = 2.0 * (n - 2) * (s3 - pow(s2, 2));
    h = 2.0 / (n * (n - 1)) * (part + s2 - pow(s2, 2));
  }
  return h;
}

/// calculate Haplotype Diversity
double calHaplotypeDiversity(int n, List<double> l) {
  double h;
  // check input (not very concreate)
  var sum = l.reduce((c, n) => c + n);
  if (l.length > 2 && sum > 0.9 && sum < 1.1) {
    var s2 = l.map((x) => pow(x, 2)).reduce((c, n) => c + n);
    h = (n / (n - 1)) * (1 - s2);
  }
  return h;
}

/// calculate Haplotype Diversity Var
double calHaplotypeDiversityVar(int n, List<double> l) {
  double h;
  // check input (not very concreate)
  var sum = l.reduce((c, n) => c + n);
  if (l.length > 2 && sum > 0.9 && sum < 1.1) {
    var s2 = l.map((x) => pow(x, 2)).reduce((c, n) => c + n);
    var s3 = l.map((x) => pow(x, 3)).reduce((c, n) => c + n);
    var part = 2.0 * (n - 2) * (s3 - pow(s2, 2));
    h = 2.0 / (n * (n - 1)) * (part + s2 - pow(s2, 2));
  }
  return h;
}

/// calculate Wright's Fst
double calWrightFst(List<double> l) {
  double fst;
  // check input (not very concreate)
  if (l.length > 2) {
    var pMean = l.reduce((c, n) => c + n) / l.length;
    var pDelta =
        l.map((x) => pow(x - pMean, 2)).reduce((c, n) => c + n) / l.length;
    fst = pDelta / (pMean * (1 - pMean));
  }
  return fst;
}
