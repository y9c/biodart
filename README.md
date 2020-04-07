# bio

Functions and command line tools for biological computation written in **Dart**.

[![CI Status](https://travis-ci.org/yech1990/biodart.svg?branch=master)](https://travis-ci.org/yech1990/biodart)
[![Release](https://github.com/yech1990/biodart/workflows/Release/badge.svg)](https://github.com/yech1990/biodart/actions)
[![Publish](https://github.com/yech1990/biodart/workflows/Publish/badge.svg)](https://github.com/yech1990/biodart/actions)
[![Pub Version](https://img.shields.io/pub/v/bio.svg)](https://pub.dev/packages/bio)

## USAGE

- As a dart package

  - Add `bio` in pubspec.yaml
  - Run `pub get`

- As a command line tool

  - Download binary from [release](https://github.com/yech1990/biodart/releases). linux, mac and win are available.
  - Extract the binary file `7z e bio-xxx.7z`
  - Run `./bio` + subcommand

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

## BENCHMARK

| tool            | test IO time | test RC time |
| --------------- | -----------: | -----------: |
| biodart         |        6.678 |       15.533 |
| seqkit (Golang) |        0.996 |        0.879 |
| seqtk (C)       |        0.849 |        0.854 |

