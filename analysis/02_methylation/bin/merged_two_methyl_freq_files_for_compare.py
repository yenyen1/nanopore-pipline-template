# Usage: python3 main.py ${input1} ${intput2} ${output}
# Author: yenyen.wang

import sys
from dataclasses import dataclass


@dataclass
class Methyl:
    _chrom: str
    _pos: int
    _modified_reads_1: int
    _total_reads_1: int
    _modified_reads_2: int
    _total_reads_2: int

    def add_input_2(self, modified: int, total: int):
        self._modified_reads_2 = modified
        self._total_reads_2 = total

    def get_tsv_line(self):
        ss = self._chrom + "\t" + str(self._pos)
        ss += (
            "\t"
            + str(self._modified_reads_1)
            + "\t"
            + str(self._total_reads_1)
            + "\t"
            + str(self._modified_reads_1 / self._total_reads_1)
        )
        ss += (
            "\t"
            + str(self._modified_reads_2)
            + "\t"
            + str(self._total_reads_2)
            + "\t"
            + str(self._modified_reads_2 / self._total_reads_2)
            + "\n"
        )
        return ss


def get_compare_file_merge(input_1: str, input_2: str):
    records = dict()
    with open(input_1, "r") as f:
        for line in f.readlines():
            s = line[:-1].split("\t")
            key = s[0] + "_" + s[1]
            records[key] = Methyl(s[0], int(s[1]), int(s[3]), int(s[4]), 0, 0)
    with open(input_2, "r") as f:
        for line in f.readlines():
            s = line[:-1].split("\t")
            key = s[0] + "_" + s[1]
            if key in records:
                records[key].add_input_2(int(s[3]), int(s[4]))
            else:
                records[key] = Methyl(s[0], int(s[1]), 0, 0, int(s[3]), int(s[4]))
    return records


def write_merged_file(records: dict, output: str):
    with open(output, "w") as f:
        for record in records.values():
            f.write(record.get_tsv_line())


def main():
    merged = get_compare_file_merge(sys.argv[1], sys.argv[2])
    write_merged_file(merged, sys.argv[3])


if __name__ == "__main__":
    main()
