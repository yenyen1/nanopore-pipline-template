### Usage: python3 extract_methyl_freq_by_bed.py $(input_TSV) $(output_TSV) cpgIslandExt.bed
### Author: yenyen.wang

import sys
from dataclasses import dataclass


@dataclass
class range:
    _pos: int
    _end: int
    def is_overlap(self, pos: int):
        return pos >= self._pos and pos <= self._end
    def is_small(self, pos: int):
        return pos < self._pos


def parse_bed(file: str) -> dict:
    bed_dict = {}
    with open(file, "r") as f:
        for line in f.readlines():
            s = line[:-1].split(" ")
            if s[0] in bed_dict:
                bed_dict[s[0]].append(range(int(s[1]), int(s[2])))
            else:
                bed_dict[s[0]] = [range(int(s[1]), int(s[2]))]
    return bed_dict


def write_by_bed(input: str, output: str, bed_dict: dict):
    first = True
    # not_write = True
    # line = ""
    with open(output, "w") as out:
        with open(input, "r") as f:
            while True:
                # if not_write:
                #    out.write(line)
                # not_write = True

                line = f.readline()
                if first:
                    out.write(line)
                    first = False
                    continue
                if line == "":
                    break
                s = line[:-1].split("\t")[1].split("_")
                if s[0] in bed_dict:
                    for r in bed_dict.get(s[0]):
                        if r.is_small(int(s[1])):
                            break
                        elif r.is_overlap(int(s[1])):
                            #            not_write = False
                            out.write(line)
                            break


def main():
    bed_dict = parse_bed(sys.argv[3])
    print("bed dictionary is generated")
    write_by_bed(sys.argv[1], sys.argv[2], bed_dict)


if __name__ == "__main__":
    main()
