#!/usr/bin/env python

import pandas as pd
import os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("input_file")
parser.add_argument("pheno_file")
parser.add_argument("output_dir")
args = parser.parse_args()

def gcf_splicer(fn, dr, sample_meta_d):
    gex_mat = {}
    c = 0
    c, cc = 0, 0
    with open(fn, "r") as f:
        for line in f.readlines():
            line = line[:-1].split("\t")
            c += 1
            if c == 3:
                columns = line[2:]
            if c > 3:
                gex_mat[line[0]] = line[2:]
            if c-(cc*1000) > 1000:
                cc += 1
                gex_mat = pd.DataFrame.from_dict(gex_mat, orient="index", columns=columns).melt(ignore_index=False)
                gex_mat["Tissue"] = gex_mat["variable"].map(sample_meta_d)
                grouped_df = gex_mat.groupby("Tissue")
                for x in grouped_df.groups:
                    grouped_df.get_group(x).to_csv(dr+"/"+x+".csv", mode='a', header=False)
                grouped_df = None
                gex_mat = dict()
        gex_mat = pd.DataFrame.from_dict(gex_mat, orient="index", columns=columns).melt(ignore_index=False)
        gex_mat["Tissue"] = gex_mat["variable"].map(sample_meta_d)
        grouped_df = gex_mat.groupby("Tissue")
        for x in grouped_df.groups:
            grouped_df.get_group(x).to_csv(dr+"/"+x+".csv", mode='a', header=False)
    return


if __name__ == "__main__":
    pheno = pd.read_csv(args.pheno_file, sep="\t")
    pheno["Tissue"] = pheno["SMTSD"]
    pheno["Sample"] = pheno["SAMPID"]
    pheno = pheno.loc[:, ["Sample", "Tissue"]
    sample_meta_d = pheno.set_index("Sample").to_dict()["Tissue"]
    gcf_splicer(args.input_file, args.output_dir, sample_meta_d)