# Usage: python3 main.py ${input} ${output}
# Author: yenyen.wang

import sys
from dataclasses import dataclass

@dataclass
class Methyl:
    _chrom: str
    _pos: int
    _modified_reads: int
    _total_reads: int

    def add_reverse_strand_read(self, modified_count:int, total_count:int):
        self._modified_reads += modified_count
        self._total_reads += total_count
    def is_the_same_methyl(self, chr:str, pos:int):
        if self._chrom != chr:
            return False
        return ( self._pos +1 == pos )
    def get_tsv_line(self):
        return self._chrom + "\t" + str(self._pos) + "\t" + str(self._pos) + "\t" + str(self._modified_reads) + "\t" + str(self._total_reads) + "\t" + str(self._modified_reads/self._total_reads) + "\n" 

def parse_tsv(input_tsv:str):
    records = list()
    with open(input_tsv, "r") as f:
        f.readline()
        for line in f.readlines():
            s = line[:-1].split("\t")
            if( s[2] == "+" ):
                records.append(Methyl(s[0], int(s[1]), int(s[3]), int(s[4])))
            else:
                if( records[-1].is_the_same_methyl( s[0], int(s[1])) ):
                    records[-1].add_reverse_strand_read(int(s[3]), int(s[4]))
                else:
                    print("no + strands " + s[0] + " " + s[1])
                    records.append(Methyl(s[0], int(s[1])-1, int(s[3]), int(s[4])))
    return records
    
def write_tsv(output_tsv:str, records:list):
    with open(output_tsv, 'w') as f:
        for record in records:
            f.write(record.get_tsv_line())

def main():
    data = parse_tsv(sys.argv[1])
    write_tsv(sys.argv[2], data)

if __name__ == '__main__':
    main()
