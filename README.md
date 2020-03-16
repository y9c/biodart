# bio

Functions and command line tools for biological computation written in **Dart**.

## USAGE

- Add `bio` in pubspec.yaml
- Download binary from [release](https://github.com/yech1990/biodart/releases)

## DOCUMENTATION

### seq (Seq)

#### seqIO

- convert fastq into fasta

  ```bash
  bio seq --input ./data/seq.fq --output ./data/seq.fa
  ```

- format fasta with max number of characters per line

  ```bash
  bio seq --input ./data/seq.fq --output ./data/seq_formated.fa --fasta-line-length 20
  ```

- subset records with list of names

  ```bash
  bio seq --input ./data/seq.fq --output ./data/seq_subset.fa --filter-names ./data/name.list
  ```

- subsamples N records

  ```bash
  bio seq --input ./data/seq.fq --output ./data/seq_sampled.fa --sample 2 --sample-seed 123
  ```

- trim DNA records

  ```bash
  bio seq --input ./data/seq.fq --output ./data/seq_sample.fa --trim-start 6 --trim-end 3
  ```

#### alignIO

### phylo (Phylo)

#### treeIO

### popgen
