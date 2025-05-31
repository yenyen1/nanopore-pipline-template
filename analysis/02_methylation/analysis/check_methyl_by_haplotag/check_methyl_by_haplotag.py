### Usage: python3 main.py check_methyl_by_haplotag.py gene_region.txt $(INPUT_TSV)
### Author: yenyen.wang

import sys
from dataclasses import dataclass
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


@dataclass
class SampleCount:
    _h1_methyl_count: list
    _h1_total_count: list
    _h2_methyl_count: list
    _h2_total_count: list
    _un_methyl_count: list
    _un_total_count: list

    def get_h1_freq_by_idx(self, idx: int) -> float:
        total = self._h1_total_count[idx] + self._un_total_count[idx] / 2.0
        count = self._h1_methyl_count[idx] + self._un_methyl_count[idx] / 2.0
        if total == 0:
            print("no methylation record observed in h1...")
            return 0.5
        return count / total

    def get_h2_freq_by_idx(self, idx: int) -> float:
        total = self._h2_total_count[idx] + self._un_total_count[idx] / 2.0
        count = self._h2_methyl_count[idx] + self._un_methyl_count[idx] / 2.0
        if total == 0:
            print("no methylation record observed in h2...")
            return -1.0
        return count / total

    def get_h1_freqs(self) -> list:
        out = []
        for i in range(len(self._h1_total_count)):
            out.append(self.get_h1_freq_by_idx(i))
        return out

    def get_h2_freqs(self) -> list:
        out = []
        for i in range(len(self._h2_total_count)):
            out.append(self.get_h2_freq_by_idx(i))
        return out

    def get_total_count(self) -> list:
        out = []
        for i in range(len(self._h1_total_count)):
            count = (
                self._h1_total_count[i]
                + self._h2_total_count[i]
                + self._un_total_count[i]
            )
            out.append(count)
        return out

    def get_length(self):
        return len(self._h1_methyl_count)


@dataclass
class MethylSites:
    _gene: str
    _chr: str
    _pos: list
    _sample_count: dict

    def add_sample_count(self, sample: str, count: dict):
        self._sample_count[sample] = SampleCount(
            count.get("methyl").get("h1"),
            count.get("total").get("h1"),
            count.get("methyl").get("h2"),
            count.get("total").get("h2"),
            count.get("methyl").get("un"),
            count.get("total").get("un"),
        )

    def get_pos_list(self):
        return self._pos

    def get_sample_h1_freq_list(self, sample: str):
        return self._sample_count[sample].get_h1_freqs()

    def get_sample_h2_freq_list(self, sample: str):
        return self._sample_count[sample].get_h2_freqs()

    def get_sample_total_count_list(self, sample: str):
        return self._sample_count[sample].get_total_count()

    def get_sample_list(self):
        return list(self._sample_count.keys())

    # def __str__(self):
    #     return str({"GENE": self._gene, "CHR": self._chr, "POS": self._pos, "SAMPLE_COUNT": self._sample_count})


@dataclass
class Bed:
    _id: list
    _chr: list
    _start: list
    _end: list

    def get_id(self):
        return self._id

    def is_in_regions(self, chr: str, pos: int) -> bool:
        init_pos = self._chr.index(chr)
        for i in range(init_pos, len(self._chr)):
            if self._chr[i] == chr:
                if pos < self._start:
                    break
                elif pos >= self._start and pos <= self._end:
                    return True
            else:
                break
        return False

    def is_in_id_region(self, id: str, chr: str, pos: int) -> bool:
        id_idx = self._id.index(id)
        if chr == self._chr[id_idx]:
            if pos >= self._start[id_idx] and pos <= self._end[id_idx]:
                return True
        return False

    def __str__(self):
        return str(
            {"ID": self._id, "CHR": self._chr, "START": self._start, "END": self._end}
        )


def build_methyl_list_by_gene(file: str, bed: Bed, one_gene: str) -> dict:
    methyl_dict = {}

    # 01 parse gene and methyl sites info
    current_gene = ""
    current_chr = ""
    current_pos_set = set()
    with open(file, "r") as f:
        f.readline()
        for line in f.readlines():
            ss = line[:-1].split("\t")
            if current_gene != ss[2]:
                if current_gene != "":
                    methyl_dict[current_gene] = MethylSites(
                        current_gene, current_chr, sorted(current_pos_set), dict()
                    )
                current_gene = ss[2]
                current_chr = ss[3]
                if current_gene in methyl_dict:
                    current_pos_set = set(methyl_dict.get(current_gene).get_pos_list())
                else:
                    current_pos_set = set()
            if bed.is_in_id_region(current_gene, current_chr, int(ss[4])):
                current_pos_set.add(int(ss[4]))

    methyl_dict[current_gene] = MethylSites(
        current_gene, current_chr, sorted(current_pos_set), dict()
    )

    # 02 parse sample info
    first = True
    current_gene = ""
    current_sample = ""
    current_count = {}
    current_pos_list = []
    current_pos_set = set()
    pos_idx = 0
    with open(file, "r") as f:
        f.readline()
        for line in f.readlines():
            ss = line[:-1].split("\t")

            if current_gene != ss[2]:
                if first:
                    first = False
                elif current_gene == one_gene:
                    print(
                        "       finish",
                        current_sample,
                        current_gene,
                        len(current_pos_list),
                    )
                    methyl_dict.get(current_gene).add_sample_count(
                        current_sample, current_count
                    )
                current_sample = ss[0]
                current_gene = ss[2]
                current_pos_list = methyl_dict.get(current_gene).get_pos_list()
                current_pos_set = set(current_pos_list)
                current_count = {
                    "methyl": {
                        "h1": [0] * len(current_pos_list),
                        "h2": [0] * len(current_pos_list),
                        "un": [0] * len(current_pos_list),
                    },
                    "total": {
                        "h1": [0] * len(current_pos_list),
                        "h2": [0] * len(current_pos_list),
                        "un": [0] * len(current_pos_list),
                    },
                }
            elif ss[2] != one_gene:
                pass
            elif int(ss[4]) in current_pos_set:
                pos_idx = current_pos_list.index(int(ss[4]))
                current_count.get("methyl").get(ss[1])[pos_idx] = int(ss[5])
                current_count.get("total").get(ss[1])[pos_idx] = int(ss[6])
    methyl_dict.get(current_gene).add_sample_count(current_sample, current_count)

    return methyl_dict


def get_bed(file: str) -> Bed:
    id = []
    chr = []
    start = []
    end = []
    with open(file, "r") as f:
        for line in f.readlines():
            ss = line[:-1].split("\t")
            id.append(ss[0])
            chr.append(ss[1])
            start.append(int(ss[2]))
            end.append(int(ss[3]))
    return Bed(id, chr, start, end)


def draw_heatmap(methyl_dict: dict, gene: str):
    dic = {}
    for s in methyl_dict.get(gene).get_sample_list():
        print(s)
        dic[s + "_h1"] = methyl_dict.get(gene).get_sample_h1_freq_list(s)
        dic[s + "_h2"] = methyl_dict.get(gene).get_sample_h2_freq_list(s)
    df = pd.DataFrame(dic)
    sns.clustermap(
        df.T, cmap="coolwarm", vmin=0.0, vmax=1.0, row_cluster=True, col_cluster=True
    )
    plt.savefig(gene + ".png")
    # print(df.T)


def main():
    print("[STEP01] Start: Gene bed file is parsing...")
    bed = get_bed(sys.argv[1])
    print("[STEP01] End: Gene bed file is parsed.")
    for gene in bed.get_id():
        print("[STEP02] Start: methylation file is parsing ", gene)
        methyl_dict = build_methyl_list_by_gene(sys.argv[2], bed, gene)
        print("[STEP02] End: methylation file is parsed.")
        draw_heatmap(methyl_dict, gene)


if __name__ == "__main__":
    main()
